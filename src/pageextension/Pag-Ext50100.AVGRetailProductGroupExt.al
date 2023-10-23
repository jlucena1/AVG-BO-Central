pageextension 50100 "AVG Retail Product Group Ext." extends "LSC Retail Product Group"
{
    layout
    {
        addafter(General)
        {
            group("AVG Customizations")
            {
                field("AVG Enable PI Lines"; Rec."AVG Enable PI Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable PI Lines field.';
                }
                field("AVG Enable PO Lines"; Rec."AVG Enable PO Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable PO Lines field.';
                }
            }
        }
    }
}
