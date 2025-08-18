#
=begin
    #Function:  Send a SMS to some recipients
    #Build:     1.2.1   <250126-0715>
    #Call:      ruby PrvSenSMS_csv.rb N E DD/MM/YYYY
    #Parameters::
        #P1:    debug   Y N [N]
        #P2:    mode    L or E
        #P3:    date    DD/MM/YYYY

    #<1.2.1>    get text message from txt file
    #<1.1.1>    get sms numbers from csv file
=end
#Require
#*******
#require gems
require 'rubygems'
require 'net/http'
require 'net/smtp'
require 'timeout'
require 'time'
require 'date'
require 'uri'
require 'json'
require 'csv'
require 'pp'
#require specific
#
#My classes
comm_dir    = '/Volumes/Shares/Progs/Prod/PartCommon/'
prod_dir    = '/Volumes/Shares/Progs/Prod/PartP/'
beta_dir    = '/Volumes/Shares/Progs/Dvlps/Private/'
#
require "#{comm_dir}ClCommon.rb"
    _com        = Common.new(true)
    exec_dir    = _com.currentDir()
#
#Internal functions
#******************
    def readFileLine(p_row=[])
        #+++++++++++++++
        #   INP::   row array 1 string to split(;)
        #   OUT::   row hash into @csv_array
            #check
            return  false   if p_row.length == 0
            row     = p_row.split(";")          #split into fields
            ### pp  row
            #load array
            @csv_array  = {}                    #clear array
            @csv_fields.each do |field| #<L1>   #load array
                name    = field[0]
                index   = field[1]
                type    = field[2]
                value   = row[index]            #
                ### puts    "Fields::NAME:#{name}-INDEX:#{index}-TYPE:#{type}-VAL:#{value}"
                case    type    #<SW2>          #<SW1>for conversion
                when    'T'     #<SW2>          #text
                    value   = "*"   if value.nil? or value.size == 0
                when    'D'     #<SW2>          #date
                    value   = "#{value[6,4]}-#{value[3,2]}-#{value[0,2]}"
                when    'N'                     #number
                    value   = value.gsub(',','.').to_f
                when    'TA'                    #text to adapt
                else                            #others
                end #<SW2>  #<SW1>
                #load array
                @csv_array[name]    = value     #add entry {name=>value}
            end #<L1>
           #
           return   true
        end #<def>
        #    
    #
#Variables
#*********
    program         = 'TestsSMS'
    cyber_date      = ''
    cyber_time      = ''

    #File variables
    file_fullname   = ''

    #csv variables
    @csv_fields     = [
        ['Phone',3,'T'],
        ['SMS',4,'T']
    ]
    @csv_array      = {}
    @csv_statements = []

    #sms variables
    api_username    = 'cssghe@heintje.net'
    api_password    = ''
    api_key         = 'NzUzMTUzNmE3NzMxNjY0NjUzMzc2NjU5NDEzMDRmNmM='
    api_test        = true
    api_sender      = 'Gilbert'
    api_recipients  = []
    api_message     = ''
    api_msghdr      = "*****\n"
    api_message_1   = "Bonjour, bonsoir,\nAttention: la séance du Cyber du:"
    api_message_2   = "est annulée, veuillez nous en excuser.\nGilbert"
    api_msgtlr      = "\n*****"
    api_sender      = "Eneo.Cyber-Gilbert"
    api_time        = ""
    api_order       = ""

#Input parameters
#****************
    _debug  = ARGV[0]
    _mode   = ARGV[1]
    _date   = ARGV[2]
    
