#
=begin
    #   Define infos for all private DBs
    #   VRP: 1-1-1 <> <
=end

module PrvTables_mbr2
#====================
#
#   Variables
#   +++++++++
    @tables  = {
        'MBR2'   => {
            'prefix'        => 'MBR2',
            'name'          => 'Mbr2.Membres_NIV',
            'id'            => '96313b72db5542cbac572be3004087d1',
            'integr'        => 'secret_2XXOYzX5JThHqZviHGZpPna5ihVU2o3knCvrCu76RjS',
            'properties'    => [
                'Nom-Prénom', 
                'CDC',
                'ActivitéP',
                'ActivitéS',
                'Cotisant/Participant/Extérieur',
                'Statut',
                'Civilité',
                'Rue + Numéro/Boite',
                'Code postal',
                'Localité',
                'Gsm',
                'Téléphone',
                'Mail',
                'Cotisation',
                'Certificat',
                'Date de Naissance',
                "Date d'Inscription",
                'Date de Sortie',
                'EneoSport',
                'Seagma',
                'Contrôle',
                'Expand',
                'Mod.Secr.',
                'AllActs',
                'Reference',
                'Alpha',
                'Paiement',
                'Modifications_NIV'
            ],
            'filter'        => {},
            'sort'          => {},
            'url'           => 'https://www.notion.so/eneobw/96313b72db5542cbac572be3004087d1?v=ce78128936074ddcabe15921654b756c&pvs=4'
        }
       }
    }
#
#   Functions
#   +++++++++
    #Return infos to caller
    def PrvTables_tra.loadTable(p_table='MBR2')
    #++++++++++++++++++++++++++
        #INP::  p_table: prefix
        #OUT::  {pref=>,name=>,id=>,properties=>,filter=>,sort=>,url=>}
        #
        return  @tables[p_table]
    end #<def>
    #
    #
end #<Mod>
