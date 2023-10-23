pageextension 50106 "AVG Location Card Ext." extends "Location Card"
{
    layout
    {
        addafter("LSC Customer Order Defaults")
        {
            group("AVG Customizations")
            {
                field("AVG Distribution Center"; Rec."AVG Distribution Center")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Center field.';
                }
            }
        }
    }
}
