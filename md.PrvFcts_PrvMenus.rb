#
=begin
    Goals:  contains functions for the main menu
    Author: Ghe
    VRP:    1.1.0
    Buid:   250818-0831
    Logs:
        ?
        2502818-0831    create module
=end
#
module PrvFcts_PrvMenus
#**********************
#
# Variables
# =========
#
    values  = {
        'program'   => 'PrvMenus',
        'functions' => arrfunctions
    }
    arrfunctions    = {
        '01'  => ["*","**","***"],
        '10'  => ["Send events to iCloud","#{private_dir}/PrvSndToiCloud4","N L"],
        '11'  => ["Send events to iCloud","#{private_dir}/PrvSndToiCloud4","N E"],
        '20'  => ["PrvLoadStatements_CBC","#{private_dir}/PrvLoadStatements_CBC4","N L"],
        '21'  => ["PrvLoadStatements_CBC","#{private_dir}/PrvLoadStatements_CBC4","N E"],
        '22'  => ["PrvLoadStatements_MC","#{private_dir}/PrvLoadStatements_MC4","N L"],
        '23'  => ["PrvLoadStatements_MC","#{private_dir}/PrvLoadStatements_MC4","N E"],
        '24'  => ["PrvLoadStatements_Visa","#{private_dir}/PrvLoadStatements_Visa4","N L"],
        '25'  => ["PrvLoadStatements_Visa","#{private_dir}/PrvLoadStatements_Visa4","N E"],
        '50'  => ["PrvMakeWeekReport","#{private_dir}/PrvMakeWeekReport","N E"],
        '60'  => ["PrvUpload-File","#{private_dir}/PrvUpload_File","N L"],
        '61'  => ["PrvUpload_File","#{private_dir}/PrvUpload_File","N E"],
        '62'  => ["PrvUpload-Media","#{private_dir}/PrvUpload_Media","N E"],
        '70'  => ["PrvMakeCalendar","#{private_dir}/PrvMakeCalendar","N"],
        '02'  => ["*","**","***"]
    }
#
# Functions
# =========
#
    def self.loadFunctions()
    #++++++++++++++++++++++
    #   INP:    ?
    #   OUT:    hash table values
    #
        return values
        
    end <def>