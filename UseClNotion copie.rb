#
=begin
    #Function:  template for use of ClNotion_Tests
    #Call:      ruby UseClNotion.rb N
    #Parameters::
        #P1:    argv: R=>request D=>default Y=>debug
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
#require specific
common_dir  = '~/pCloudSync/Progs/Prod/PartCommon/'
private_dir = '~/pCloudSync/Progs/Dvlps/Private/'
beta_dir    = '~/pCloudSync/Progs/Dvlps/Private/'

require "#{beta_dir}ClCommon_2.rb"
require "#{beta_dir}ClNotion_2.rb"

#
#
# Input parameters
#*****************
    _debug  = 'N'

# Variables
#**********
    program = 'Tests'
    #membres_v24 => mbr_
    mbr_key     = 'membres_v24'                         #DB key
    mbr_fields  = []                                    #DB fields
    #requests
    req_fields  = [                                     #array of fields requested, or ALL
        'Référence','CDC','ActivitéP','ActivitéS',
        'EnCours','Statut','Etat'
    ] 
    #   req_fields  = ['ALL']
    #
    infos   = {}
    count   = 0

#
# Internal functions
#*******************

# Main code
#**********
    # Initialize
    #+++++++++++
    # Common class
    _com    = Common_2.new(program,false)

    # Notion class
    _not    = ClNotion_2.new('Mbr24')                   #mbr24 DBs familly

    puts    "DBG>>Init>"
    rc  = _not.loadParams('N',_not)                     #load params to Notion class
    puts    "DBG>>loadParams => #{rc}"
    rc  = _not.initNotion(mbr_key)                      #init new cycle for 1 DB
    puts    "DBG>>initNotion for #{mbr_key}=> #{rc}"

    #
    # Processing
    #+++++++++++

    puts    "DBG>>Processings"
    puts    "DBG>>Get MBR Fields"
    result  = _not.getDbFields()
    mbr_fields  = result['data']
    pp result

    #   puts    "DBG>Search Title"
    #   result  = _not.schTitle('database','')
    #   code    = result['code']
    #   id      = result['ID']
    #   data    = result['result']
    #   pp result

    #   exit 9

    puts    "DBG>>Yield block"
    mbr_filter  = {
        'and'=> [
            {'property'=> 'EnCours', 'checkbox'=>{'equals'=>true}},
            {'property'=> 'AllActs', 'formula'=> {'string'=> {'contains'=> "NIV-Pilates"}}}
        ]
    }
    mbr_sort    = [
        {'property'=> 'Référence', 'direction'=> 'ascending'}
    ]
    fields  = ['Référence','CDC','ActivitéP','ActivitéS','EnCours','Statut','Etat'] #array of fields requested, or ALL
    #   fields  = ['ALL']

    _not.runDb(mbr_filter,mbr_sort,fields) do |data|            #execute bloc on Notion class with filter, sort & properties
                                                        #data => result function
        count   += 1
        ### pp  data

    #    print "   =>"
    #    print   data['CDC']
    #    print " "
    #    print   data['Référence']
    #    puts " "

        print "   =>"
        data.each do |prop|                             #loop all properties
            #pp  prop
            name    = prop[0]                           #extract name
            value   = prop[1]                           #extract value
            case    name
            when    'CDC'
                print   value
                print   " "
            when    'Référence'
                print   value
                print   " "
            when    'ActivitéP'
                print   value
                print   " "
            when    'ActivitéS'
                print   value
                print   " "
            when    'EnCours'
                print   value
            end
        end
        puts " "
    end

    puts    "DBG>>End"
    puts    "DBG>>Count: #{count} recs"
