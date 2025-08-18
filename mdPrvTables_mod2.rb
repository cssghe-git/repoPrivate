#
=begin
    #   Define infos for all private DBs
    #   VRP: 1-1-1 <> <
=end

module PrvTables_mod2
#====================
#
#   Variables
#   +++++++++
    @tables  = {
        'MOD2'   => {
            'prefix'        => 'MOD2',
            'name'          => '',
            'id'            => '',
            'integr'        => '',
            'properties'    => [
                'Nom-Prénom',
                'ActivitéP',
                'ActivitéS',
                'Expand',
                'CPE',
                'CDC',
                'Statut',
                'Demande',
                'Validation',
                'Suppression',
                'EneoSport',
                'Civilité',
                'Rue + Numéro/Bte',
                'Coe postal',
                'Localité',
                'Gsm',
                'Téléphone',
                'Mail',
                'Cotisation',
                'Paiement',
                'Certificat',
                'Date de Naissance',
                "Date d'Inscription",
                'Date de Sortie',
                'Cotisant',
                'Participant',
                'Reference',
                'Mod.Secr.',
                'Type',
                'Alpha',
                'Form.Author',
                'Membre_NIV',
                'AllMembers_NIV',
                'Doubles',
                'LstMembers_NIV',
                'RefID'
            ],
            'filter'        => {},
            'sort'          => {},
            'url'           => ''
        }
        }
    }
#
#   Functions
#   +++++++++
    #Return infos to caller
    def PrvTables_tra.loadTable(p_table='MOD2')
    #++++++++++++++++++++++++++
        #INP::  p_table: prefix
        #OUT::  {pref=>,name=>,id=>,properties=>,filter=>,sort=>,url=>}
        #
        return  @tables[p_table]
    end #<def>
    #
    #
end #<Mod>
