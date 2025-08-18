#
=begin
    # =>    PrvSetTransValues
    # =>    VRP: 1-1-1 240531-2100
    # =>    Function : set some values to Transactions
    # =>        
    # =>    Parameters :
    #           P1: x -> no debug, X -> debug
    #           P2: Mode => E or L
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
comm_dir    = '/Volumes/Shares/Progs/Prod/PartCommon/'
prod_dir    = '/Volumes/Shares/Progs/Prod/PartP/'
beta_dir    = '/Volumes/Shares/Progs/Dvlps/Private/'

require "#{comm_dir}ClCommon.rb"
require "#{comm_dir}ClNotion.rb"
#
    _com = Common.new(false)
    current_dir = _com.currentDir()
require "#{current_dir}/MdPrvTables.rb"
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
    _mode       = _mode.upcase
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
#
#   Variables
#   =========
    program     = 'PrvSetTransValues'

#####Variables#####
    integr      = ''
    tr_prefix   = 'TRA'
    tr_id       = ''
    pg_id       = ''
    wk_prefix   = 'WEEK'
    wk_id       = ''
    mt_prefix   = 'MONTH'
    mt_id       = ''
    ac_prefix   = 'ACCOUNT'
    ac_id       = ''
#####Variables#####

    timeout     = 60 * 30
    timemin     = timeout/60
    timestart   = "07:15"
    currtime    = ''
    updreply    = 'N'

#   trans infos
    tra_x               = ''
    tra_name            = ''
    tra_datevalue       = ''
    tra_datestatement   = ''
    tra_amounttrans     = ''
    tra_checked         = ''
    tra_week            = ''
    tra_relweek         = ''
    tra_month           = ''
    tra_relmonth        = ''
    tra_account         = ''
    new_datestatement   = ''
    new_relweek         = ''
    new_relmonth        = ''
    new_account         = ''
    acc_cbc             = '87c21e3dbe714551b62ce081d52d4aed'    #https://www.notion.so/cssghe/CBC-Common-87c21e3dbe714551b62ce081d52d4aed?pvs=4
    acc_keyt            = '1aba4a8075404428a52ff54ce4f2ecfd'    #https://www.notion.so/cssghe/KEYT-Common-1aba4a8075404428a52ff54ce4f2ecfd?pvs=4

    wk_x                = ''

    mt_x                = ''

    ac_x                = ''

    #Notion filter & sort
    filter  = {
        'and'=> [
            {'property'=>'Type','select'=>{'equals'=>"Expense"}},
            {'or'=> [
                {'property'=>'Date statement','date'=>{'is_empty'=> true}},
                {'property'=>'relWeek','relation'=>{'is_empty'=> true}},
                {'property'=>'relMonth','relation'=>{'is_empty'=> true}},
                {'property'=>'Account','relation'=>{'is_empty'=>true}}
                ]
            }
        ]
    }
    sort    = []
#
#   Init
#   ====
#####Classes#####
    #Common class

    #Notion class instances
    _tra    = ClNotion.new()
    _month  = ClNotion.new()
    _week   = ClNotion.new()
    _acc    = ClNotion.new()
 
    #DB instance Transactions
    rc          = _tra.loadParams(_debug)           #load instance parameters
    _debug      = true                              if _debug == 'S'
    _debug      = true                              if _debug == 'Y'
    result      = PrvTables.loadTable(tr_prefix)    #extract DB Infos
    integr      = result['integr']
    tr_prefix   = result['prefix']
    tr_id       = result['id']
    _com.debug(program,"INTEGR:#{integr}", "PREFIX:#{tr_prefix}", "ID:#{tr_id}",'*',"#{_debug}")
    rc          = _tra.initNotion(integr,tr_id)             #init cycle
    response    = _tra.getDbFields(tr_id)           #extract field names
    arrfields   = response['data']                  #get fields only

    #DB instance Weeks
    rc          = _week.loadParams(_debug)          #load instance parameters
    result      = PrvTables.loadTable(wk_prefix)    #extract DB Infos
    integr      = result['integr']
    wk_prefix   = result['prefix']
    wk_id       = result['id']
    rc          = _week.initNotion(integr,wk_id)             #init cycle

    #DB instance Months
    rc          = _month.loadParams(_debug)           #load instance parameters
    result      = PrvTables.loadTable(mt_prefix)  #extract DB Infos
    integr      = result['integr']
    mt_prefix   = result['prefix']
    mt_id       = result['id']
    rc          = _month.initNotion(integr,mt_id)             #init cycle

    #DB instance Accounts
    rc          = _acc.loadParams(_debug)           #load instance parameters
    result      = PrvTables.loadTable(ac_prefix)    #extract DB infos
    integr      = result['integr']
    ac_prefix   = result['prefix']
    ac_id       = result['id']
    rc          = _acc.initNotion(integr,ac_id)             #init cycle
#####Classes#####

    _com.start(program,'Start of Script -> Set some values to each transaction')
    _com.debug("Prms::Prod: Debug:#{_debug} Mode:#{_mode} with:#{timeout} secs & Filter: #{filter}")

#    Main code
#   ==========
#
#####Loop#####
_com.debug("Loop all pages")
    hasmore = true
    while hasmore  #<L1>
        #Get blocks
        _com.debug("Read block")
        response    = _tra.getBlock(filter)         #=>{code=>,data=>,hasmore=>}
        code        = response['code']              #extract coe
        hasmore     = response['hasmore']           #extract hasmore

        if code == '200'    #<IF2>
            data        = response['data']          #extract data(block)
            #
            #loop all pages
            #++++++++++++++
            data.each do |page| #<L3>               #for each page
                _com.debug("Process Page")
                pg_id       = page['id']
