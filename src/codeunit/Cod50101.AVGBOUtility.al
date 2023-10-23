codeunit 50101 "AVG BO Utility"
{
    SingleInstance = true;
    procedure AVGConfirmPurchPost(var PurchaseHeader: Record "Purchase Header"): Boolean;
    var
        Selection: Integer;
        ConfirmManagement: Codeunit "Confirm Management";
        ReceiveInvoiceQst: Label '&Receive';
        ShipInvoiceQst: Label '&Ship';
        PostConfirmQst: Label 'Do you want to post the %1?', Comment = '%1 = Document Type';
    begin
        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Order:
                begin
                    Selection := StrMenu(ReceiveInvoiceQst, 1);
                    PurchaseHeader.Receive := Selection in [1, 1];
                    if Selection = 0 then
                        exit(false);
                end;
            PurchaseHeader."Document Type"::"Return Order":
                begin
                    Selection := StrMenu(ShipInvoiceQst, 1);
                    if Selection = 0 then
                        exit(false);
                    PurchaseHeader.Ship := Selection in [1, 1];
                end;
            else
                if not ConfirmManagement.GetResponseOrDefault(
                     StrSubstNo(PostConfirmQst, LowerCase(Format(PurchaseHeader."Document Type"))), true)
                then
                    exit(false);
        end;
        PurchaseHeader."Print Posted Documents" := false;
        exit(true);
    end;

    procedure ImportStockRequestFromExcel(var TransferHeader: Record "Transfer Header")
    var
        Location: Record Location;
        InventorySetup: Record "Inventory Setup";
        ExcelBuffer: Record "Excel Buffer";
        ExcelBuffer1: Record "Excel Buffer";
        ExcelBuffer2: Record "Excel Buffer";
        ExcelBuffer3: Record "Excel Buffer";
        FileMgt: Codeunit "File Management";
        Counter: Integer;
        Selection: Integer;
        FileName: Text;
        ActualFileName: Text;
        SheetName: Text;
        InTransitCode: Text;
        ImportSRMsg: Label 'Import Stock Request';
        ImportExtTypeMsg: Label '*.xls';
        ImportSRErrorMsg: Label 'You are not allowed to upload the same file.';
        ImportSTRSelectMsg: Label 'Select In-Transit Code:';
    begin
        InventorySetup.GET;
        InventorySetup.TESTFIELD("AVG Stock Rqst. Loc. Code From");

        CLEAR(FileName);
        FileName := FileMgt.UploadFile(ImportSRMsg, ImportExtTypeMsg);
        IF FileName = '' then
            EXIT;

        IF NOT Exists(FileName) then
            exit;
        CLEAR(ActualFileName);
        ActualFileName := FileMgt.GetFileName(FileName);

        CLEAR(SheetName);
        SheetName := ExcelBuffer.SelectSheetsName(FileName);
        if SheetName = '' then
            exit;

        IF TransferHeader."AVG Last Filename uploaded" = ActualFileName THEN
            ERROR(ImportSRErrorMsg);

        CLEAR(Location);
        CLEAR(InTransitCode);
        Location.SETRANGE("Use As In-Transit", TRUE);
        IF Location.FINDSET THEN
            REPEAT
                InTransitCode += Location.Code + ',';
            UNTIL Location.NEXT = 0;

        InTransitCode := COPYSTR(InTransitCode, 1, STRLEN(InTransitCode) - 1);
        IF Location.COUNT > 1 THEN BEGIN
            Selection := STRMENU(InTransitCode, 1, ImportSTRSelectMsg);

            IF Selection = 0 THEN
                EXIT;

            InTransitCode := SELECTSTR(Selection, InTransitCode);
        END;
        ExcelBuffer.DELETEALL;
        ExcelBuffer.LockTable();
        ExcelBuffer.OpenBook(FileName, SheetName);
        ExcelBuffer.ReadSheet();

        CLEAR(Location);
        Location.GET(InTransitCode);

        EVALUATE(TransferHeader."Transfer-from Code", InventorySetup."AVG Stock Rqst. Loc. Code From");
        TransferHeader.VALIDATE("Transfer-from Code");

        EVALUATE(TransferHeader."Transfer-to Code", GetCellValueNew(6, 2));
        TransferHeader.VALIDATE("Transfer-to Code");

        EVALUATE(TransferHeader."LSC Store-from", InventorySetup."AVG Stock Rqst. Loc. Code From");
        TransferHeader.VALIDATE("LSC Store-from");

        EVALUATE(TransferHeader."LSC Store-to", GetCellValueNew(6, 2));
        TransferHeader.VALIDATE("LSC Store-to");

        TransferHeader."In-Transit Code" := InTransitCode;
        TransferHeader.VALIDATE("In-Transit Code");

        IF EVALUATE(TransferHeader."AVG Request date", GetCellValueNew(3, 2)) THEN;
        IF EVALUATE(TransferHeader."AVG Delivery Date", GetCellValueNew(4, 2)) THEN;
        TransferHeader."AVG Order Date" := TODAY;

        IF TransferHeader."AVG Last Filename uploaded" <> ActualFileName THEN
            TransferHeader."AVG Last Filename uploaded" := ActualFileName;
        TransferHeader."AVG Last Uploaded By" := UserId;
        TransferHeader."AVG Last Uploaded DateTime" := CreateDateTime(TODAY, TIME);
        TransferHeader.MODIFY(TRUE);

        CLEAR(ExcelBuffer3);
        ExcelBuffer3.SETFILTER("Row No.", '>=%1', 9);
        ExcelBuffer3.SETRANGE("Column No.", 7);
        ExcelBuffer3.SETFILTER("Cell Value as Text", '<>%1', '');
        IF ExcelBuffer3.FINDSET THEN
            REPEAT
                InsertIntoTransferLine(ExcelBuffer3."Row No.", TransferHeader);
            UNTIL ExcelBuffer3.NEXT = 0;
    end;

    local procedure InsertIntoTransferLine(RowNo: Integer; TransferHeader: Record "Transfer Header")
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        ItemUOM2: Record "Item Unit of Measure";
        TransferLine: Record "Transfer Line";
        TransferLine2: Record "Transfer Line";
        LineNo: Integer;
        Selection: Integer;
        AvailableItemUOM: Boolean;
        ItemString: Text;
        ItemUOMString: Text;
        ItemUOMMsg: Label 'Select Available Item Unit of Measure Code for:';
    begin
        CLEAR(ItemString);
        IF Item.GET(GetCellValueNew(RowNo, 5)) THEN
            ItemString := Item."No.";

        IF ItemString <> '' THEN BEGIN
            ItemUOMString := GetCellValueNew(RowNo, 10);
            CLEAR(TransferLine);
            TransferLine.SETRANGE("Document No.", TransferHeader."No.");
            IF TransferLine.FINDLAST THEN
                LineNo := TransferLine."Line No." + 10000
            ELSE
                LineNo := 10000;

            TransferLine.SETRANGE("Document No.");

            TransferLine2.INIT;
            TransferLine2."Document No." := TransferHeader."No.";
            TransferLine2."Line No." := LineNo;
            TransferLine2.VALIDATE("Item No.", GetCellValueNew(RowNo, 5));
            IF TransferLine2.Description = '' THEN
                TransferLine2.VALIDATE(Description, GetCellValueNew(RowNo, 10));

            AvailableItemUOM := ItemUOM2.GET(Item."No.", ItemUOMString);

            IF AvailableItemUOM THEN
                TransferLine2.VALIDATE("Unit of Measure Code", ItemUOMString)
            ELSE BEGIN
                CLEAR(ItemUOM);
                CLEAR(Selection);
                CLEAR(ItemUOM);
                ItemUOM.SETRANGE("Item No.", Item."No.");
                IF ItemUOM.FINDSET THEN
                    REPEAT
                        ItemUOMString += ItemUOM.Code + ',';
                    UNTIL ItemUOM.NEXT = 0;
                ItemUOMString := COPYSTR(ItemUOMString, 1, STRLEN(ItemUOMString) - 1);
                IF (ItemUOM.COUNT > 1) THEN BEGIN
                    Selection := STRMENU(ItemUOMString, 1, ItemUOMMsg + '\' + Item."No." + ' - ' + Item.Description);
                    IF Selection = 0 THEN BEGIN
                        TransferLine2.VALIDATE("Item No.")
                    END ELSE BEGIN
                        ItemUOMString := SELECTSTR(Selection, ItemUOMString);
                        TransferLine2.VALIDATE("Unit of Measure Code", ItemUOMString);
                    END;
                END;
            END;

            TransferLine2."AVG Imported from Excel" := TRUE;
            TransferLine2."AVG Type" := GetCellValueNew(RowNo, 1);
            TransferLine2."AVG Sub Category" := GetCellValueNew(RowNo, 2);
            TransferLine2."AVG Bin Location" := GetCellValueNew(RowNo, 3);
            TransferLine2."AVG Old Item Code" := GetCellValueNew(RowNo, 4);
            IF EVALUATE(TransferLine2.Quantity, GetCellValueNew(RowNo, 7)) THEN;
            TransferLine2.VALIDATE(Quantity);
            IF EVALUATE(TransferLine2."AVG Price", GetCellValueNew(RowNo, 9)) THEN;
            IF TransferLine2.Quantity <> 0 THEN
                TransferLine2.INSERT(TRUE);
        END;
    end;

    local procedure GetCellValueNew(Row: Integer; Col: Integer): Text;
    var
        ExcelBufferLoc: Record "Excel Buffer";
    begin
        IF ExcelBufferLoc.GET(Row, Col) THEN
            EXIT(ExcelBufferLoc."Cell Value as Text");
    end;
}
