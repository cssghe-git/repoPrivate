#
=begin
=end
#Require
#*******
#require gems
require 'rubygems'
require 'timeout'
require 'time'
require 'date'
require 'uri'
require 'json'
require 'csv'
require 'pp'
#
#***** Directories management *****
# Start of block
    require_dir = Dir.pwd
    Dir.chdir("../Common/")             #change to Dvlps/Common directory
    require_dir = Dir.pwd               #
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

# Check parameters
#*****************

#
#***** Exec environment *****
# Start of block
    program = 'TestsUpload'
    exec_mode   = 'B'                                   #change B or P
    dbglevel    = 'DEBUG'
    arrdirs = _dir.otherDirs(exec_mode)                 #=>{exec,private,membres,common,send,work}
    #   pp arrdirs
    private_dir = arrdirs['private']
    member_dir   = arrdirs['membres']                   #members directory
    common_dir   = arrdirs['common']                    #common directory
    work_dir    = arrdirs['work']
    send_dir    = arrdirs['send']
require "#{common_dir}/ClCommon_2.rb"
    _com    = Common_2.new(program,_debug,dbglevel)
require "#{common_dir}/ClNotion_2F.rb"
# End of block
#***** Exec environment *****
#

#
#Internal functions
#******************
#
#Variables
#*********
    dbglevel    = "DEBUG"
    count       = 0
    not_key     = 'filesupload'

    body_add    = ''
    result      = ''
    pag_id      = ''

    file_name_def   = 'TestsUpload.txt'
    file_id         = ''
    file_size       = ''
    file_data       = ''
    file_type       = ''
    file_tags       = ''
    file_name       = ''
    file_path       = ''
#
#Main code
#*********
    #Initialize
    #++++++++++
    _com.start("Start of #{program} at #{Time.now}")

    # Init Notion handle
    _not = ClNotion_2F.new("Private")
    rc   = _not.loadParams(_debug,_not)
    _com.step("1A-Notion load parameters: #{rc}")
    rc   = _not.initNotion(not_key)
    _com.step("1B-Notion init cycle: #{rc}")

    # Get file parameters
    _com.step("2A-Get File parameters")
    print "Enter file name to upload (default: #{file_name_def}): "
    file_name = $stdin.gets.chomp.strip
    file_name = file_name_def   if file_name.empty?
    file_path = "#{work_dir}/#{file_name}" unless file_name.start_with?('/') || file_name.start_with?('\\')
    if File.exist?(file_path)
        stat        = File.stat(file_path)
        file_size   = stat.size.to_s
        file_data   = File.read(file_path)
        file_type   = File.extname(file_path).delete('.').downcase
    else
        _com.exit("File '#{file_path}' does not exist. Please create it before running this script.")
        exit 1
    end
    _com.step   ("2B-File name: #{file_name}, File size: #{file_size}, File type: #{file_type}")
    print "Enter file tags (separated by ','): "
    file_tags = $stdin.gets.chomp.strip
    file_tags = 'Default' if file_tags.empty?
    file_tags = file_tags.split(',').map(&:strip) unless file_tags.empty?
    _com.step   ("2C-File tags: #{file_tags.join(', ')}")

    # Create a new page with file parameters
    _com.step("3A-Create new page on DB FilesUpload")
    body_add    = {
        'Reference' => {'title' => [{'text' => {'content' => file_name}}]},
        'FileName'  => {'rich_text' => [{'text' => {'content' => file_path}}]},
        'Tags'      => {'multi_select' => file_tags.map { |tag| {'name' => tag} }},
        'Type'      => {'select' => {'name' => file_type}},
        'FileSize'  => {'number' => file_size.to_i}
    }
    result  = _not.addPage('', body_add)
    not_code    = result['code']
    pagid       = result['id']
    _com.step("Notion add page result: #{not_code}")

    # Upload file to Notion
    _com.step("4A-Upload file to Notion & attach to page")
    file_id = _not.upLoadFile(pagid, file_path, file_data, file_size.to_i)
    _com.step("4B-Upload file result: #{rc}")

#
#Exit phase
#++++++++++
    _com.exit(program,"End of #{program} at #{Time.now}")