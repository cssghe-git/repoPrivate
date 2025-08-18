#
=begin
    #Program:   PrvMenus
    #Build:     4-1-1   <250309-1245>
    #Function:  Execute private applications
    #Call:      ruby PrvMenus.rb P1 P2 P3 P4 P5
    #Folder:    Public/Progs/.
    #Parameters::
        #P1:    Prod (P) or Beta (B) or Alpha (A)
        #P2:    debug   Y N [N]
        #P3:    loop    count of loop before sleeping   [0]
        #P4:    sleep   how many secs   [60]
        #P5:    function to execute @ start   [0]
=end
#
#Require
#*******
require 'rubygems'
### require 'profile'
require 'timeout'
require 'net/http'
require 'net/smtp'
require 'uri'
require 'json'
require 'csv'
require 'pp'
#
#***** Directories management *****
# Start of block
    load_dir = Dir.pwd
    Dir.chdir("#{load_dir}/../Common")
    require_dir   = Dir.pwd
require "#{require_dir}/ClDirectories.rb"
    _dir    = Directories.new(false)
# End of block
#***** Directories management *****

#
# Arguments
#**********
begin
    _exec   = ARGV[0]   #Prod or Beta
    _debug  = ARGV[1]   #debug:: true or false
    _loop   = ARGV[2]   #loop
    _tmo    = ARGV[3]   #timeout
    _funct  = ARGV[4]   #function to execute @ start
rescue
    _exec   = 'B'
    _debug  = false
    _loop   = 0
    _tmo    = 60
    _funct  = 0
end
    _exec   = _exec.upcase
    _loop   = _loop.to_i
    _tmo    = _tmo.to_i
    _funct  = _funct.to_i
#
#***** Exec environment *****
# Start of block
    program     = 'PrvMenus'
    dbglevel    = 'DEBUG'
    exec_mode   = _exec                                 #change B or P
    arrdirs = _dir.otherDirs(exec_mode)                 #=>{exec,private,membres,common,send,work}
require "#{arrdirs['common']}/ClCommon_2.rb"
    _com    = Common_2.new(program,false,dbglevel)
    private_dir = arrdirs['private']
    work_dir    = arrdirs['work']
    send_dir    = arrdirs['send']
# End of block
#***** Exec environment *****

#
#Variables
#*********
    repfct      = _funct
    timeout     = _tmo
    timemin     = timeout/60
    timestart   = "06:45"
    timestop    = "19:00"
    timeloop    = _tmo * 5
    flagloop    = true
    flagwait    = true

    arrfunctions    = {
        '01'  => ["*","**","***"],
        '10'  => ["Send events to iCloud","#{private_dir}/PrvSndToiCloud4","N L"],
        '11'  => ["Send events to iCloud","#{private_dir}/PrvSndToiCloud4","N E"],
        '03'  => ["**********","**","***"],
        '20'  => ["PrvLoadStatements_CBC","#{private_dir}/PrvLoadStatements_CBC4","N L"],
        '21'  => ["PrvLoadStatements_CBC","#{private_dir}/PrvLoadStatements_CBC4","N E"],
        '22'  => ["PrvLoadStatements_MC","#{private_dir}/PrvLoadStatements_MC4","N L"],
        '23'  => ["PrvLoadStatements_MC","#{private_dir}/PrvLoadStatements_MC4","N E"],
        '24'  => ["PrvLoadStatements_Visa","#{private_dir}/PrvLoadStatements_Visa4","N L"],
        '25'  => ["PrvLoadStatements_Visa","#{private_dir}/PrvLoadStatements_Visa4","N E"],
        '04'  => ["**********","**","***"],
        '40'  => ["PrvUpload-File","#{private_dir}/PrvUpload_File","N L"],
        '41'  => ["PrvUpload_File","#{private_dir}/PrvUpload_File","N E"],
        '42'  => ["PrvUpload-Media","#{private_dir}/PrvUpload_Media","N E"],
        '43'  => ["PrvUpload-File4","#{private_dir}/PrvUpload_File4","N E"],
        '05'  => ["**********","**","***"],
        '30'  => ["PrvMakeWeekReport","#{private_dir}/PrvMakeWeekReport","N E"],
        '50'  => ["PrvMakeCalendar","#{private_dir}/PrvMakeCalendar","N"],
        '06'  => ["***********","**","***"],
        '51'  => ["PrvListBooks","#{private_dir}/PrvListBooks","N"],
        '07'  => ["***********","**","***"],
        '60'  => ["CybMeetings","#{private_dir}/CybMeetings","N L"],
        '02'  => ["*","**","***"]
    }

