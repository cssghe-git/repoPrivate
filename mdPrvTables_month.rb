#
=begin
    #   Define infos for all private DBs
    #   VRP: 1-1-1 <> <
=end

module PrvTables_month
#=====================
#
#   Variables
#   +++++++++
    @tables  = {
        'MONTH'  => {
            'prefix'        => 'MONTH',
            'name'          => 'Sprocket.Months',
            'id'            => '1677d3cabb2b416fb0482c3ebf641d00',
            'integr'        => 'secret_FIhPnoyaCFBlTWzD1Y4BBRbzEx7chTck1HkAm14uBd3',
            'properties'    => [
                'Name','Month','Amount trans','Amount exp','Amount sub','Amount month','Total months',
                'Monthly mean','Transactions','Month-99','Months','Dates','Reste','Reference'
            ],
            'filter'        => {},
            'sort'          => {},
            'url'           => 'https://www.notion.so/cssghe/1677d3cabb2b416fb0482c3ebf641d00?v=746eeaf10369413d9fc9502c68c63c4c&pvs=4'
        }
    }
#
#   Functions
#   +++++++++
    #Return infos to caller
    def PrvTables_month.loadTable(p_table='MONTH')
    #++++++++++++++++++++++++++++
        #INP::  p_table: prefix
        #OUT::  {pref=>,name=>,id=>,properties=>,filter=>,sort=>,url=>,}
        #
        return  @tables[p_table]
    end #<def>
    #
    #
end #<Mod>
