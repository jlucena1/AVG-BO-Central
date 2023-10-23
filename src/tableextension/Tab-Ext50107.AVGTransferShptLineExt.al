tableextension 50107 "AVG Transfer Shpt. Line Ext." extends "Transfer Shipment Line"
{
    fields
    {
        field(50100; "AVG Remarks"; Text[300])
        {
            Caption = 'Remarks';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50101; "AVG Imported from Excel"; Boolean)
        {
            Caption = 'Imported from Excel';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50102; "AVG Type"; Code[50])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50103; "AVG Sub Category"; Code[50])
        {
            Caption = 'Sub Category';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50104; "AVG Bin Location"; Code[50])
        {
            Caption = 'Bin Location';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50105; "AVG Old Item Code"; Code[20])
        {
            Caption = 'Old Item Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50106; "AVG Price"; Decimal)
        {
            Caption = 'Price';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
