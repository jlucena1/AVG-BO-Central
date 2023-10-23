pageextension 50111 "AVG Transfer Shpt. Subform Ext" extends "Posted Transfer Shpt. Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("AVG Remarks"; Rec."AVG Remarks")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Remarks field.';
                Editable = false;
            }
            field("AVG Imported from Excel"; Rec."AVG Imported from Excel")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Imported from Excel field.';
                Editable = false;
            }
            field("AVG Type"; Rec."AVG Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Type field.';
                Editable = false;
            }
            field("AVG Sub Category"; Rec."AVG Sub Category")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Sub Category field.';
                Editable = false;
            }
            field("AVG Bin Location"; Rec."AVG Bin Location")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Bin Location field.';
                Editable = false;
            }
            field("AVG Old Item Code"; Rec."AVG Old Item Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Old Item Code field.';
                Editable = false;
            }
            field("AVG Price"; Rec."AVG Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Price field.';
                Editable = false;
            }
        }
    }
}
