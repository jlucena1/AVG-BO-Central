tableextension 50102 "AVG Inventory Setup Ext." extends "Inventory Setup"
{
    fields
    {
        field(50100; "AVG Auto Rcv. NonWhse Transfer"; Boolean)
        {
            Caption = 'Auto Receive Non-Whse Transfer';
            DataClassification = CustomerContent;
        }
        field(50101; "AVG Auto Rcv. Whse Transfer"; Boolean)
        {
            Caption = 'Auto Receive Whse Transfer';
            DataClassification = CustomerContent;
        }
        field(50102; "AVG Stock Rqst. Loc. Code From"; Code[10])
        {
            Caption = 'Stock Rqst. Loc. Code From';
            DataClassification = CustomerContent;
            TableRelation = Location.Code WHERE("AVG Distribution Center" = filter('Yes'));
        }
    }
}
