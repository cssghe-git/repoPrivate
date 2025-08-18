#
=begin
    # =>    PrvSndToiCloud
    # =>    VRP: 4-1-1 <250512-1827>
    # =>    Function : send new event to iCloud calendar
    # =>
    # =>    Parameters :
    #           P1: Y or N pr n
    #           P2: Mode => E or L
    #
    # =>    Process :
                - extract some properties
                - Make events :
                - if state = 'En cours'
                    - set state to 'iCloud'
                - if state = 'Récurrent'
                    - set state to 'Exécuté'
                - Checks :
                - if state = 'iCloud' AND Date < Last edited time
                    - set state to 'Terminé'
                - if state = 'Exécuté' AND Date < Last edited time
                    - set state to 'Terminé'

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
#
    require_dir = Dir.pwd
    puts    "dirREQUIREDIR:"+require_dir
require "#{require_dir}/ClDirectories.rb"
#
    exec_mode   = 'P'                                   #change B or P
    _dir    = Directories.new('N')
    arrdirs = _dir.otherDirs(exec_mode)                 #=>{exec,private,membres,common,send,work}
require "#{arrdirs['common']}/ClCommon_2.rb"
    _com    = Common_2.new(false)
#
require "#{arrdirs['common']}/ClNotion.rb"
#
    exec_dir    = arrdirs['exec']
#
#   Parameters
#   ==========
begin
    _debug  = ARGV[0]
    _mode   = ARGV[1]
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
#   Internal functions
#   ==================
    #
    def sndEvents(p_data)
        #++++++++
        #INP:   #<=[prefix,[properties]]
        #OUT:   iCal
        prefix      = p_data[0]
        recfields   = p_data[1]     #[event,from,to]
        message     = "<h3>Sorry, it's a bug. Do not use it as request</h3>"
        #
        event       = recfields[0]
        fromdate    = recfields[1]
        fromdate    = fromdate['start']
        todate      = recfields[2]
        todate      = todate['start']
        puts "iCAL: EVT: #{event} - From: #{fromdate} - To: #{todate}"
        #
        system("osascript #{exec_dir}/CreateEventCal.scpt #{fromdate} #{todate} #{event}")
        #
        return true
    end #<def>
#
#   Variables
#   =========
    program     = 'PrvSndToiCloud'
    integr      = 'secret_FIhPnoyaCFBlTWzD1Y4BBRbzEx7chTck1HkAm14uBd3'
    db_name     = 'enct.Evénements'
    db_id       = '1a072117082a80b4a8cdf069f3f319d1'    #https://www.notion.so/cssghe/1a072117082a80b4a8cdf069f3f319d1?v=1a072117082a80bbba43000c6740e61e&pvs=4
    pg_id       = ''

    timeout     = 60 * 30
    timemin     = timeout/60
    timestart   = "07:15"
    nbrloop     = 0

#   blk infos
    blk_nom     = ''
    blk_date    = ''
    blk_state   = ''
    blk_next    = 0
    blk_fromto  = ''

    #Notion filter & sort
    filter  = {
            'or'=> [
                {'property'=>'Statut','status'=>{'equals'=>'Confirmé'}},
                {'property'=>'Statut','status'=>{'equals'=>'A renouvellé'}}
            ]
    }
    sort    = [
            {'property'=> 'Titre','direction'=>'ascending'}
    ]
#
#   Init
#   ====
    #Notion class
    _not    = ClNotion.new()
    rc      = _not.loadParams(_debug)

    _com.start(program,'Start of Script -> Send new event to iCloud calendar')
    _com.debug("Prms::Prod: Debug:#{_debug}/#{_dbgflag}/#{_dbglvl} Mode:#{_mode} with:#{timeout} secs & Filter: #{filter}")

    t           = Time.now                              #get time
    currtime    = t.strftime("%Y-%m-%dT%H:%M").strip    #extract YYYY-MM-DD
    t2          = Time.now.utc                          #get tile UTC zone
    currtime2   = t2.strftime("%Y-%m-%dT%H:%M").strip   #extract YYYY-MM-DD
    _com.step("Times:: #{currtime} - #{currtime2}")

