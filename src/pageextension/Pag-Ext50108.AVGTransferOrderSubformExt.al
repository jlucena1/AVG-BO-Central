pageextension 50108 "AVG Transfer Order Subform Ext" extends "Transfer Order Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("AVG Remarks"; Rec."AVG Remarks")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Remarks field.';
            }
            field("AVG Imported from Excel"; Rec."AVG Imported from Excel")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Imported from Excel field.';
            }
            field("AVG Type"; Rec."AVG Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Type field.';
            }
            field("AVG Sub Category"; Rec."AVG Sub Category")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Sub Category field.';
            }
            field("AVG Bin Location"; Rec."AVG Bin Location")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Bin Location field.';
            }
            field("AVG Old Item Code"; Rec."AVG Old Item Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Old Item Code field.';
            }
            field("AVG Price"; Rec."AVG Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Price field.';
            }
        }
    }
}
