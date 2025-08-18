#
=begin
    #Program:   PrvMakeCalendar
    #Build:     01-01-01   <250602-2025>
    #Function:  print calendar for 1 month
    #Call:      ruby PrvMakeCalendar.rb N
    #Folder:    Public/Progs/.
    #Parameters::
        #P1:    Y/true or N/false
        #P2:    
        #P3:    
    #Actions:
        #Create date: 20250602 with Build: 01.01.01
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
rescue
    _debug  = false
end
    _debug  = true if _debug == 'Y'
    _debug  = false if _debug == 'N'

    ###_debug = true   #forcet to tests

# Check parameters
#*****************
    if _debug
        puts "Debug mode: #{_debug}"
    end
    _dis    = 'R'
    _dis    = 'F'

#
#***** Exec environment *****
# Start of block
    program = 'PrvMakeCalendar'
    exec_mode   = 'P'                                   #change B or P
    dbglevel    = 'DEBUG'
    arrdirs = _dir.otherDirs(exec_mode)                 #=>{exec,private,membres,common,send,work}
require "#{arrdirs['common']}/ClCommon_2.rb"
    _com    = Common_2.new(program,_debug,dbglevel)     #new instance
    private_dir = arrdirs['private']                    #private directory
    member_dir   = arrdirs['membres']                   #members directory
    common_dir   = arrdirs['common']                    #common directory
    work_dir    = arrdirs['work']                       #work directory
    send_dir    = arrdirs['send']                       #to send directory
require "#{arrdirs['common']}/ClNotion_2F.rb"
# End of block
#***** Exec environment *****
#

# Variables
#**********
    evt_key     = 'evenements'                          #DB key
    evt_fields  = []                                    #DB fields
    #requests
    req_fields  = [                                     #array of fields requested, or ALL
        'ALL'
    ] 
    #
    infos   = {}
    count       = 0
    count_sel   = 0

    #pdf
    header  = "
                <head>
                    <style>
                        h1 {color:green;}
                        h2 {color:blue;}
                        h3 {color:orange}
                        h4 {color:pink}
                        div {height:400px;width:100%;background_color:blue}
                        body {text-align:left; color:black;}
                    </style>
                    <style>
                        table {
                            border-collapse: collapse; /* Évite la double bordure */
                            width: 100%;
                        }
                        th, td {
                            border: 1px solid #000; /* Bordure autour des cellules */
                            padding: 8px;
                            text-align: center;
                        }
                        th {
                            background-color: #f2f2f2; /* Couleur de fond pour l'en-tête */
                        }
                    </style>
                </head>
    "
    body    = ''
    @content    = "*****Start*****<br>"
    @content.concat("<table>")

#
# Internal functions
#*******************

# Main code
#**********
    # Initialize
    #+++++++++++
    # Notion class
    _evt    = ClNotion_2F.new('Private')                #new instance for private DBs familly

    _com.start(program,"Start for Calendar")
    _com.logData(" Start for Calendar")
    _com.step("1-Initialize>")
    rc  = _evt.loadParams(_debug,_evt)                  #load params to Notion class
    _com.step("1A-loadParams => #{rc}")
    rc  = _evt.initNotion(evt_key)                      #init new cycle for 1 DB
    _com.step("1B-initNotion for #{evt_key}=> #{rc}")

    # Get month to check
    #+++++++++++++++++++
    print   "Enter the month (nn) : "
    month       = $stdin.gets.chomp.to_s
    #make file
    filepflog   = "#{send_dir}/Calendar_#{month}.pdf"
    @content.concat("<caption><h1>Calendrier : #{month}</h1></caption>")
    @content.concat("<tr><th>Titre</th><th>Catégorie</th><th>Type</th><th>Date</th><th>Description</th><th>Tierce partie</th></tr>")
    #
    # Processing
    #+++++++++++

    _com.step("2-Processing with properties :: Debug:#{_debug}")
    _com.step("2A-Get evt Fields")
    result  = _evt.getDbFields()                        #get DB fields
    evt_fields  = result['data']                        #{code=>,fields=>[]}
    _com.debug("2B-Fields: #{evt_fields}")

    _com.step("3-Yield block")
    evt_filter  = {
        'and'=> [
            {'property'=> 'Status', 'status'=>{'equals'=>"Confirmed"}}
        ]
    }
    evt_sort    = [
        {'property'=> 'Dates', 'direction'=> 'ascending'}
    ]
    fields  = ['ALL']                                   #array of fields requested or ALL, or ALL

    _evt.runPages(evt_filter,evt_sort,fields) do |code,data|    #execute bloc on Notion class with filter, sort & properties
                                                        #data => result function => all properties {field=>value,...}
        count   += 1

        if code == true and !data.nil?  #<IF2>
            properties  = _evt.loadProperties(data,fields)

            titre       = properties['Reference']       #extract Title
            _com.step("4A-REF:#{titre}")

            if !properties['Dates']['start'].nil?
                date_start1 = properties['Dates']['start'][0,16]   #extract Date
                date_start  = "Le "+date_start1[8,2].to_s+ " à "+date_start1[11,5].to_s
                date_end   = properties['Dates']['end'].to_s if !properties['Dates']['end'].nil?
            else
                next
            end
            description = properties['Text']            #extract Description
            description = ""    if description == 'None'
            next if !date_start1.include?("-#{month}-") #next if not this month

            count_sel   += 1
            if _dis.include?('R')    #<IF3>
                @content.concat("<br>Titre => #{titre}<br>")
                properties.each do |prop| #<L4>         #loop all properties
                    name    = prop[0]                   #extract name
                    value   = prop[1]                   #extract value
                    if name != "Reference"  #<IF5>
                        _com.step("4B-FIELD:#{name} => #{value}")
                        @content.concat("<br>#{name} => #{value}<br>")
                    end #<IF5>
                end #<L4>
            elsif _dis.include?('F') #<IF3>
                puts "<br>Titre             => #{properties['Reference']}<br>"
                puts "<br>Catégorie         => #{properties['Category']}<br>"
                puts "<br>Type              => #{properties['Type']}<br>"
                puts "<br>Date              => #{properties['Dates']}<br>"
                puts "<br>Description       => #{properties['Text']}<br>"
                puts "<br>Tierce partie     => #{properties['Third Party']}<br>"

                @content.concat("<tr>")
                @content.concat("<td><h1>#{properties['Reference']}</h1></td>")
                @content.concat("<td><h1>#{properties['Category']}</h1></td>")
                @content.concat("<td><h1>#{properties['Type']}</h1></td>")
                @content.concat("<td><h1>#{date_start}</h1></td>")
                @content.concat("<td><h1>#{description}</h1></td>")
                @content.concat("<td><h1>#{properties['Third Party']}</h1></td>")
                @content.concat("</tr>")
            end #<IF3>
        end #<IF2>
    end #<L1>
    @content.concat("</table>")                         #close html table

    #Create pdf
    #++++++++++
    if _dis == 'F'
        _com.step("5-Create pdf")
        @content.concat("<br><br>*****End*****<br>")
        body    = "<body> #{@content} </body>"
        html    = "#{header} #{body}"
        _pdf    = PDFKit.new(html, :orientation => 'Landscape')
        _pdf.to_file(filepflog)
    end

    #Display counters
    #================
    _com.step("6-Counters::Events:#{count_sel} / #{count}")
    _com.stop(program,"Bye bye")
#<EOS>