pageextension 50103 "AVG Retail Item Ext." extends "LSC Retail Item Card"
{
    layout
    {
        addafter("LSC Forecast")
        {
            group("AVG Customizations")
            {
                field("AVG Non Returnable"; Rec."AVG Non Returnable")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the AVG Non Returnable field.';
                }
            }
        }
    }
}
