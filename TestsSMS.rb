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
#require specific
#
#My classes
    require '/users/Gilbert/Public/Progs/Prod/PartCommon/ClDirectories.rb'

    _dir    = Directories.new('B')
    arrdirs = _dir.otherDirs('B')
    pp  arrdirs


    current_dir = Dir.pwd                               #current directory
    puts "CURRENT:#{current_dir}"
    Dir.chdir()
    user_dir  = Dir.pwd                                 #user directory
    puts "USER:#{user_dir}"
    Dir.chdir('./Public')
    public_dir  = Dir.pwd                               #public directory
    puts "PUBLIC:#{public_dir}"
    
    Dir.chdir('./Progs')
    progs_dir   = Dir.pwd                               #Progs directory
    puts "PROGS:#{progs_dir}"

    Dir.chdir('./Dvlps')
    beta_dir    = Dir.pwd                               #Beta directory
    puts "BETA:#{beta_dir}"
    Dir.chdir('./Private')
    b_private_dir = Dir.pwd                             #Private directory
    puts "BETA-PRIVATE:#{b_private_dir}"
    #Dir.chdir('..')
    Dir.chdir('../MembersV2-3')                          #Members directory
    b_members_dir = Dir.pwd
    puts "BETA-MEMBERS:#{b_members_dir}"

    Dir.chdir('../..')                                  #Progs directory
    Dir.chdir('./Prod')
    prod_dir    = Dir.pwd                               #Prod directory
    puts "PROD:#{prod_dir}"
    Dir.chdir('./PartCommon')
    p_common_dir    = Dir.pwd                           #Common directory
    puts "PROD-COMMON:#{p_common_dir}"
    #Dir.chdir('..')
    Dir.chdir('../PartP')
    p_private_dir = Dir.pwd                             #Private directory
    puts "PROD-PRIVATE:#{p_private_dir}"
    #Dir.chdir('..')
    Dir.chdir('../PartB')
    p_members_dir = Dir.pwd                             #Members directory
    puts "PROD-MEMBERS:#{p_members_dir}"

    Dir.chdir(public_dir)                               #
    Dir.chdir('./MemberLists')
    mbrlist = Dir.pwd                                   #MemberLists
    puts "MBRLISTS:#{mbrlist}"
    Dir.chdir('./ToSend')
    tosend_dir  = Dir.pwd                               #ToSend
    puts "TOSEND:#{tosend_dir}"
    Dir.chdir('../Works')
    works_dir   = Dir.pwd                               #Works
    puts "WORKS:#{works_dir}"

    xyz = Dir.pwd
    puts "XYZ:#{xyz}"

    exit 9
#Internal functions
#******************
#
#Variables
#*********
    program     = 'TestsSMS'
    counter     = 0
#
#Input parameters
#****************
    
#
#Main code
#*********
    #Initialize
    #++++++++++
    puts "Start of #{program} at #{Time.now}"
#
#Exit phase
#++++++++++
