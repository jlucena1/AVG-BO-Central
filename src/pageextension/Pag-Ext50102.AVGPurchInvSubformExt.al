pageextension 50102 "AVG Purch. Inv. Subform Ext." extends "Purch. Invoice Subform"
{
    layout
    {
        modify("Line Amount")
        {
            Editable = EditableFields;
        }
        modify("Direct Unit Cost")
        {
            Editable = EditableFields;
        }
    }
    trigger OnOpenPage()
    begin
        SetEditableProductGroups();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetEditableProductGroups
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetEditableProductGroups
    end;

    local procedure SetEditableProductGroups()
    var
        LSCRetailProductGroups: Record "LSC Retail Product Group";
    begin
        IF Rec.Type = Rec.Type::Item then begin
            IF LSCRetailProductGroups.Get(Rec."Item Category Code", Rec."LSC Retail Product Code") then begin
                if LSCRetailProductGroups."AVG Enable PI Lines" then
                    EditableFields := true
                else
                    EditableFields := false;
            end else
                EditableFields := false;
        end else
            EditableFields := true;
    end;

    var
        EditableFields: Boolean;
}
