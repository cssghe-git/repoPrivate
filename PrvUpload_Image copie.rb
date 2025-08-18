#
=begin
    #Function:  uploadd images to Notion
    #Call:      ruby PrvUpload_Image.rb N
    #Parameters::
        #P1:    Debug => true/Y=>debug f/ alse/N=>None
        #P2:    Mode => L for log only / E for execute
        #P3:    ?
    #Actions:
        #Create date: 20250530 with Build: 01.01.01
        #Updates:
            #Build: ? <>    Logs: ?
=end
# Required
#*********
#require gems
require 'rubygems'
require 'net/http'
require 'net/smtp'
require 'timeout'
require 'uri'
require 'json'
require 'csv'
require 'pp'
require 'pdfkit'
#
#***** Directories management *****
# Start of block
    require_dir = Dir.pwd
    ### puts    "dirREQUIRE:"+require_dir
require "#{require_dir}/ClDirectories.rb"
    _dir    = Directories.new(false)
# End of block
#***** Directories management *****
#

#
# Input parameters
#*****************
begin
    _debug  = ARGV[0]
    _mode   = ARGV[1]
rescue
    _debug  = false
    _mode   = 'L'
end
    _debug  = true if _debug == 'Y'
    _debug  = false if _debug == 'N'

# Check parameters
#*****************
    if _debug
        puts "Debug mode: #{_debug}"
    end

#
#***** Exec environment *****
# Start of block
    program = 'PrvUpload_Image'
    exec_mode   = 'B'                                   #change B or P
    dbglevel    = 'DEBUG'
    arrdirs = _dir.otherDirs(exec_mode)                 #=>{exec,private,membres,common,send,work}
require "#{arrdirs['common']}/ClCommon_2.rb"
    _com    = Common_2.new(program,_debug,dbglevel)
    private_dir = arrdirs['private']
    member_dir   = arrdirs['membres']                     #members directory
    common_dir   = arrdirs['common']                     #common directory
    work_dir    = arrdirs['work']
    send_dir    = arrdirs['send']
require "#{arrdirs['common']}/ClNotion_2F.rb"
# End of block
#***** Exec environment *****
#

#
# Variables
#**********
    count       = 0                                     #counter for uploaded files
    count_sel   = 0                                     #counter for sequence file
    reply_ok    = 'X'                                   #reply for processing
    not_key     = 'filesupload'                         #key for mdCommon_Dbs
    not_code =  ''                                      #api return-code
    body_add    = {}                                    #body for add page
    page_id     = ''                                    #ID of the page created in Notion
    result      = {}                                    #api result

    directory   = ''
    dir_flag    = false
    dir_index   = 0
    dir_start   = ''
    dir_select  = ''
    dir_list    = []
    # predefined locations
    dir_pre = {
        '#icloud.documents'                 => '/users/Gilbert/Library/Mobile Documents/com~apple~CloudDocs/Documents',
        '#icloud.downloads'                 => '/users/Gilbert/Library/Mobile Documents/com~apple~CloudDocs/Downloads',
        '#pcloud.documents.informatic'      => '/users/Gilbert/pCloud Drive/Documents/Informatic',
        '#pcloud.eaglefiler_temptemp'       => '/users/Gilbert/pCloud Drive/EagleFiler_Temp',
        '#pcloud.ighe/ghe-dos_etc.rapports' => '/users/Gilbert/pCloud Drive/iGhe/Ghe-Dos_etc/Rapports'
    }
#
# Internal functions
#*******************

