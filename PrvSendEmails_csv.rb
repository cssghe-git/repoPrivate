#
=begin
    # =>    PrvSendEmails_csv
    # =>    VRP: 1-1-1 241101-0511
    # =>    Function : send emails to 'csv records'
    # =>        
    # =>    Parameters :
    #           P1: Y or N
    #           P2: Mode => E or L
    #           P3: Date
    #
    # =>    Process :
                ?
    #
=end
require 'rubygems'
require 'timeout'
require 'net/http'
require 'net/smtp'
require 'uri'
require 'json'
require 'csv'
require 'pp'
#   require 'dir'
#
comm_dir    = '~/pCloudSync/Progs/Prod/PartCommon/'
prod_dir    = '~/pCloudSync/Progs/Prod/PartP/'
beta_dir    = '~/pCloudSync/Progs/Dvlps/Private/'

require "#{comm_dir}ClCommon.rb"
require "#{comm_dir}ClNotion.rb"
#
    _com = Common.new(false)
    current_dir     = _com.currentDir()
    others_dir      = _com.otherDirs()
    downloads_dir   = others_dir['downloads']
#
#   Parameters
#   ==========
begin
    _debug  = ARGV[0]       #Y or N or 1..9
    _mode   = ARGV[1]       #L for log or E for Execute
    _date   = ARGV[2]       #date
rescue
    _debug  = 'N'
    _mode   = 'L'
    _date   = ''
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
#   Internal functions
#   ==================
    #
    def readCsvLine(p_row=[])
    #++++++++++++++
    #   INP::   row array 1 string to split(;)
    #   OUT::   row hash into @csv_array
        #check
        return  false   if p_row.length == 0
        pp  p_row
        p_row   = p_row[0]                  #extract string
        row     = p_row.split(";")          #split into fields
        #load array
        @csv_array  = {}                    #clear array
        @csv_fields.each do |field| #<L1>   #load array
            name    = field[0]
            index   = field[1]
            type    = field[2]
            value   = row[index]            #if conversion
            puts    "Fields::NAME:#{name}-INDEX:#{index}-TYPE:#{type}-VAL:#{value}"
            case    type    #<SW2>
            when    'T'     #<SW2>
                value   = "*"   if value.nil? or value.size == 0
                row[index]  = value
            when    'D'     #<SW2>
                value   = "#{value[6,4]}-#{value[3,2]}-#{value[0,2]}"
                row[index]  = value
            when    'I'
                point   = value.index('.')
            else
                row[index]  = value
            end #<SW2>
            @csv_array[name]    = row[index]    #add entry {name=>value}
        end #<L1>
       #
       return   true
    end #<def>
    #
#   Variables
#   =========
    program     = 'PrvLoadStatements_csv'
#####Variables#####
    integr      = 'secret_FIhPnoyaCFBlTWzD1Y4BBRbzEx7chTck1HkAm14uBd3'  #    #https://www.notion.so/cssghe/12372117082a8054aad7ffb0513b5a61?v=12372117082a803480f5000c9ba48bb6&pvs=4
    db_name     = 'enct-Fin_iverses'
                    #https://www.notion.so/cssghe/12372117082a801daa1feb1ef00ffa9d?v=12372117082a8059adb5000cbae6f76c&pvs=4
    db_id       = '12372117082a801daa1feb1ef00ffa9d'
    cbc_id      = '511dea44b6ef41f18029830e1b8e224c'    #https://www.notion.so/cssghe/CBC-Commun-511dea44b6ef41f18029830e1b8e224c?pvs=4
#####Variables#####

#   csv infos
    @csv_fields     = [
        ['Object',0,'T'],
        ['Header',1,'T'],
        ['Body',2,'T'],
        ['Trailer',3,'T'],
        ['Sign',4,'T'],
        ['To',5,'T']
    ]
    @csv_array      = {}
    @csv_statements = []

#   row infos

#   BD infos

#
#   Init
#   ====
#####Classes-start#####
    #Common class

    #Notion class
    _not    = ClNotion.new()
    rc      = _not.loadParams(_debug)
    rc      = _not.initNotion(integr,db_id)             #init cycle

    #CSV class
    
#####Classes-end#####

    _com.start(program,'Start of Script -> Load statements')
    _com.step("Prms::Prod: Debug:#{_debug}/#{_dbgflag}/#{_dbglvl} Mode:#{_mode}")
    _com.step("DBID: #{db_id} - Key: #{integr}")

    #
    t           = Time.now                                      #get time
    currtime    = t.strftime("%Y-%m-%dT%H:%M").strip            #extract YYYY-MM-DD

#    Main code
#   ==========
#
    #Select file to read
    #+++++++++++++++++++
    _com.step("List of .csv files")
#    Dir.chdir("/users/Gilbert/Library/Mobile Documents/com~apple~CloudDocs/Downloads")
    Dir.chdir(downloads_dir)
    allfiles    = Dir.glob("*.csv")
    allfiles.each_with_index do |file,index|    #<L1>
        puts    "#{index+1}.#{file}"
    end #<L1>
    print   "Please select file to process by N° => "
    fileindex   = $stdin.gets.chomp.to_i
    fileselect  = allfiles[fileindex-1]
    _com.step("File selected: #{fileselect}")

    #loop all rows fo extract fields
    #+++++++++++++++++++++++++++++++
    _com.step("Extract statements")
    csv_flag    = false
    CSV.foreach(fileselect) do |row|    #<L1> => @csv_array
        if csv_flag #<IF2>
            readCsvLine(row)
            puts    "DBG>>CSV:#{@csv_array}"
            @csv_statements.push(@csv_array)    #add to statements
        else    #<IF2>
            csv_flag    = true
            next
        end #<IF2>
    end #<L1>

    #Confirm
    #+++++++
    print   "Do you confirm: remove Cyber: #{_date} y/n ? "
    reply   = $stdin.gets.chomp
    reply   = reply.upcase
    if reply != 'Y'
        _com.exit(program,"No confirm")
        exit    1
    end
    
    #Send eMails
    #+++++++++++
    _com.step("Send emails")
    countemails =   0
    @csv_statements.each do |statement| #<L1>loop all statements
        puts    "DBG>>STATEMENT:#{statement}"
        if _mode == 'E' #<IF2>
            arrto   = []
            arrto.push(statement['To'])
            statement['Object'] = "Cyber : " + _date
            message = statement['Body']
            statement['Body']   = message.gsub("DD/MM/YYYY",_date)
            _com.sendEmails(arrto,statement)
            countemails += 1
            if countemails > 10 #<IF3>
                sleep   10
                countemails = 0
            end #<IF3>
        else    #<IF2>
            puts    "LOG>>REC:#{statement}"
        end #<IF2>
    end #<L1>
    #
    _com.stop(program,"Byebye")
#