#
# Internal functions
#*******************
#
# Main code
#**********
    # Initialize
    #+++++++++++
    _com.start(program,"Menu pour les programmes <Privés> on #{private_dir}")
    current_mode = Dir.pwd
    current_mode = "Beta"    if current_mode.include?('Dvlps')
    current_mode = "Prod"    if current_mode.include?('Prod')

    # Loop
    #+++++
    flagloop    = true
    while flagloop  #<L1>
        t           = Time.now                          #get time
        currtime    = t.strftime("%k:%M").strip         #extract HH:MM
        currsize    = currtime.size
        currtime    = "0#{currtime}"    if currsize < 5

        if repfct > 0   #<IF2>
            # too early
            #++++++++++
            while   currtime < timestart    #<L3>
                puts    ">>>#{currtime} -> too early, waiting until #{timestart}, sleeping..."
                puts    "Press Ctrl+C to interrupt if you want to run the program anyway"
                
                begin
                    sleep   timeout                              #wait
                rescue Interrupt
                    puts "->Sleep interrupted by user. Continuing with program execution."
                    break
                end
                t           = Time.now                       #get time
                currtime    = t.strftime("%k:%M").strip      #extract HH:MM
                currtime    = "0#{currtime}"[-5,5]           #prefix 0
            end #<L3>

            # too late
            #+++++++++
            if currtime > timestop #<L3>
                puts ">>>#{currtime} -> too late, up #{timestop}, sleeping until tomorrow morning at #{timestart}"
                puts "Press Ctrl+C to interrupt if you want to run the program anyway"
                
                # Calculate time until tomorrow morning's timestart
                t_now = Time.now
                # Extract hours and minutes from timestart
                start_hour, start_min = timestart.split(':').map(&:to_i)
                
                # Create a Time object for tomorrow morning at timestart
                tomorrow = Time.new(t_now.year, t_now.month, t_now.day) + 24*60*60 # Add a day
                tomorrow = Time.new(tomorrow.year, tomorrow.month, tomorrow.day, start_hour, start_min)
                
                # Calculate seconds until tomorrow morning
                seconds_until_tomorrow = (tomorrow - t_now).to_i
                
                # Sleep in smaller increments to allow for Ctrl+C
                remaining = seconds_until_tomorrow
                chunk_size = [timeout, 300].max # Use at least 5-minute chunks
                
                begin
                    while remaining > 0
                        sleep_time = [remaining, chunk_size].min
                        sleep sleep_time
                        remaining -= sleep_time
                        
                        # Update current time for next iteration
                        t = Time.now
                        currtime = t.strftime("%k:%M").strip
                        currtime = "0#{currtime}" if currtime.size < 5
                        
                        # Check if we've reached timestart
                        break if currtime >= timestart && currtime < timestop
                    end
                rescue Interrupt
                    puts "Sleep interrupted by user. Continuing with program execution."
                    break
                end
            end #<L3>
        end #<IF2>

        # get request
        #++++++++++++
        _com.step("1A:: Fonction requested: #{repfct}")
        _com.logData("1A:: Fonction requested: #{repfct}")
        if repfct == 0  #<IF2>
            _com.step("1B:: Choice <Private> function to execute on #{current_mode}")
            #Display infos
            puts    "*****"
            puts    "Functions :"
            puts    "*"

            arrfunctions.each do |key,function|  #<L3>
                puts    "*  (#{key})  => #{function[0]} with Args: <#{function[2]}>"    if function[0].include?("*")==false
                puts    "*  (#{key})  => #{function[0]}"                                if function[0].include?("*")==true
            ###    puts    "*"
            end #<L3>

            puts    "*****"
            #get choice
            print   ">>>Enter your choice : "
            repfct  = $stdin.gets.chomp                 #get choice
            repfct  = repfct.to_i
            repfct  = repfct * 10   if repfct < 10
        else    #<IF2>
            repfct  = _funct
        end #<IF2>
        #
        if repfct > 100 #<IF2>
            case    repfct  #<SW3>
            when    120
                puts    "120-"
            when    130
                puts    "130-"
            when    140
                puts    "140-"
            when    150
                puts    "150-"
            when    151
                puts    "151-"
            when    160
                puts    "160-"
            end #<SW3>
        end #<IF2>
        #
        prog_key    = repfct.to_s
        if repfct == 0  #<IF2>
            _com.exit(program,'Exit requested by operator')
            exit 0
        elsif   repfct < 100    #<IF2>
            # Execute it
            #+++++++++++
            _com.step("1C:: Function #{repfct} - #{arrfunctions[prog_key][0]} in progress...")
            _com.logData("1C:: Function #{repfct} - #{arrfunctions[prog_key][0]} in progress...")

            prog    = "ruby #{arrfunctions[prog_key][1]}.rb #{arrfunctions[prog_key][2]}"
            _com.step("1D:: Run : #{prog}")
            _com.execProg(prog)
            ###exit 9
        end #<IF2>

        flagwait    = true
        while   flagwait    #<L2>
            # Next
            #+++++
            _com.step("3::Next function => wait #{timeloop}secs/#{timeloop/60}mins or enter your request [q, n] ")
            answer  = _com.wait(timeloop,true)
            puts    "DBG>ANSWER:#{answer}"
            if answer == 'q'
                flagloop    = false
                flagwait    = false
                repfct      = 0
            else
                _com.debug('>>>Forced loop')
                flagwait    = false
                repfct      = _funct
            end
        end #<L2>
    end #<L1>

#Exit
#****
    _com.stop(program,"Bye bye, see you soon")
    exit 0
#<EOS>