# Main code
#**********
    # Initialize
    #+++++++++++
    # Notion class
    _not    = ClNotion_2F.new('Private')                 # Private DBs familly

    _com.logData("**********")
    _com.start(program," Start at #{Time.now} ")
    _com.logData(" Start at #{Time.now} ")
    _com.step("1-Initialize>")
    _com.logData("1-Initialize>")
    rc  = _not.loadParams(_debug,_not)                  #load params to Notion class
    _com.step("1A-loadParams => #{rc}")
    _com.logData("1A-loadParams => #{rc}")
    rc  = _not.initNotion(not_key)                      #init new cycle for 1 DB
    _com.step("1B-initNotion for #{not_key}=> #{rc}")
    _com.logData("1B-initNotion for #{not_key}=> #{rc}")

    #
    # Processing
    #+++++++++++
    _com.step("2-Processing")
    _com.logData("2-Processing")
    Dir.chdir("/users/Gilbert")                         #start @ home directory
    print "Current directory: #{Dir.pwd} - set to [# for predefined or @ for list]: "
    directory   = $stdin.gets.chomp

    if directory.include?('#')  #<IF1>
        # Predefined directories
        dir_flag = true
        ## Display
        dir_pre.each_with_index do |dir,index| #<L2>    #display all entries
            puts "#{index+1} -> #{dir}"
        end #<L2>
        ## Select
        print "Select directory by N°: "
        dir_index = $stdin.gets.chomp.to_i - 1
        exit 5 if dir_index < 0 || dir_index >= dir_pre.length
        directory = dir_pre.values[dir_index]           #entry selected
        _com.step("2A-Predefined directory selected: #{directory}")
        _com.logData("2A-Predefined directory selected: #{directory}")
    end #<IF1>

    if directory.include?('@')  #<IF1>
        # Directories & sub-directories
        dir_flag = true
        dir_start = "/users/Gilbert/pCloud Drive"
        dir_index = 999
        while dir_index > 0 #<L2>
            dir_list = Dir.glob("#{dir_start}/*").select{|entry| File.directory?(entry) && !entry.include?('Library')}
            # Display lists
            dir_list.each_with_index do |dir,index| #<L2>
                puts "#{index+1} -> #{dir}"
            end
            # Select directory
            print "Select directory by N°: "
            dir_index = $stdin.gets.chomp.to_i-1
            exit 5 if dir_index < 0 || dir_index >= dir_list.length
            dir_select = dir_list[dir_index]            #entry selected
            puts "You selected: #{dir_select}"
            print "Next sub-directory? [Y/N]: "
            reply = $stdin.gets.chomp.strip.upcase
            if reply == 'Y' #<IF3>
                dir_start = dir_select                  #go to next sub-directory
            else    #<IF3>
                directory = dir_select                  #select it
                dir_index = 0
                _com.step("2B-Tree directory selected: #{directory}")
                _com.logData("2B-Tree directory selected: #{directory}")
            end #<IF3>
        end #<L2>
    end #<IF1>

    if dir_flag
        if File.directory?(directory) == false    #<IF1>
            puts "###ERR>Directory does not exist: #{directory}"
            exit 1                                      #ERROR
        end #<IF1>
        Dir.chdir(directory)                            #change to directory
    else
        if File.directory?("/users/Gilbert/"+directory) == false    #<IF1>
            puts "###ERR>Directory does not exist: #{directory}"
            exit 1                                      #ERROR
        end #<IF1>
        Dir.chdir("/users/Gilbert/#{directory}")        #change to directory
    end
    _com.step("2C-Set directory to: #{Dir.pwd}")
    _com.logData("2C-")
    _com.logData("2C-Set directory to: #{Dir.pwd}")
    _com.logData("2C-")
    directory_path  = Dir.pwd                            #get current directory path
    selected_files  = Dir.glob("#{directory_path}/*.{gif,jpeg,jpg,png}")

    _com.step("3-Selected images: #{selected_files.length}")
    _com.logData("3-Selected images: #{selected_files.length}")
    selected_files.each do |file_path|  #<L1>
        file_name = File.basename(file_path)            #get file name
        file_size = File.size(file_path)                #get file size
        file_type = File.extname(file_name).delete('.') #get file type without dot
        file_tags = "upload,#{file_type}"               #set tags for the file
        file_data = File.read(file_path)                #read file data

        # Upload or not 
        puts "*"
        count_sel   +=1
        _com.step("3A-Processing image: #{file_name} as #{count_sel}/#{selected_files.length}")
        _com.logData("3A-Processing image: #{file_name} as #{count_sel}/#{selected_files.length}")
        if reply_ok != 'ALL'    #<IF2>
            print "Ok for this image to upload: #{file_name} (#{file_size} bytes, type: #{file_type}) [Y/N/Q]: "
            reply_ok    = $stdin.gets.chomp.strip.upcase
            next if reply_ok.nil? or reply_ok.empty? or reply_ok.size < 1
            exit 7 if reply_ok == 'Q' || reply_ok == 'QUIT' || reply_ok == 'EXIT' || reply_ok.size == 0
            next if reply_ok == 'N' || reply_ok == 'NO' || reply_ok == 'NONE'
            next if reply_ok != 'Y' && reply_ok != 'ALL'
        else    #<IF2>
            _com.step("3A-Ok for this image to upload: #{file_name} (#{file_size} bytes, type: #{file_type}")
        end #<IF2>

        # Get tags
        if reply_ok != 'ALL'    #<IF2>
            print "Define tags for the file (default: #{file_tags}): "
            file_tags   = $stdin.gets.chomp.strip
        end #<IF2>
        file_tags   = "upload,#{file_type}" if file_tags.empty? or file_tags.nil? or file_tags.size < 2 #default tags
        file_tags   = file_tags.split(',').map(&:strip) #split tags by comma and remove spaces

        # Create a new page in Notion
        _com.step("4-Process page for: #{file_name}")
        _com.logData("4-")
        _com.logData("4-Process page for: #{file_name}")
        _com.logData("4-")
        _com.step("4A-Creating page for: #{file_name}")
        _com.logData("4A-Creating page for: #{file_name}")
        body_add    = {
            'Reference' => {'title' => [{'text' => {'content' => file_name}}]},
            'FileName'  => {'rich_text' => [{'text' => {'content' => file_path}}]},
            'Tags'      => {'multi_select' => file_tags.map { |tag| {'name' => tag} }},
            'Type'      => {'select' => {'name' => file_type}},
            'FileSize'  => {'number' => file_size.to_i}
        }
        if _mode == 'E' #<IF2>                          #execute mode
            result      = _not.addPage('', body_add)    #get result
            not_code    = result['code']                #extract code
            page_id     = result['id']                  #extract ID
        else    #<IF2>
            not_code = '900'                            #log mode
        end #<IF2>
        _com.step("4B-Notion add page result: #{not_code} [900 = Log only]")
        _com.logData("4B-Notion add page result: #{not_code} [900 = Log only]")

        # Upload to Notion
        _com.step("5-Uploading: #{file_name} (#{file_size} bytes)")
        _com.logData("5-Uploading: #{file_name} (#{file_size} bytes)")
        if _mode == 'E' #<IF2>
            rc = _not.upLoadFile(page_id, file_name, file_data, file_size)  #upload image
            if rc   #<IF3>
                _com.step("5A-Upload successful for #{file_name}")          #OK
                _com.logData("5A-Upload successful for #{file_name}")          #OK
                count += 1
            else    #<IF3>
                _com.step("###ERR>5B-Upload failed for #{file_name}")       #ERR
                _com.logData("###ERR>5B-Upload failed for #{file_name}")       #ERR
            end #<IF3>
        else    #<IF2>
            _com.step("5C-Upload skipped for #{file_name} (Log only mode)") #LOG
        end #<IF2>
    end #<L1>

    #Display counters
    #================
    _com.step("6-Counters::Images:#{count}")
    _com.logData("6-Counters::Images:#{count}")
    _com.stop(program,"Done at #{Time.now} ")
#<EOS>