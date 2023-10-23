pageextension 50119 "AVG LSC P. Trs. Shpt. Card Ext" extends "LSC Store P. Transfer Shipment"
{
    layout
    {
        addafter(General)
        {
            group("AVG Customizations")
            {
                field("Last Filename Uploaded"; Rec."AVG Last Filename Uploaded")
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
                field("Request Date"; Rec."AVG Request Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Date field.';
                }
                field("Order Date"; Rec."AVG Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Date field.';
                }
                field("Delivery Date"; Rec."AVG Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Date field.';
                }
            }
        }
    }

}
