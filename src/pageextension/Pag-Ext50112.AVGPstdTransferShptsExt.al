pageextension 50112 "AVG Pstd. Transfer Shpts. Ext." extends "Posted Transfer Shipments"
{
    layout
    {
        addlast(Control1)
        {
            field("AVG Request Date"; Rec."AVG Request Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Request Date field.';
            }
            field("AVG Order Date"; Rec."AVG Order Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Order Date field.';
            }
            field("AVG Delivery Date"; Rec."AVG Delivery Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Delivery Date field.';
            }
            field("AVG Last Filename Uploaded"; Rec."AVG Last Filename Uploaded")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Last Filename Uploaded field.';
            }
            field("AVG Last Uploaded By"; Rec."AVG Last Uploaded By")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Last Uploaded By field.';
            }
            field("AVG Last Uploaded DateTime"; Rec."AVG Last Uploaded DateTime")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Last Uploaded DateTime field.';
            }
        }
    }
}
