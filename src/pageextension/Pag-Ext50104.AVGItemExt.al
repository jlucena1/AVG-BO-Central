pageextension 50104 "AVG Item Ext." extends "Item Card"
{
    layout
    {
        addafter(Replenishment)
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
