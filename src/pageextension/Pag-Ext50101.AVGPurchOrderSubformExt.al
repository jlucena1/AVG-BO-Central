pageextension 50101 "AVG Purch. Order Subform Ext." extends "Purchase Order Subform"
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
                if LSCRetailProductGroups."AVG Enable PO Lines" then
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
