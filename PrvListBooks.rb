#
=begin
    #Program:   PrvListBooks
    #Build:     01-01-01   <250625-1530>
    #Function:  print author's books
    #Call:      ruby PrvListBooks.rb N
    #Folder:    Public/Progs/.
    #Parameters::
        #P1:    Y/true or N/false
        #P2:    
        #P3:    
    #Actions:
        #Create date: 20250625 with Build: 01.01.01
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
    exec_mode   = 'B'                                   #change B or P
    require_dir = Dir.pwd
    common_dir  = "/users/gilbert/public/progs/prod/common/"    if exec_mode == 'P'
    common_dir  = "/users/gilbert/public/progs/dvlps/common/"    if exec_mode == 'B'
require "#{common_dir}/ClDirectories.rb"
    _dir    = Directories.new(false)
    arrdirs = _dir.otherDirs(exec_mode)                 #=>{exec,private,membres,common,send,work}
# End of block
#***** Directories management *****
#
# Input parameters
#*****************
# Start of block
begin
    _debug  = ARGV[0]
    _member = ARGV[1]
    _dis    = ARGV[2]
rescue
    _debug  = false
    _member = 'None'
    _dis    = 'F'
end
    _debug  = true if _debug == 'Y'
    _debug  = false if _debug == 'N'

###    _debug = true

# End of block

# Check parameters
#*****************
# Start of block
    if _debug
        puts "Debug mode: #{_debug}"
    end
# End of block
#
#***** Exec environment *****
# Start of block
    program     = 'PrvListBooks'
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
    not_key     = 'livres'
    count       = 0
    count_sel   = 0
    filepflog   = "#{send_dir}/AuthorsBooksList.pdf"
    auteur_old  = ''

    #pdf
    header  = "
                <head>
                    <style>
                        h1 {color:green;}
                        h2 {color:black;}
                        h3 {color:black}
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
    @content.concat("<caption><h1>Author's books</h1></caption>")
    @content.concat("<tr><th>Author</th><th>Title</th><th>Score</th></tr>")

#
# Internal functions
#*******************

# Main code
#**********
    # Initialize
    #+++++++++++
    # Notion class
    _not    = ClNotion_2F.new('Private')                #new instance for private DBs familly

    _com.start(program,"Start for Author's books list")
    _com.step("1-Initialize>")
    rc  = _not.loadParams(_debug,_not)                  #load params to Notion class
    _com.step("1A-loadParams => #{rc}")
    rc  = _not.initNotion(not_key)                      #init new cycle for 1 DB
    _com.step("1B-initNotion for #{not_key}=> #{rc}")
    #
    # Processing
    #+++++++++++

    _com.step("2-Processing with properties :: Debug:#{_debug}")
    _com.step("2A-Get not Fields")
    result  = _not.getDbFields()                        #get DB fields
    not_fields  = result['data']                        #{code=>,fields=>[]}
    _com.debug("2B-Fields: #{not_fields}")

    _com.step("3-Yield block")
    not_filter  = {
        'and'=> [
            {'property'=> 'Status', 'status'=>{'equals'=>"Terminé"}}
        ]
    }
    not_sort    = [
            {'property'=> 'Auteur', 'direction'=> 'ascending'},
            {'property'=> 'Reference', 'direction'=> 'ascending'}
    ]
    fields  = ['ALL']                                   #array of fields requested or ALL, or ALL

    _not.runPages(not_filter,not_sort,fields) do |code,data|    #execute bloc on Notion class with filter, sort & properties
                                                        #data => result function => all properties {field=>value,...}
        count   += 1

        if code == true and !data.nil?  #<IF2>
            properties  = _not.loadProperties(data,fields)

            auteur  = properties['Auteur']              #extract Auteur
            next if auteur.nil? or auteur.size == 0 or auteur == ''
            _com.debug("4A-REF:#{auteur}")

            titre   = properties['Reference']            #extract Reference(Titre)
            next if titre.nil? or titre.size == 0 or titre == ''

            stats   = properties['Stats']

            puts "<br>Auteur  => #{auteur} : #{titre} - #{stats}<br>"

            if auteur != auteur_old #<IF3>
                @content.concat("<tr>")
                @content.concat("<td><h2>#{auteur}</h2></td>")
                @content.concat("<td><h3>#{titre}</h3></td>")
                @content.concat("<td><h3>#{stats}</h3></td>")
                @content.concat("</tr>")
                auteur_old  = auteur
                count_sel   += 1
            else    #<IF3>
                @content.concat("<tr>")
                @content.concat("<td><h2>***</h2></td>")
                @content.concat("<td><h3>#{titre}</h3></td>")
                @content.concat("<td><h3>***</h3></td>")
                @content.concat("</tr>")
            end #<IF3>
        end #<IF2>
    end #<L1>
    @content.concat("</table>")                         #close html table

    #Create pdf
    #++++++++++
        _com.step("5-Create pdf")
        @content.concat("<br><br>*****End*****<br>")
        body    = "<body> #{@content} </body>"
        html    = "#{header} #{body}"
        _pdf    = PDFKit.new(html, :orientation => 'Portrait')
        _pdf.to_file(filepflog)

    #Display counters
    #================
    _com.step("6-Counters::Authors:#{count_sel} / #{count}")
    _com.stop(program,"Bye bye")
#<EOS>