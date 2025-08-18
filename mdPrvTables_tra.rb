#
=begin
    #   Define infos for all private DBs
    #   VRP: 1-1-1 <> <
=end

module PrvTables_tra
#===================
#
#   Variables
#   +++++++++
    @tables  = {
        'TRA'   => {
            'prefix'        => 'TRA',
            'name'          => 'Sprocket.Transactions',
            'id'            => '9954848211e14d17b6c33617efd933d0',
            'integr'        => 'secret_FIhPnoyaCFBlTWzD1Y4BBRbzEx7chTck1HkAm14uBd3',
            'properties'    => [
                'Name', 'Date trans', 'Date value', 'Date statement', 'amount trans', 'amount sub', 'amount exp',
                'Checked', 'Subscription', 'Category', 'Week', 'relWeek', 'Month', 'relMonth', 'processed',
                'Attachments', 'Account', 'This Month', 'Next Month', 'This Year', 'Next Year'
            ],
            'filter'        => {},
            'sort'          => {},
            'url'           => 'https://www.notion.so/cssghe/9954848211e14d17b6c33617efd933d0?v=94ac54e6d97c4ee19fd90a223f05ee82&pvs=4'
        }
       }
    }
#
#   Functions
#   +++++++++
    #Return infos to caller
    def PrvTables_tra.loadTable(p_table='TRA')
    #++++++++++++++++++++++++++
        #INP::  p_table: prefix
        #OUT::  {pref=>,name=>,id=>,properties=>,filter=>,sort=>,url=>}
        #
        return  @tables[p_table]
    end #<def>
    #
    #
end #<Mod>
