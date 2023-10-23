tableextension 50108 "AVG Transfer Receipt Ext." extends "Transfer Receipt Header"
{
    fields
    {
        field(50100; "AVG Order Date"; Date)
        {
            Caption = 'Order Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50101; "AVG Delivery Date"; Date)
        {
            Caption = 'Delivery Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50102; "AVG Request Date"; Date)
        {
            Caption = 'Request Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50103; "AVG Last Filename Uploaded"; Text[250])
        {
            Caption = 'Last Filename Uploaded';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50104; "AVG Last Uploaded By"; Code[100])
        {
            Caption = 'Last Uploaded By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50105; "AVG Last Uploaded DateTime"; DateTime)
        {
            Caption = 'Last Uploaded DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
