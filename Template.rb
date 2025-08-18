#
=begin
    #Function:  extract 1 member
    #Call:      ruby ?.rb N
    #Parameters::
        #P1:    true/Y=>debug false/N=>None
        #P2:    ?
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
require 'fileutils'

#
#***** Directories management *****
# Start of block
    exec_mode   = 'B'                                   #change B or P
    require_dir = Dir.pwd                               #get current directory
    exec_mode   = 'P'       if require_dir.include?('Prod')
    common_dir  = "/users/gilbert/public/progs/prod/common/"    if exec_mode == 'P'
    common_dir  = "/users/gilbert/public/progs/dvlps/common/"   if exec_mode == 'B'
require "#{common_dir}/ClDirectories.rb"
    _dir    = Directories.new(false)
    arrdirs = _dir.otherDirs(exec_mode)                 #=>{exec,private,membres,common,send,work}
require "#{common_dir}/ClCommon_2.rb"
    _com    = Common_2.new(program,_debug,dbglevel)
    private_dir     = arrdirs['private']                #private directory
    member_dir      = arrdirs['membres']                #members directory
    work_dir        = arrdirs['work']
    send_dir        = arrdirs['send']
    download_dir    = arrdirs['idown']                  #download iCloud
# End of block
#***** Directories management *****
#

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
# End of block

# Check parameters
#*****************
# Start of block
    if _debug
        puts "Debug mode: #{_debug}"
#        puts "Member: #{_member}"
#        puts "Display mode: #{_dis}"
    end
# End of block
#
#***** Exec environment *****
# Start of block
    program     = '?'
    #Init Notion if needed
require "#{common_dir}/ClNotion_2F.rb"

# End of block
#***** Exec environment *****
#
#
# Variables
#**********
    not_key = ''
    count   = 0
#
# Internal functions
#*******************

# Main code
#**********
    # Initialize
    #+++++++++++
    # Notion class
    _not    = ClNotion_2F.new('Mbr24')                  #Members DBs familly

    _com.start(program," ")
#    _com.logData(" ")
    _com.step("1-Initialize Notion ->")
    rc  = _not.loadParams(_debug,_not)                  #load params to Notion class
    _com.step("1A-loadParams => #{rc}")
    rc  = _not.initNotion(not_key)                      #init new cycle for 1 DB
    _com.step("1B-initNotion for #{not_key} => #{rc}")

    #
    # Processing
    #+++++++++++
    _com.step("2-Processing")

    #Display counters
    #================
    _com.step("9-Counters::?:#{count}")
    _com.stop(program,"Bye bye")
#<EOS>