#Internal functions
#******************
#      
#
#Main code
#*********
    #Initialize
    #++++++++++
    _com.start(program,"Send SMS - DEBUG:#{_debug} MODE:#{_mode} DATE:#{_date}")
    _com.step("Initialize")

    Dir.chdir("/users/Gilbert/Library/Mobile Documents/com~apple~CloudDocs/Downloads")
    #Get text file
    _com.step("List of .txt files")
    allfiles    = Dir.glob("*.txt")                         #display files
    allfiles.each_with_index do |file,index|    #<L1>
        puts    "#{index+1}.#{file}"
    end #<L1>
    print   "Please select file to process by N° => "
    fileindex   = $stdin.gets.chomp.to_i
    ftxtselect  = allfiles[fileindex-1]
    _com.step("File selected: #{ftxtselect}")

    #Load message text
    _com.step("Extract message text")
    #    File.foreach(ftxtselect) do |line|  #<L1> => api_message
    #        pp  line    if _debug == 'Y'
    #        api_message = api_message + line
    #    end #<L1>
    filetxt = File.open(ftxtselect)                         #open file
    filedata    = filetxt.read                              #get text
    filetxt.close                                           #close file
    api_message = filedata.gsub("<DD/MM/YYYY>",_date)       #replace date
    pp  api_message     if _debug == 'Y'
    #Check length
    if api_message.size > 155   #<IF1>
        _com.exit(program,"Text exceeds max size")
        exit 1
    end #<IF1>

    #Get sms numbers csv file
    _com.step("List of .csv files")
    allfiles    = Dir.glob("*.csv")                         #display files
    allfiles.each_with_index do |file,index|    #<L1>
        puts    "#{index+1}.#{file}"
    end #<L1>
    print   "Please select file to process by N° => "
    fileindex   = $stdin.gets.chomp.to_i
    fcsvselect  = allfiles[fileindex-1]
    _com.step("File selected: #{fcsvselect}")

    #Load recipients number
    _com.step("Extract numbers")
    csv_flag    = false
    File.foreach(fcsvselect) do |row|   #<L1> => @csv_array
        pp  row     if _debug == 'Y'
        if csv_flag #<IF2>
            readFileLine(row)
            _com.debug("LINE:#{@csv_array}")
            sms = @csv_array['SMS']
            if sms == 'Yes' #<IF3>
                num = @csv_array['Phone']
                api_recipients.push(num)                    #add to recipients array
            end #<IF3>
        else    #<IF2>
            csv_flag    = true
            next
        end #<IF2>
    end #<L1>
    pp  api_recipients      if _debug == 'Y'

    #Set sms variables value
    cyber_date  = Date.parse(_date)                         #=>YYYY-MM-DD
    cyber_time  = "#{cyber_date.year}#{cyber_date.month}#{cyber_date.day}090000"
    api_message = "#{api_msghdr}#{api_message_1} <#{_date}> #{api_message_2}#{api_msgtlr}"
    api_msgsize = api_message.size
    api_order   = cyber_date
    api_time    = cyber_time
    _com.step("INIT:#{cyber_date}, #{api_time}, #{api_message} with #{api_msgsize} chars for #{api_recipients}")
    ###_com.exit(program,"End for tests")
    ###exit 9

    #Confirm
    #+++++++
    print   "Do you confirm: remove Cyber: #{_date} y/n ? "
    reply   = $stdin.gets.chomp
    reply   = reply.upcase
    if reply != 'Y'
        _com.exit(program,"No confirm")
        exit    1
    end

    #Main phase
    #++++++++++
    _com.step("Send SMS")
    _com.step("Send request")
    #Send message
    #++++++++++++
    # Send the request & check response
    if _mode == 'E'     #<IF1>
        requested_url   = 'https://api.txtlocal.com/send/?' 
        uri             = URI.parse(requested_url)
        http            = Net::HTTP.start(uri.host, uri.port)
        request         = Net::HTTP::Get.new(uri.request_uri)
        res             = Net::HTTP.post_form(  uri, 
                                                'apikey'    => api_key, 
                                                'message'   => api_message, 
                                                'sender'    => api_sender, 
                                                'numbers'   => api_recipients,
                                                'test'      => api_test
                                            )
        response        = JSON.parse(res.body)
        code            = response['status']   
        if code == "success"   #<IF2>
        _com.step("SMS sent successfully:: CODE:#{code}")
        pp  response
        else    #<IF2>
            _com.step("Error::CODE:" + code + ", MESSAGE:" + response)
            _com.exit(program,"<Send error>")
            exit 5
        end #<IF2>
    else    #<IF1>
        _com.step("LOG:simulate SMS sent")
    end #<IF1>
    
    #Exit phase
    #++++++++++
    _com.stop(program,"End of script")
#****

=begin

=end