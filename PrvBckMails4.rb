#
=begin
    *   Program:    PrvBckMails
    *   Call:       ruby PrvBckMails4.rb
    *   Purpose:    Save emails to Notion DB
    *   Build:      20250507T204500
    *   Author:     Gilbert
    *   Version:    4.1.1 - 20250513T204500
    *   History:
    *   20250507T204500 - 1.0 - Gilbert - First version
    *   20250513T171000 - 4.1.1 - Gilbert - new dirs
    *   INP:    Works
    *   OUT:    DB emails
=end
# Require
#********
#require gems
require 'rubygems'
require 'timeout'
require 'time'
require 'date'
require 'uri'
require 'json'
require 'csv'
require 'pp'
#require specific
#
require '/users/Gilbert/Public/Progs/Prod/PartCommon/ClDirectories.rb'
    exec_mode   = 'P'                                   #change B or P
    _dir    = Directories.new('N')
    arrdirs = _dir.otherDirs(exec_mode)                 #=>{exec,private,membres,common,send,work}
require "#{arrdirs['common']}/ClCommon_2.rb"
    _com    = Common_2.new(false)
#
require "#{arrdirs['common']}/ClNotion_2.rb"
#
    work_dir    = "#{arrdirs['work']}"
#
# Parameters
# ==========
begin
    _debug  = ARGV[0]       #Y or N or 1..9
    _mode   = ARGV[1]       #L for log or E for Execute
    _wxyz   = ARGV[2]       #
rescue
    _debug  = 'N'
    _mode   = 'L'
end
    _dbgflag    = 'N'
    _dbglvl     = 0
    _mode   = _mode.upcase
    if _debug.class == 'String'
        _debug  = _debug.upcase
        if _debug == 'Y'
          _dbglvl   = 9
          _dbgflag  = 'Y'
        else
          _dbglvl   = 0
        end
    else
        _dbglvl   = 0
        _dbgflag  = 'N'
    end
#
# Internal functions
#*******************
#
# Variables
#**********
    program     = 'PrvBckMails'

    attachment  = ''
    body        = {}
    code        = ''
    count_files = 0
    count_add   = 0
    fileselect  = ''
    flag_loop   = false
    flag_text   = false
    fulltext    = ''
    header      = {}
    item        = {}
    repref      = ''
    result      = {}
    text        = ''

    index       = 0
    targets     = [
        'emails25',
        'archives24',
        'archives23',
        'archives22',
        'archives21',
        'archives20',
        'archives19',
        'archives18',
        'archives17'
    ]
#
# Input parameters
#*****************
    _com.step("List of Targets")
    targets.each.with_index do |target,index|  #L1>
        puts    "#{index+1}.#{target}"
    end #<L1>
    print   "Please select target to process by N° => "
    reptarget   = $stdin.gets.chomp                 #get index
    exit 7   if reptarget.size == 0
    target      = targets[index-1]                  #get target

#
# Main code
#**********
    # Initialize
    #+++++++++++
    _com.start("Start of #{program} at #{Time.now}")
    _com.step("Init Notion for <eMails>")
    _eml    = ClNotion_2.new('Private')
    rc  = _eml.loadParams('N',_eml)
    rc  = _eml.initNotion(target)

    #
    # Loop files
    #+++++++++++
    flag_loop   = true                                  #default
    # Loop
    path    = work_dir
    while   flag_loop   #<L1>
        # Make Reference
        print   "What is the reference for next files ? => "
        repref  = $stdin.gets.chomp                     #get it
        exit 0  if repref.nil?

        # Display list of files & select 1 or exit
        Dir.chdir(path)                                 #change dir
        _com.step("Directory checked : #{path}")
        allfiles    = Dir.glob("*.txt")                 #extract filenames
        allfiles.each_with_index do |file,index|        #<L2>
            puts    "#{index+1}.#{file}"
        end #<L2>
        print   "Please select file(s) to process by N° => "
        repfirst    = $stdin.gets.chomp                 #get indexes (Fr_To)
        break   if repfirst.size == 0
        arrindex    = repfirst.split('_')               #make array

        # Loop all files
        for fileindex in arrindex[0].to_i..arrindex[1].to_i do   #<L2>
            fileselect  = allfiles[fileindex-1]         #select file
            _com.step("File: #{fileindex} : #{fileselect} => selected")

