tableextension 50100 "AVG Product Group Ext." extends "LSC Retail Product Group"
{
    fields
    {
        field(50100; "AVG Enable PO Lines"; Boolean)
        {
            Caption = 'Enable PO Lines';
            DataClassification = CustomerContent;
        }
        field(50101; "AVG Enable PI Lines"; Boolean)
        {
            Caption = 'Enable PI Lines';
            DataClassification = CustomerContent;
        }
    }
}
