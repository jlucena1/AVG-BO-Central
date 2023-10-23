pageextension 50105 "AVG Inventory Setup Ext." extends "Inventory Setup"
{
    layout
    {
        addafter(Numbering)
        {
            field("AVG Auto Rcv. NonWhse Transfer"; Rec."AVG Auto Rcv. NonWhse Transfer")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Auto Receive Non-Whse Transfer field.';
            }
            field("AVG Auto Rcv. Whse Transfer"; Rec."AVG Auto Rcv. Whse Transfer")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Auto Receive Whse Transfer field.';
            }
            field("AVG Stock Rqst. Loc. Code From"; Rec."AVG Stock Rqst. Loc. Code From")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Stock Rqst. Loc. Code From field.';
            }
        }
    }
}