#    Main code
#   ==========
#
    #####Loop#####
    _com.debug("Init new cycle",'*','*','*','*',_dbgflag)
    rc  = _not.initNotion(integr,db_id)             #init cycle
    hasmore = true
    _com.debug("Loop blocks of pages",'*','*','*','*',_dbgflag)
    while hasmore  #<L1>
        #Get blocks
        _com.debug("Read block",'*','*','*','*',_dbgflag)
        response    = _not.getBlock(filter)         #=>{code=>,data=>,hasmore=>}
        code        = response['code']              #extract coe
        hasmore     = response['hasmore']           #extract hasmore
        ###pp  response

        if code == '200'    #<IF2>
            _com.debug("Pages to process",'*','*','*','*',_dbgflag)
            data        = response['data']          #extract data(block)
            #
            #loop all pages
            #++++++++++++++
            _com.debug("Loop all pages",'*','*','*','*',_dbgflag)
            data.each do |page| #<L3>                   #for each page
                ###    pp  page
                pg_id       = page['id']
                #
                #extract some properties
                #+++++++++++++++++++++++
                _com.debug("Extract fields",'*','*','*','*',_dbgflag)
                properties  = _not.allProperties(page)  #extract all properties
                blk_nom     = _not.extrProperty('Titre')
                blk_state   = _not.extrProperty('Statut')
                blk_tkw     = _not.extrProperty('TKW')
                blk_dateS   = _not.extrProperty('Date de début')
                blk_dateE   = _not.extrProperty('Date de fin')
                blk_dateS2  = _not.extrProperty('Date de début svte')
                blk_dateE2  = _not.extrProperty('Date de fin svte')
                checktime   = currtime
                #log
                blk_nomx    = blk_nom.ljust(20,"*")
                params      = ['BLK',[blk_nom,blk_dateS,blk_dateE]]
                params2     = ['BLK',[blk_nom,blk_dateS2,blk_dateE2]]
                #
                #make event
                #++++++++++
                if blk_state == "Confirmé"  #<IF4>
                    _com.debug("Processing state <En cours>",'*','*','*','*',_dbgflag)
                    _com.step("REC::Confirmé => #{params}")
                    if _mode == 'E' #<IF5>
                        #send event
                        #----------
                        _com.step("Create iCloud event => #{params}")
                        sndEvents(params)
                        #update record
                        #-------------
                        newstate    = "iCloud"
                        blk_upd     = {'Statut' => {'status'=>{'name'=>newstate}}}
                        _com.step("UPD::#{params}-#{newstate}")
                        _not.updPage(pg_id, blk_upd)
                    else    #<IF5>
                        _com.step("LOG::#{params}")
                    end #<IF5>

                elsif blk_state == "A renouvellé"   #<IF4>
                    _com.debug("Processing state <En cours>")
                    _com.step("REC::Renouvellé => #{params}")
                    if _mode == 'E' #<IF5>
                        #send event
                        #----------
                        _com.step("Create iCloud event => #{params}")
                        sndEvents(params2)
                        #update record
                        #-------------
                        newstate    = "iCloud"
                        blk_upd     = {
                            'Statut'        => {'status'=>{'name'=>newstate}},
                            'Date de début' => {'date'=>{'start'=>blk_dateS2}},
                            'Date de fin'   => {'date'=>{'start'=>blk_dateE2}}
                        }
                        _com.step("UPD::#{params2}-#{newstate}")
                        _not.updPage(pg_id, blk_upd)
                    else    #<IF5>
                        _com.step("LOG::#{params2}")
                    end #<IF5>
                end #<IF4>
            end #<L3>
        else    #<IF2>
            hasmore = false
        end #<IF2>
    end #<L1>
    #
    _com.stop(program,"Byebye")
#