=begin    
            f1  = File.open(fileselect,'r')
            puts "Handle: #{f1}"
            begin
                contenu = f1.read
                puts contenu
            ensure
                f1.close
            end
=end
            # Init body
            body    = {
                'Reference'=>{'title'=>['text'=>{'content'=>repref}]}
            }
            # Init vars
            attachment  = ''
            flag_text   = false
            fulltext    = ''
            header      = ''
            text        = '***Start of Text***'

            # Loop each line
            File.foreach(fileselect) do |line|    #<L3>
                #    puts ("DBG>>LINE:: #{line}-#{line.size}")
                fulltext.concat(line)                       #save all lines
                # Extract infos & add to body
                if line.include?('Sujet :') #<IF4>
                    item    = {'Subject'=>{'rich_text'=>[{'text'=>{'content'=>line}}]}}
                    body.merge!(item)
                elsif line.include?('De :')
                    item    = {'Sender'=>{'rich_text'=>[{'text'=>{'content'=>line}}]}}
                    body.merge!(item)
                elsif line.include?('Date :')
                    item    = {'Date'=>{'rich_text'=>[{'text'=>{'content'=>line}}]}}
                    body.merge!(item)
                elsif   line.include?('Pour :')
                    item    = {'To'=>{'rich_text'=>[{'text'=>{'content'=>line}}]}}
                    body.merge!(item)
                elsif   line.include?('Copie à :')
                    item    = {'CopyTo'=>{'rich_text'=>[{'text'=>{'content'=>line}}]}}
                    body.merge!(item)
                elsif   line.include?('Répondre à :')
                    item    = {'ReplyTo'=>{'rich_text'=>[{'text'=>{'content'=>line}}]}}
                body.merge!(item)
                elsif   line.include?('Disposition-Notification-To:')
                    item    = {'NotifyTo'=>{'rich_text'=>[{'text'=>{'content'=>line}}]}}
                    body.merge!(item)
                elsif   line.include?("* Attachments-")
                    attachment.concat(line)
                elsif   line.include?('X-')
                    header.concat(line)
                end #<IF4>
                if flag_text    #<IF4>
                    text.concat(line)                   #save line of text
                else    #<IF4>
                    flag_text   = true  if line.size < 3
                end #<IF4>
            end #<L3>

            #close text parts
            text    = text[0,1900]  if text.size > 1900
            text.concat("\n\n***End of Text***")
            item    = {'Text'=>{'rich_text'=>[{'text'=>{'content'=>text}}]}}
            body.merge!(item)
            header  = header[0,1990] if header.size > 1990
            item    = {'Header'=>{'rich_text'=>[{'text'=>{'content'=>header}}]}}
            body.merge!(item)
            fulltext    = fulltext[0,1990]  if fulltext.size > 1990
            item    = {'Body'=>{'rich_text'=>[{'text'=>{'content'=>fulltext}}]}}
            body.merge!(item)
            item    = {'Attachment'=>{'rich_text'=>[{'text'=>{'content'=>attachment}}]}}
            body.merge!(item)

            # Add page to Notion DB
            #   pp body
            if _mode == "E"
                result  = _eml.addPage('',body)
                code    = result['code']
                if code == '200'
                    _com.step("Mail/Page added with code : #{code}")
                else
                    _com.step("Mail/Page not added for error : #{result}")
                end
            else
                _com.step("*")
            end

            _com.step("File: #{fileindex} : #{fileselect} => backup done")
            _com.step("")
        end #<L2>
    end #<L1
#
#Exit phase
#++++++++++
