#
=begin
    #Function:  management of Cyber DBs
    #Call:      ruby CybMeetings.rb N
    #Parameters::
        #P1:    true/Y=>debug false/N=>None
        #P2:    L / E
        #P3:    ?
    #Actions:
        #
        #
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
    exec_mode   = 'B'                                   #change B or P
    require_dir = Dir.pwd
    common_dir  = "/users/Gilbert/Public/Progs/Prod/Common/"    if exec_mode == 'P'
    common_dir  = "/users/Gilbert/Public/Progs/Dvlps/Common/"    if exec_mode == 'B'
require "#{common_dir}/ClDirectories.rb"
    _dir    = Directories.new(false)
    arrdirs = _dir.otherDirs(exec_mode)                 #=>{exec,private,membres,common,send,work}
# End of block
#***** Directories management *****
#

#
# Input parameters
#*****************
# Start of block
begin
    _debug  = ARGV[0]
    _mode   = ARGV[1]
rescue
    _debug  = false
    _mode   = 'L'
end
    _debug  = true if _debug == 'Y'
    _debug  = false if _debug == 'N'
# End of block

# Check parameters
#*****************
# Start of block
    if _debug
        puts "Debug mode: #{_debug}"
    end
    current_mode = 'L'
# End of block
#
#***** Exec environment *****
# Start of block
    program     = 'CybMeetings'
    dbglevel    = 'DEBUG'

require "#{arrdirs['common']}/ClCommon_2.rb"
    _com    = Common_2.new(program,_debug,dbglevel)
require "#{arrdirs['common']}/ClNotion_2F.rb"

    private_dir     = arrdirs['private']                #private directory
    member_dir      = arrdirs['membres']                #members directory
    common_dir      = arrdirs['common']                 #common directory
    work_dir        = arrdirs['work']
    send_dir        = arrdirs['send']
    download_dir    = arrdirs['idown']                  #download iCloud
# End of block
#***** Exec environment *****
#
#
# Variables
#**********
    not_key     = 'cybmeetings'
    count       = 0
    flag_loop   = true
    flag_wait   = false
    timeloop    = 5

    arrfunctions = {
            '01'  => ["*","**","***"],
            '10' => ["View meetings","","N L"],
            '02'  => ["*","**","***"]
    }
#
# Internal functions
#*******************

# Main code
#**********
    # Initialize
    #+++++++++++
    # Notion class
    _not    = ClNotion_2F.new('Cyber')                   #Cyber DBs familly

    _com.start(program," ")
    _com.logData(" ")
    _com.step("1-Initialize>")
    rc  = _not.loadParams(_debug,_not)                  #load params to Notion class
    _com.step("1A-loadParams => #{rc}")
    rc  = _not.initNotion(not_key)                      #init new cycle for 1 DB
    _com.step("1B-initNotion for #{not_key}=> #{rc}")

    #
    # Processing
    #+++++++++++
    _com.step("2-Processing")
    _com.step("2A:: Fonction requested: None")
    while flag_loop #<L1>
        # get request
        #++++++++++++
        _com.step("2A:: Choice <Cyber> function to execute on #{current_mode}")
        #Display infos
        puts    "*****"
        puts    "Functions :"
        puts    "*"

        arrfunctions.each do |key,function|  #<L2>
            puts    "*  (#{key})  => #{function[0]} with Args: <#{function[2]}>"
        ###    puts    "*"
        end #<L2>

        puts    "*****"
        #get choice
        print   ">>>Enter your choice : "
        repfct  = $stdin.gets.chomp                 #get choice
        repfct  = repfct.to_i
        repfct  = repfct * 10   if repfct < 10

        prog_key    = repfct.to_s
        if prog_key == '0'  #<IF2>
            _com.exit(program,'Exit requested by operator')
            exit 0
        end #<IF2>
        _com.step("2B:: Function #{repfct} - #{arrfunctions[prog_key][0]} in progress...")

        # Execute it
        #+++++++++++
        case repfct #<L2
        when 10                                         #view meetings
            rc  = _not.initNotion(not_key)              #init new cycle
            filter = {}
            sort = [
                {'property' => 'Reference','direction'=> 'ascending'}
            ]
            _not.runPages(filter,sort) do |code,data|  #<L3>
                if code == true and !data.nil?  #<IF4>  #extract pages
                    ###pp data
                    properties  = _not.loadProperties(data,['ALL'])  #extract properties
                    titre       = properties['Reference']            #extract Titre
                    etat    = properties['Etat']
                    membres = properties['Membre']
                    _com.step("3A-REF:#{titre} => Etat:#{etat} => Membres:#{membres} ")

                else    #<L4>
                    break
                end #<L4>


            end #<L3>
        end #<L2>
        ###exit 9

        flag_wait   = true
        while   flag_wait    #<L2>
            # Next
            #+++++
            _com.step("3::Next function => wait #{timeloop}secs/#{timeloop/60}mins or enter your request [q, n] ")
            answer  = _com.wait(timeloop,true)
            puts    "DBG>ANSWER:#{answer}"
            if answer == 'q'
                flag_loop   = false
                flag_wait   = false
            else
                _com.debug('>>>Forced loop')
                flag_wait   = false
            end
        end #<L2>

    end #<L1

    #Display counters
    #================
    _com.step("6-Counters::Requests:#{count}")
    _com.stop(program,"Bye bye")
#<EOS>