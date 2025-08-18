#
=begin
    #   Define infos for all private DBs
    #   VRP: 1-1-1 <> <
=end

module PrvTables_week
#====================
#
#   Variables
#   +++++++++
    @tables  = {
        'WEEK'  => {
            'prefix'        => 'WEEK',
            'name'          => 'Sprocket.Weeks',
            'id'            => '05b82c18a3744633be75e67e6fc6bc08',
            'integr'        => 'secret_FIhPnoyaCFBlTWzD1Y4BBRbzEx7chTck1HkAm14uBd3',
            'properties'    => [
                'Name','Week','Amount exp','Amount sub','Amount week','Total weeks','Weekly mean','Transactions',
                'Week-99','Weeks','Reference','Dates'
            ],
            'filter'        => {},
            'sort'          => {},
            'url'           => 'https://www.notion.so/cssghe/05b82c18a3744633be75e67e6fc6bc08?v=d5e80c4dcc2146a6b0c6d13c57471e97&pvs=4'
        }
    }

#
#   Functions
#   +++++++++
    #Return infos to caller
    def PrvTables_week.loadTable(p_table='WEEK')
    #+++++++++++++++++++++++++++
        #INP::  p_table: prefix
        #OUT::  {pref=>,name=>,id=>,properties=>,filter=>,sort=>,url=>,}
        #
        return  @tables[p_table]
    end #<def>
    #
    #
end #<Mod>