#####Loop#####
                #
                #extract some property values
                #++++++++++++++++++++++++++++
                allkeys             = _tra.loadProperties(page,['Name','Date value','Date statement','Amount trans','Checked',
                                                                'Week','relWeek','Month','relMonth','Account'])
                tra_name            = allkeys['Name']
                tra_datevalue       = allkeys['Date value']
                tra_datestatement   = allkeys['Date Statement']
                tra_amounttrans     = allkeys['Amount trans']
                tra_checked         = allkeys['Checked']
                tra_week            = allkeys['Week']
                tra_relweek         = allkeys['relWeek']
                tra_month           = allkeys['Month']
                tra_relmonth        = allkeys['relMonth']
                tra_account         = allkeys['Account']
                #
                #checks
                #++++++
                _com.debug("Checks_olds:: Name:#{tra_name} - Dvalue:#{tra_datevalue} - Dstate: #{tra_datestatement} - Amount:#{tra_amounttrans} - Checked:#{tra_checked} - Week:#{tra_relweek} - Month:#{tra_relmonth}")
                if tra_checked  #<IF4>
                    #
                    #already checked
                    #+++++++++++++++
                    updreply  = 'A'                   #force to exec by menu

                    if updreply != 'A'  #<IF5>
                        print   "Can I update ? "
                        updreply    = $stdin.gets.chomp
                        updreply    = updreply.upcase
                    end #<IF5>s
                    if updreply == 'Q' #<IF5>
                        hasmore = false
                        break
                    end #<IF5>
                    if updreply == 'Y' or updreply == 'A' #<IF5>
                        #
                        #updates
                        #+++++++
                        if tra_datestatement.nil?   #<IF6>
                            currtime            = Time.now
                        ###    new_datestatement   = currtime.strftime("%Y-%m-%d").strip  #extract YYYY-MM-DD
                            new_datestatement   = tra_datevalue['start']
                        else    #<IF6>
                        end #<IF6>

                        if tra_relweek.nil? or tra_relweek == 'None'    #<IF6>
                            _com.debug("UPD:: WEEK")
                            wk_filter   = {
                                'or'    => [
                                    {'property'=> 'Reference','rich_text'=> {'contains'=> "Week-#{tra_week}"}}
                                ]
                            }
                            response    = _week.getBlock(wk_filter)
                            code        = response['code']
                            if code == '200'    #<IF7>
                                _com.debug("UPD:: Get Week ID")
                                data    = response['data']
                                data.each do |page| #<L8>
                                    new_relweek = page['id']
                                end #<L8>
                            else    #<IF7>
                                _com.debug("WEEK::Not found => #{response}")
                            end #<IF7>
                        else    #<IF6>
                            new_relweek = tra_relweek
                        end #<IF6>

                        if tra_relmonth.nil? or tra_relmonth == 'None'   #<IF6>
                            _com.debug("UPD:: MONTH")
                            mt_filter   = {
                                'or'    => [
                                    {'property'=> 'Reference','rich_text'=> {'contains'=> "Month-#{tra_month}"}}
                                ]
                            }
                            response    = _month.getBlock(mt_filter)
                            code        = response['code']
                            if code == '200'    #<IF7>
                                _com.debug("UPD:: Get Month ID")
                                data    = response['data']
                                data.each do |page| #<L8>
                                    new_relmonth = page['id']
                                end #<L8>
                            else    #<IF7>
                                _com.debug("MONTH::Not found => #{response}")
                            end #<IF7>
                        else    #<IF6>
                            new_relmonth    = tra_relmonth
                        end #<IF6>

                        if tra_account.nil? or tra_account == 'None'  #<IF6>
                            _com.step("UPD:: ACCOUNT:#{tra_name} => #{tra_account}")
                            print "CBC=> C # KEYT=> K # N for not upd ? "
                            updaccount  = $stdin.gets.chomp
                            updaccount  = updaccount.upcase
                            case updaccount #<SW7>
                            when  'C'   #<SW7>
                                acc_id  = acc_cbc
                            when  'K'   #<SW7>
                                acc_id  = acc_keyt
                            else    #<SW7>
                                acc_id  = acc_cbc
                            end #<SW7>
                        end #<IF6>

                        _com.step("UPD::NAME:#{tra_name} - DATE:#{new_datestatement} - WEEK:#{new_relweek} - MONTH:#{new_relmonth} - ACC:#{acc_id}")
    
                        body    = {}
                        body.merge!({'Date statement'=>{'date'=>{'start'=>new_datestatement}}}) if tra_datestatement.nil?
                        body.merge!({'relWeek'=>{'relation'=>[{'id'=>new_relweek}]}})
                        body.merge!({'relMonth'=>{'relation'=>[{'id'=>new_relmonth}]}})
                        body.merge!({'Account'=>{'relation'=>[{'id'=>acc_id}]}})
                        if _mode == 'E' #<IF6>
                            
                            response    = _tra.updPage(pg_id,body)
                            code        = response['code']
                            if code == '200'    #<IF7>
                                _com.debug("EXEC","ID:#{pg_id}","BODY:#{body}","CODE:#{code}",'*',true)
                            else    #<IF7>
                                _com.debug("EXEC","ID:#{pg_id}","BODY:#{body}","RC:#{rc}",'*',true)
                            end #<IF7>
                        else    #<IF6>
                            _com.debug("LOG","ID:#{pg_id}","BODY:#{body}",'*','*',true)
                        end #<IF6
                    end #<IF5>
                    #
                else    #<IF4>
                end #<IF4>
            end #<L3>
        else    #<IF2>
            hasmore = false
        end #<IF2>
    end #<L1>
    #
    _com.stop(program,"Byebye")
#
