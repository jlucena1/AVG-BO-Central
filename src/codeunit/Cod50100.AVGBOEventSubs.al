codeunit 50100 "AVG BO Event Subs."
{
    var
        AVGBOUtils: Codeunit "AVG BO Utility";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post (Yes/No)", OnBeforeConfirmPost, '', false, false)]
    local procedure OnBeforeConfirmPost(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer);
    var
    begin
        HideDialog := true;
        AVGBOUtils.AVGConfirmPurchPost(PurchaseHeader);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post (Yes/No)", OnBeforePost, '', false, false)]
    local procedure OnBeforePost(var TransHeader: Record "Transfer Header"; var IsHandled: Boolean; var TransferOrderPostShipment: Codeunit "TransferOrder-Post Shipment"; var TransferOrderPostReceipt: Codeunit "TransferOrder-Post Receipt"; var PostBatch: Boolean; var TransferOrderPost: Enum "Transfer Order Post");
    var
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        Location: Record Location;
        TransferErrMsg: Label 'Return to Distribution Center is not Allowed!\Please check the included Items.';
    begin
        IF Location.GET(TransHeader."Transfer-to Code") then
            IF Location."AVG Distribution Center" then begin
                TransferLine.setrange("Document No.", TransHeader."No.");
                IF TransferLine.FindSet() then
                    repeat
                        IF Item.GET(TransferLine."Item No.") then
                            IF Item."AVG Non Returnable" then
                                Error(TransferErrMsg);
                    until TransferLine.next = 0;
            end;
    end;


    [EventSubscriber(ObjectType::Page, Page::"Transfer Order", 'OnModifyRecordEvent', '', FALSE, FALSE)]
    local procedure NonWarehouseTransferReceivedFromNonWhse(var xRec: Record "Transfer Header"; var Rec: Record "Transfer Header"; var AllowModify: Boolean)
    var
        TransferLine: Record "Transfer Line";
        InventorySetup: Record "Inventory Setup";
        Location: Record Location;
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";
    begin

        InventorySetup.GET;
        Location.GET(Rec."Transfer-to Code");

        IF Location."Require Receive" THEN
            EXIT;

        IF NOT InventorySetup."AVG Auto Rcv. NonWhse Transfer" THEN
            EXIT;

        IF (Rec.Status = Rec.Status::Released) AND
        (Rec."LSC Retail Status" = Rec."LSC Retail Status"::"To receive") THEN BEGIN
            // (Rec."SPO Transfer Status" = Rec."LSCSPO Transfer Status"::Waiting) THEN BEGIN
            TransferLine.RESET;
            TransferLine.SETRANGE("Document No.", Rec."No.");
            TransferLine.SETFILTER("Quantity Shipped", '<>%1', 0);
            TransferLine.SETFILTER("Qty. in Transit", '<>%1', 0);
            TransferLine.SETFILTER("Derived From Line No.", '%1', 0);
            TransferLine.SETFILTER("Qty. to Receive", '<>%1', 0);
            IF TransferLine.FINDSET THEN
                REPEAT
                    // IF Rec.lsc<> '' THEN
                    //     Rec.SetStoreDocDim(1, Rec."Transfer-to Depart. Code");
                    TransferPostReceipt.RUN(Rec);
                UNTIL TransferLine.NEXT = 0;
        END;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Transfer Order", 'OnModifyRecordEvent', '', FALSE, FALSE)]
    local procedure WarehouseTransferReceivedFromNonWhse(var xRec: Record "Transfer Header"; var Rec: Record "Transfer Header"; var AllowModify: Boolean)
    var
        TransferLine: Record "Transfer Line";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        WhseReceiptLine2: Record "Warehouse Receipt Line";
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityLine2: Record "Warehouse Activity Line";
        InventorySetup: Record "Inventory Setup";
        Location: Record Location;
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";
        GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
        WhseMgt: Codeunit "WMS Management";
        WhsePostReceipt: Codeunit "Whse.-Post Receipt";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
    begin
        InventorySetup.GET;
        Location.GET(Rec."Transfer-to Code");

        IF NOT Location."Require Receive" THEN
            EXIT;
        IF NOT InventorySetup."AVG Auto Rcv. Whse Transfer" THEN
            EXIT;

        IF (Rec.Status = Rec.Status::Released) AND
        (Rec."LSC Retail Status" = Rec."LSC Retail Status"::"To receive") THEN BEGIN
            // (Rec."SPO Transfer Status" = Rec."SPO Transfer Status"::Waiting) THEN BEGIN
            TransferLine.RESET;
            TransferLine.SETRANGE("Document No.", Rec."No.");
            TransferLine.SETFILTER("Quantity Shipped", '<>%1', 0);
            TransferLine.SETFILTER("Qty. in Transit", '<>%1', 0);
            TransferLine.SETFILTER("Derived From Line No.", '%1', 0);
            // TransferLine.SETFILTER(, '<>%1', 0);
            IF TransferLine.FINDSET THEN
                REPEAT
                    GetSourceDocInbound.CreateFromInbndTransferOrder(Rec);

                    WhseReceiptLine.RESET;
                    WhseReceiptLine.SETRANGE("Source No.", Rec."No.");
                    WhseReceiptLine.SETRANGE("Source Document", WhseReceiptLine."Source Document"::"Inbound Transfer");
                    IF WhseReceiptLine.FINDSET THEN
                        REPEAT
                            WhseReceiptLine2.COPY(WhseReceiptLine);
                            WhsePostReceipt.RUN(WhseReceiptLine2);
                            WhsePostReceipt.GetResultMessage;
                            CLEAR(WhsePostReceipt);
                        UNTIL WhseReceiptLine.NEXT = 0;

                    IF Location."Require Put-away" THEN BEGIN
                        WhseActivityLine.RESET;
                        WhseActivityLine.SETRANGE("Source No.", Rec."No.");
                        WhseActivityLine.SETRANGE("Source Document", WhseActivityLine."Source Document"::"Inbound Transfer");
                        IF WhseActivityLine.FINDSET THEN
                            REPEAT
                                WhseActivityLine2.COPY(WhseActivityLine);
                                IF (WhseActivityLine2."Activity Type" = WhseActivityLine2."Activity Type"::"Invt. Movement") AND
                                   NOT (WhseActivityLine2."Source Document" IN [WhseActivityLine2."Source Document"::" ",
                                                              WhseActivityLine2."Source Document"::"Prod. Consumption",
                                                              WhseActivityLine2."Source Document"::"Assembly Consumption"])
                                THEN
                                    ERROR(Text002, WhseActivityLine2."Source Document");

                                WhseMgt.CheckBalanceQtyToHandle(WhseActivityLine2);

                                //IF NOT CONFIRM(RSAText001,FALSE,LrecWhseActivLine."Activity Type") THEN
                                //  EXIT;

                                WhseActivityRegister.RUN(WhseActivityLine2);
                                CLEAR(WhseActivityRegister);
                            UNTIL WhseActivityLine.NEXT = 0;
                    END;
                UNTIL TransferLine.NEXT = 0;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment (Yes/No)", OnAfterCode, '', false, false)]
    local procedure NonWarehouseTransferReceivedFromWhse(var WarehouseShipmentLine: Record "Warehouse Shipment Line");
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        WhseReceiptLine2: Record "Warehouse Receipt Line";
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityLine2: Record "Warehouse Activity Line";
        InventorySetup: Record "Inventory Setup";
        Location: Record Location;
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";
        GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
        WhseMgt: Codeunit "WMS Management";
        WhsePostReceipt: Codeunit "Whse.-Post Receipt";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
    begin
        IF NOT TransferHeader.GET(WarehouseShipmentLine."Source No.") THEN
            EXIT;

        InventorySetup.GET;
        Location.GET(TransferHeader."Transfer-to Code");

        IF Location."Require Receive" THEN
            EXIT;
        IF NOT InventorySetup."AVG Auto Rcv. NonWhse Transfer" THEN
            EXIT;

        IF (TransferHeader.Status = TransferHeader.Status::Released) AND
        (TransferHeader."LSC Retail Status" = TransferHeader."LSC Retail Status"::"To receive") THEN BEGIN
            // (TransferHeader."SPO Transfer Status" = TransferHeader."SPO Transfer Status"::Waiting) THEN BEGIN
            TransferLine.RESET;
            TransferLine.SETRANGE("Document No.", TransferHeader."No.");
            TransferLine.SETFILTER("Quantity Shipped", '<>%1', 0);
            TransferLine.SETFILTER("Qty. in Transit", '<>%1', 0);
            TransferLine.SETFILTER("Derived From Line No.", '%1', 0);
            TransferLine.SETFILTER("Qty. to Receive", '<>%1', 0);
            IF TransferLine.FINDSET THEN
                REPEAT
                    // IF TransferHeader."Transfer-to Depart. Code" <> '' THEN
                    //     TransferHeader.SetStoreDocDim(1, TransferHeader."Transfer-to Depart. Code");
                    TransferPostReceipt.RUN(TransferHeader);
                UNTIL TransferLine.NEXT = 0;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment (Yes/No)", OnAfterCode, '', false, false)]
    local procedure WarehouseTransferReceivedFromWhse(var WarehouseShipmentLine: Record "Warehouse Shipment Line");
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        WhseReceiptLine2: Record "Warehouse Receipt Line";
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityLine2: Record "Warehouse Activity Line";
        InventorySetup: Record "Inventory Setup";
        Location: Record Location;
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";
        GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
        WhseMgt: Codeunit "WMS Management";
        WhsePostReceipt: Codeunit "Whse.-Post Receipt";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
    begin
        IF NOT TransferHeader.GET(WarehouseShipmentLine."Source No.") THEN
            EXIT;

        InventorySetup.GET;
        IF Location.GET(TransferHeader."Transfer-to Code") THEN;

        IF NOT Location."Require Receive" THEN
            EXIT;
        IF NOT InventorySetup."AVG Auto Rcv. Whse Transfer" THEN
            EXIT;

        IF (TransferHeader.Status = TransferHeader.Status::Released) AND
        (TransferHeader."LSC Retail Status" = TransferHeader."LSC Retail Status"::"To receive") THEN BEGIN
            // (TransferHeader."SPO Transfer Status" = TransferHeader."SPO Transfer Status"::Waiting) THEN BEGIN
            TransferLine.RESET;
            TransferLine.SETRANGE("Document No.", TransferHeader."No.");
            TransferLine.SETFILTER("Quantity Shipped", '<>%1', 0);
            TransferLine.SETFILTER("Qty. in Transit", '<>%1', 0);
            TransferLine.SETFILTER("Derived From Line No.", '%1', 0);
            // TransferLine.SETFILTER("Actual Qty. to Receive", '<>%1', 0);
            IF TransferLine.FINDSET THEN
                REPEAT
                    GetSourceDocInbound.CreateFromInbndTransferOrder(TransferHeader);

                    WhseReceiptLine.RESET;
                    WhseReceiptLine.SETRANGE("Source No.", TransferHeader."No.");
                    WhseReceiptLine.SETRANGE("Source Document", WhseReceiptLine."Source Document"::"Inbound Transfer");
                    IF WhseReceiptLine.FINDSET THEN
                        REPEAT
                            WhseReceiptLine2.COPY(WhseReceiptLine);
                            WhsePostReceipt.RUN(WhseReceiptLine2);
                            WhsePostReceipt.GetResultMessage;
                            CLEAR(WhsePostReceipt);
                        UNTIL WhseReceiptLine.NEXT = 0;

                    IF Location."Require Put-away" THEN BEGIN
                        WhseActivityLine.RESET;
                        WhseActivityLine.SETRANGE("Source No.", TransferHeader."No.");
                        WhseActivityLine.SETRANGE("Source Document", WhseActivityLine."Source Document"::"Inbound Transfer");
                        IF WhseActivityLine.FINDSET THEN
                            REPEAT
                                WhseActivityLine2.COPY(WhseActivityLine);
                                IF (WhseActivityLine2."Activity Type" = WhseActivityLine2."Activity Type"::"Invt. Movement") AND
                                   NOT (WhseActivityLine2."Source Document" IN [WhseActivityLine2."Source Document"::" ",
                                                              WhseActivityLine2."Source Document"::"Prod. Consumption",
                                                              WhseActivityLine2."Source Document"::"Assembly Consumption"])
                                THEN
                                    ERROR(Text002, WhseActivityLine2."Source Document");

                                WhseMgt.CheckBalanceQtyToHandle(WhseActivityLine2);

                                //IF NOT CONFIRM(RSAText001,FALSE,LrecWhseActivLine."Activity Type") THEN
                                //  EXIT;

                                WhseActivityRegister.RUN(WhseActivityLine2);
                                CLEAR(WhseActivityRegister);
                            UNTIL WhseActivityLine.NEXT = 0;
                    END;
                UNTIL TransferLine.NEXT = 0;
        END;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Header", OnBeforePrintRecords, '', false, false)]
    local procedure OnBeforePrintRecords(var TransShptHeader: Record "Transfer Shipment Header"; ShowRequestPage: Boolean; var IsHandled: Boolean);
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        CLEAR(TransferShipmentHeader);
        TransferShipmentHeader.Copy(TransShptHeader);
        Report.RunModal(50100, true, true, TransferShipmentHeader);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", OnBeforeInsertTransShptHeader, '', false, false)]
    local procedure OnBeforeInsertTransShptHeader(var TransShptHeader: Record "Transfer Shipment Header"; TransHeader: Record "Transfer Header"; CommitIsSuppressed: Boolean);
    begin
        TransShptHeader."AVG Order Date" := TransHeader."AVG Order Date";
        TransShptHeader."AVG Delivery Date" := TransHeader."AVG Delivery Date";
        TransShptHeader."AVG Request Date" := TransHeader."AVG Request Date";
        TransShptHeader."AVG Last Filename Uploaded" := TransHeader."AVG Last Filename Uploaded";
        TransShptHeader."AVG Last Uploaded By" := TransHeader."AVG Last Uploaded By";
        TransShptHeader."AVG Last Uploaded DateTime" := TransHeader."AVG Last Uploaded DateTime";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", OnBeforeInsertTransShptLine, '', false, false)]
    local procedure OnBeforeInsertTransShptLine(var TransShptLine: Record "Transfer Shipment Line"; TransLine: Record "Transfer Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; TransShptHeader: Record "Transfer Shipment Header");
    begin
        TransShptLine."AVG Bin Location" := TransLine."AVG Bin Location";
        TransShptLine."AVG Imported from Excel" := TransLine."AVG Imported from Excel";
        TransShptLine."AVG Old Item Code" := TransLine."AVG Old Item Code";
        TransShptLine."AVG Price" := TransLine."AVG Price";
        TransShptLine."AVG Remarks" := TransLine."AVG Remarks";
        TransShptLine."AVG Sub Category" := TransLine."AVG Sub Category";
        TransShptLine."AVG Type" := TransLine."AVG Type";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", OnBeforeTransRcptHeaderInsert, '', false, false)]
    local procedure OnBeforeTransRcptHeaderInsert(var TransferReceiptHeader: Record "Transfer Receipt Header"; TransferHeader: Record "Transfer Header");
    begin
        TransferReceiptHeader."AVG Order Date" := TransferHeader."AVG Order Date";
        TransferReceiptHeader."AVG Delivery Date" := TransferHeader."AVG Delivery Date";
        TransferReceiptHeader."AVG Request Date" := TransferHeader."AVG Request Date";
        TransferReceiptHeader."AVG Last Filename Uploaded" := TransferHeader."AVG Last Filename Uploaded";
        TransferReceiptHeader."AVG Last Uploaded By" := TransferHeader."AVG Last Uploaded By";
        TransferReceiptHeader."AVG Last Uploaded DateTime" := TransferHeader."AVG Last Uploaded DateTime"
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", OnBeforeInsertTransRcptLine, '', false, false)]
    local procedure OnBeforeInsertTransRcptLine(var TransRcptLine: Record "Transfer Receipt Line"; TransLine: Record "Transfer Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; TransferReceiptHeader: Record "Transfer Receipt Header");
    begin
        TransRcptLine."AVG Bin Location" := TransLine."AVG Bin Location";
        TransRcptLine."AVG Imported from Excel" := TransLine."AVG Imported from Excel";
        TransRcptLine."AVG Old Item Code" := TransLine."AVG Old Item Code";
        TransRcptLine."AVG Price" := TransLine."AVG Price";
        TransRcptLine."AVG Remarks" := TransLine."AVG Remarks";
        TransRcptLine."AVG Sub Category" := TransLine."AVG Sub Category";
        TransRcptLine."AVG Type" := TransLine."AVG Type";
    end;



    var
        Text001: Label 'Do you want to register the %1 Document?';
        Text002: Label 'The document %1 is not supported.';
}
