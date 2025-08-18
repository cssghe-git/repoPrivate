#
=begin
    # =>    PrvAddRecs
    # =>    VRP: 1-1-1 250425 19:00
    # =>    Function : add records to any private DB
    # =>        
    # =>    Parameters :
    #           P1: Y or N
    #           P2: Mode => E or L
    #           P3: None
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

require "#{comm_dir}ClCommon_2.rb"
require "#{comm_dir}ClNotion_2.rb"
#
    _com = Common_2.new(false)
    current_dir     = _com.currentDir()
    others_dir      = _com.otherDirs()
    downloads_dir   = others_dir['downloads']
#
#   Parameters
#   ==========
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
#   Internal functions
#   ==================
    #
#   Variables
#   =========
    program     = 'PrvAddRecs'

#   BD infos
    #Auteurs => aut_
    aut_key     = 'auteurs'                             #Aut key
    aut_fields  = []                                    #Aut fields
    aut_filter  = {}
    aut_sort    = []
    aut_id      = ''
    aut_nom     = ''
    #livres => liv_
    liv_key     = 'livres'                              #Liv key
    liv_fields  = []                                    #Liv fields
    liv_filter  = {}
    liv_sort    = []
    liv_id      = ''
    liv_ref     = ''

    #requests
    req_fields  = [                                     #array of fields requested, or ALL
    'ALL'
] 

#
#   Init
#   ====
    _com.step("1-Initialize>")
    #Common class

    #Notion class

    _com.start(program,'Start of Script -> Add pages to DB')
    _com.step("Prms::Prod: Debug:#{_debug}/#{_dbgflag}/#{_dbglvl} Mode:#{_mode}")

#    Main code
#   ==========
#
    _com.step("2-Get parameters")
    # Get DB
    print   "Enter the DB ref [L=>Livres,] : "
    repdb   = $stdin.gets.chomp.upcase
    # Init instances
    case    repdb   #sw1>
    when    'L' #<SW1>
        #enct.Auteurs => aut_
        _aut    = ClNotion_2.new('private')
        rc      = _aut.loadParams('N',_aut)
        rc      = _aut.initNotion(aut_key)                  #init cycle
        #enct.Livres => _liv
        _liv    = ClNotion_2.new('private')
        rc      = _liv.loadParams('N',_liv)
        rc      = _liv.initNotion(liv_key)                  #init cycle
    end #<SW1>

    # Dispatch
    case    repdb   #<SW1>
    when    'L' #<SW1>
        while true  #<L1>
            _com.step("3-Process books for 1 author")
            # get author infos
            print   "Enter the author : "
            repaut  = $stdin.gets.chomp
            break   if repaut.nil? or repaut.size == 0  #exit if no more author
            
            # check if exists
            aut_filter  = {
                'and'=> [
                    {'property'=> 'Nom', 'title'=>{'contains'=>repaut}}
                ]
            }
            aut_sort    = [
                {'property'=> 'Nom', 'direction'=> 'ascending'}
            ]
            fields  = ['ALL']                               #all fields
            rc      = _aut.initNotion(aut_key)                  #init cycle
            _aut.runPages(aut_filter,aut_sort,fields) do |data|    #execute bloc on Notion class with filter, sort & properties
                #data => result function => page
                #   pp  data
                infos   = data['properties']                #extract properties part
                break   if infos.nil? or infos.size == 0       #if author does not exist

                aut_id  = data['id']                        #extract page ID
                properties  = _aut.loadProperties(data,fields)  #extract all properties
        
                aut_nom = properties['Nom']                 #extract title
                _com.step("4A-REF:#{aut_nom} - #{aut_id}")
            end #<do>

            # get books to add
            while   true    #<L2>
                print   "Enter the book name [ret=>exit] : "
                repliv  = $stdin.gets.chomp
                break   if repliv.nil? or repliv.size == 0  #exit if no more book

                # check if exists
                liv_filter  = {
                    'and'=> [
                        {'property'=> 'Reference', 'title'=>{'contains'=>repliv}}
                    ]
                }
                liv_sort    = [
                    {'property'=> 'Reference', 'direction'=> 'ascending'}
                ]
                fields  = ['ALL']                           #all fields
                rc      = _liv.initNotion(liv_key)          #init cycle
                _liv.runPages(liv_filter,liv_sort,fields) do |data|    #execute bloc on Notion class with filter, sort & properties
                    #data => result function => page
                    #   pp  data
                    infos   = data['properties']            #extract data part
                    if  infos.nil? or infos.size == 0  #<IF3>   #book does not exist
                        liv_ref     = repliv
                        liv_body    = {
                            'Reference'=> { 'title'=> [{'text'=> {'content'=> repliv}}]},
                            'Status'=> {'status'=> {'name'=> "En réflexion"}},
                            'rlbAuteursPossibles'=> {'relation'=>[
                                                        {'id'=>aut_id}]}
                        }
                        if _mode == 'E' #<IF4>
                            result  = _liv.addPage('',liv_body)
                            code    = result['code']
                            _com.step("4B-ADD:#{liv_ref} with code:#{code}")
                        else    #<IF4>
                            _com.step("4B-LOG:#{liv_ref}")
                        end #<IF4>
                    else    #<IF3>
                        liv_id  = data['id']                            #page ID
                        properties  = _liv.loadProperties(data,fields)  #extract all properties
                        liv_ref     = properties['Reference']           #extract title
                        _com.step("4B-REF:#{liv_ref} - #{liv_id}")
                    end #<IF3>
                    break
                end #<do>
            end #<L2>
        end #<L1>
        
    else    #<SW1>
        _com.exit(program,"(2):No yet in use")
        exit    2
    end #<SW1>
#
    _com.stop(program,"(0):Byebye")
#