codeunit 60005 "INT_TH_OrderProcessing_SNY"
{
    trigger OnRun()
    var
        UpdateSalesHeader: Record "Sales Header";
        InterfaceSetup: Record INT_InterfaceSetup_SNY;
        UpdateStatus: Codeunit INT_SyncMktStatus_SNY;
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        FinalLocationCode: Code[10];
        MarketPlace: Record INT_MarketPlaces_SNY;
        ShopifyFullfillmentSetup: Record "INT_Shopify Fullfillment Setup";
        Item: record Item;
    begin
        InterfaceSetup.Get();

        SalesHeader.TestField(INT_MktSyncStatus_SNY);
        SalesHeader.INT_ProcessErr_SNY := '';
        SalesHeader.Modify();
        Commit();

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            MarketPlace.Get(SalesHeader.INT_MarketPlace_SNY);
            if MarketPlace."Process ID" = 1 then begin // SHOPIFY - PROCESS
                                                       //
                SalesLine2.Reset;
                SalesLine2.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine2.SetRange("Document No.", SalesHeader."No.");
                if SalesLine2.findfirst() then
                    repeat
                        ShopifyFullfillmentSetup.Reset;
                        ShopifyFullfillmentSetup.SetRange(FulfilmentLocation, SalesLine2.INT_FulfilmentLocation_SNY);
                        ShopifyFullfillmentSetup.SetRange(ShippingProfile, SalesHeader.INT_ShippingProfile_SNY);
                        if ShopifyFullfillmentSetup.Findfirst() then begin
                            //
                            // Message('Second %1,%2', ShopifyFullfillmentSetup."Final Delivery Type", ShopifyFullfillmentSetup."Final Location");
                            //
                            SalesLine2.INT_DeliveryType_SNY := ShopifyFullfillmentSetup."Final Delivery Type";
                            //location code update only for inventory items--start
                            item.Get(SalesLine2."No.");
                            if item.Type = item.Type::Inventory then
                                SalesLine2."Location Code" := ShopifyFullfillmentSetup."Final Location"
                            else
                                SalesLine2."Location Code" := '';
                            //--end
                            //SalesLine2."Location Code" := ShopifyFullfillmentSetup."Final Location";
                        end;
                        SalesLine2.Modify();

                    until SalesLine2.next() = 0;
                //

                if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Not Started" then begin
                    SalesHeader.INT_OrderStatus_SNY := SalesHeader.INT_OrderStatus_SNY::"In-Process";
                    SalesHeader."Requested Delivery Date" := 0D;
                    SalesHeader.INT_BCOrderNo_SNY := SalesHeader."No.";

                    ShopifyFullfillmentSetup.Reset;
                    ShopifyFullfillmentSetup.SetRange(ShippingProfile, SalesHeader.INT_ShippingProfile_SNY);
                    if ShopifyFullfillmentSetup.FindSet() then begin
                        SalesLine.Reset;
                        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                        SalesLine.SetRange("Document No.", SalesHeader."No.");
                        if Salesline.findfirst() then
                            repeat
                                ShopifyFullfillmentSetup.SetRange(FulfilmentLocation, Salesline.INT_FulfilmentLocation_SNY);
                                if ShopifyFullfillmentSetup.findset then begin
                                    if ShopifyFullfillmentSetup.count() > 1 then begin
                                        if ShopifyFullfillmentSetup."Inventory Check" = true then
                                            if FullfillmentInventoryCheck(SalesLine, ShopifyFullfillmentSetup."Final Location") then begin
                                                ShopifyFullfillmentSetup.next(1);
                                                if not FullfillmentInventoryCheck(SalesLine, ShopifyFullfillmentSetup."Final Location") then begin
                                                    //location code update only for inventory items--start
                                                    item.Get(SalesLine."No.");
                                                    if item.Type = item.Type::Inventory then
                                                        SalesLine."Location Code" := ShopifyFullfillmentSetup."Final Location"
                                                    else
                                                        SalesLine."Location Code" := '';
                                                    //--end
                                                    // SalesLine."Location Code" := ShopifyFullfillmentSetup."Final Location";
                                                    SalesLine.INT_DeliveryType_SNY := ShopifyFullfillmentSetup."Final Delivery Type";
                                                    SalesLine.Modify;
                                                end
                                            end;
                                    end else begin
                                        SalesLine.INT_DeliveryType_SNY := ShopifyFullfillmentSetup."Final Delivery Type";
                                        //location code update only for inventory items--start
                                        item.Get(SalesLine."No.");
                                        if item.Type = item.Type::Inventory then
                                            SalesLine."Location Code" := ShopifyFullfillmentSetup."Final Location"
                                        else
                                            SalesLine."Location Code" := '';
                                        //--end
                                        //SalesLine."Location Code" := ShopifyFullfillmentSetup."Final Location";
                                        SalesLine.Modify;
                                    end;
                                end
                            until Salesline.next() = 0;
                        commit;
                    end;
                    SplitByDeliveryType2();
                    Commit();
                end;
                if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Delivery Split Completed" then begin
                    SplitByItemType2();
                    Commit();
                end;

                //Copy from Here for reprocess umang
                if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split" then begin
                    ExplodeOrder2();
                    Commit();
                end;

                if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Explode SO" then begin
                    //InsertDeliveryFee2();
                    //Commit();
                end;

                if (SalesHeader.INT_InternalProcessing_SNY in [SalesHeader.INT_InternalProcessing_SNY::"Explode SO", SalesHeader.INT_InternalProcessing_SNY::Presales])
                        and (SalesHeader.INT_OrderType_SNY = SalesHeader.INT_OrderType_SNY::Presale) then begin
                    ProcessPreslaesOrder();

                    Commit();
                end;

                if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Inventory N/A" then begin
                    CheckInventory();
                    Commit();
                end;
                //SellVoucherCalculate 
                SalesHeader.CalcFields(Amount);
                if (SalesHeader."Seller Voucher Amount" <> 0) and (SalesHeader."Amount" <> 0) then begin
                    SellVoucherCalculate();
                end;
                //SellVoucherCalculate

                if (SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Inventory Checked")
                 and (not SalesHeader.INT_DelConfirmed_SNY) then begin
                    DeliveryConfirm2(false);
                    Commit();
                end;

                if ((SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Inventory Checked")
                        and ((SalesHeader.INT_OrderStatus_SNY = SalesHeader.INT_OrderStatus_SNY::Delivered)
                            or (SalesHeader.INT_OrderStatus_SNY = SalesHeader.INT_OrderStatus_SNY::Shipped)
                            or (SalesHeader.INT_OrderStatus_SNY = SalesHeader.INT_OrderStatus_SNY::Failed)
                            or (SalesHeader.INT_OrderStatus_SNY = SalesHeader.INT_OrderStatus_SNY::Returned)
                        )) then begin
                    SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::Completed;
                    Commit;
                end;

                /*
                if ((SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Inventory Checked") or
                    (SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::Completed))
                    and (SalesHeader.INT_SimpleStatus_SNY = SalesHeader.INT_SimpleStatus_SNY::"Not Started") then begin
                    SynctoSAP(false);
                end;
                */

                if InterfaceSetup."Auto Set Lazada Inv" then
                    if SalesHeader.INT_InvCheck_SNY then begin
                        Commit();
                        clear(UpdateStatus);
                        UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                        UpdateStatus.SetOrder(UpdateSalesHeader, 10);
                        if not UpdateStatus.Run() then begin
                            UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                            UpdateSalesHeader.INT_ProcessErr_SNY := GetLastErrorText;
                            UpdateSalesHeader.Modify();
                        end;
                        Commit();
                        clear(UpdateStatus);
                        UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                        UpdateStatus.SetOrder(UpdateSalesHeader, 20);
                        if not UpdateStatus.run() then begin
                            UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                            UpdateSalesHeader.INT_ProcessErr_SNY := GetLastErrorText;
                            UpdateSalesHeader.Modify();
                            Commit();
                        end;
                    end;

                if SalesHeader.INT_SAPOrderID_SNY <> '' then
                    PostingShipments();

            end else begin   //Regular/LAZADA Process
                if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Not Started" then begin
                    SalesHeader.INT_OrderStatus_SNY := SalesHeader.INT_OrderStatus_SNY::"In-Process";
                    SalesHeader."Requested Delivery Date" := 0D;
                    SalesHeader.INT_BCOrderNo_SNY := SalesHeader."No.";
                    SplitByDeliveryType();
                    Commit();
                end;
                if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Delivery Split Completed" then begin
                    SplitByItemType();
                    Commit();
                end;

                //Copy from Here for reprocess umang
                if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split" then begin
                    ExplodeOrder();
                    Commit();
                end;

                if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Explode SO" then begin
                    //InsertDeliveryFee();
                    skipInsertDeliveryFee();
                    Commit();
                end;

                //SellVoucherCalculate test1
                SalesHeader.CalcFields(Amount);
                if (SalesHeader."Seller Voucher Amount" <> 0) and (SalesHeader."Amount" <> 0) then begin
                    SellVoucherCalculate();
                end;
                //SellVoucherCalculate test1

                if (SalesHeader.INT_InternalProcessing_SNY in [SalesHeader.INT_InternalProcessing_SNY::"Explode SO", SalesHeader.INT_InternalProcessing_SNY::Presales])
                        and (SalesHeader.INT_OrderType_SNY = SalesHeader.INT_OrderType_SNY::Presale) then begin
                    ProcessPreslaesOrder();

                    Commit();
                end;

                if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Inventory N/A" then begin
                    CheckInventory();
                    Commit();
                end;

                if (SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Inventory Checked")
                 and (not SalesHeader.INT_DelConfirmed_SNY) then begin
                    DeliveryConfirm(false);
                    Commit();
                end;

                if ((SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Inventory Checked")
                        and ((SalesHeader.INT_OrderStatus_SNY = SalesHeader.INT_OrderStatus_SNY::Delivered)
                            or (SalesHeader.INT_OrderStatus_SNY = SalesHeader.INT_OrderStatus_SNY::Shipped)
                            or (SalesHeader.INT_OrderStatus_SNY = SalesHeader.INT_OrderStatus_SNY::Failed)
                            or (SalesHeader.INT_OrderStatus_SNY = SalesHeader.INT_OrderStatus_SNY::Returned)
                        )) then begin
                    SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::Completed;
                    Commit;
                end;

                /*
                if ((SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Inventory Checked") or
                    (SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::Completed))
                    and (SalesHeader.INT_SimpleStatus_SNY = SalesHeader.INT_SimpleStatus_SNY::"Not Started") then begin
                    SynctoSAP(false);
                end;
                */

                if InterfaceSetup."Auto Set Lazada Inv" then
                    if SalesHeader.INT_InvCheck_SNY then begin
                        Commit();
                        clear(UpdateStatus);
                        UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                        UpdateStatus.SetOrder(UpdateSalesHeader, 10);
                        if not UpdateStatus.Run() then begin
                            UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                            UpdateSalesHeader.INT_ProcessErr_SNY := GetLastErrorText;
                            UpdateSalesHeader.Modify();
                        end;
                        Commit();
                        clear(UpdateStatus);
                        UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                        UpdateStatus.SetOrder(UpdateSalesHeader, 20);
                        if not UpdateStatus.run() then begin
                            UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                            UpdateSalesHeader.INT_ProcessErr_SNY := GetLastErrorText;
                            UpdateSalesHeader.Modify();
                            Commit();
                        end;
                    end;

                if SalesHeader.INT_SAPOrderID_SNY <> '' then
                    PostingShipments();
            end

        end else
            if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then begin

                MarketPlace.Get(SalesHeader.INT_MarketPlace_SNY);
                if MarketPlace."Process ID" = 1 then begin
                    if SalesHeader.INT_OrderStatus_SNY < SalesHeader.INT_OrderStatus_SNY::Processed then begin
                        ProcessReturnOrder2();
                        FullfillmentReturnOrder(SalesHeader);
                        ReturnExplodeOrder2();
                        //ReturnInsertDeliveryFee();
                    end;
                    /*
                    if (SalesHeader.INT_OrderStatus_SNY >= SalesHeader.INT_OrderStatus_SNY::Processed) and
                      (SalesHeader.INT_SimpleStatus_SNY = SalesHeader.INT_SimpleStatus_SNY::"Not Started") then
                        NotifySAPForReturn();
                        */
                end else
                    if SalesHeader.INT_OrderStatus_SNY < SalesHeader.INT_OrderStatus_SNY::Processed then
                        ProcessReturnOrder();
            end;

    end;

    var
        SalesHeader: Record "Sales Header";
        OrderCollectionForReReun: Record "Sales Header" temporary;
        JobQueueEntry: Record "Job Queue Entry";

        SalesSetup: Record "Sales & Receivables Setup";
        AlertMgmt: Codeunit INT_AlertMgnt_SNY;
        INT_salesline3: Record "Sales Line";
        INT_salesline4: Record "Sales Line";
        checkLine: Integer;
        checkLine2: Integer;
        INT_item: Record item;
        SellVourcher: Decimal;
        calculatelineamount: Decimal;

    local procedure PostingShipments()
    var
        SalesLine: Record "Sales Line";
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.setfilter("Outstanding Quantity", '<>0');
        if SalesLine.IsEmpty() then
            exit;
        SalesHeader.Ship := true;
        SalesHeader.Invoice := false;
        SalesHeader.Modify();
        SalesPost.Run(SalesHeader);
        SalesHeader.Status := SalesHeader.Status::Open;
        SalesHeader.Modify();
    end;

    local procedure ProcessReturnOrder()
    var
        SalesHeader2: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        NewSalesLine: Record "Sales Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        LineNo: Integer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        HaveSAPId: Boolean;
    begin
        //Get SAP Invoice ID
        SalesSetup.get();
        SalesSetup.TestField(INT_ReturnCode_SNY);
        HaveSAPId := false;
        if SalesHeader.INT_SAPInvoiceID_SNY = '' then begin
            SalesLine.reset();
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.setrange("Document No.", SalesHeader."No.");
            SalesLine.FindLast();
            SalesLine.RESET();

            SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
            Salesline.setrange(INT_OrderId_SNY, SalesHeader.INT_MktplaceOrderID_SNY);
            SalesLine.SETRANGE(INT_MktOrderLineID_SNY, SalesLine.INT_MktOrderLineID_SNY);
            SalesLine.SetRange("Document No.");

            IF SalesLine.FindFirst() THEN begin
                SalesHeader2.get(SalesLine."Document Type", SalesLine."Document No.");
                HaveSAPId := SalesHeader2.INT_SAPInvoiceID_SNY <> '';
            end;
            if not HaveSAPId then begin
                SalesShipmentLine.Reset();
                SalesShipmentLine.SETRANGE(int_orderid_sny, SalesHeader.INT_MktplaceOrderID_SNY);
                SalesShipmentLine.SETRANGE(INT_MktOrderLineID_SNY, SalesLine.INT_MktOrderLineID_SNY);
                HaveSAPId := (not SalesShipmentLine.IsEmpty());
                SalesShipmentHeader.Init();
                if HaveSAPId then begin
                    SalesShipmentLine.FindFirst();
                    SalesShipmentHeader.get(SalesShipmentLine."Document No.");
                end;
                SalesHeader2.TransferFields(SalesShipmentHeader);

            end;
            if HaveSAPId then begin
                SalesHeader.INT_SAPInvoiceID_SNY := SalesHeader2.INT_SAPInvoiceID_SNY;
                SalesHeader.INT_SAPOrderID_SNY := SalesHeader2.INT_SAPOrderID_SNY;
                SalesHeader.Modify();
            end;

        end;
        //Code to pick SAP Invoice ID from Sales Invoice 13/Oct/2020
        if SalesHeader.INT_SAPInvoiceID_SNY = '' then begin
            SalesInvoiceLine.Reset();
            SalesInvoiceLine.SETRANGE(int_orderid_sny, SalesHeader.INT_MktplaceOrderID_SNY);
            SalesInvoiceLine.SETRANGE(INT_MktOrderLineID_SNY, SalesLine.INT_MktOrderLineID_SNY);
            // HaveSAPId := (not SalesInvoiceLine.IsEmpty());
            SalesInvoiceHeader.Init();
            // if HaveSAPId then begin
            if SalesInvoiceLine.FindFirst() then begin
                SalesInvoiceHeader.get(SalesInvoiceLine."Document No.");
                // end;
                // SalesHeader2.TransferFields(SalesShipmentHeader);
                SalesHeader.INT_SAPInvoiceID_SNY := SalesInvoiceHeader.INT_SAPInvoiceID_SNY;
                SalesHeader.INT_SAPOrderID_SNY := SalesInvoiceHeader.INT_SAPOrderID_SNY;
                SalesHeader.Modify();
            end;

        end;
        if SalesHeader.INT_SAPInvoiceID_SNY = '' then begin
            if SalesHeader2.INT_BCOrderNo_SNY <> '' then begin
                SalesHeader.INT_BCOrderNo_SNY := SalesHeader2.INT_BCOrderNo_SNY;
                SalesHeader.Modify();
            end;
            clear(AlertMgmt);
            JobQueueEntry."Parameter String" := 'CHECK_RET_SAPINV';
            AlertMgmt.SetSalesHeader(SalesHeader);
            Commit();//added to remove codeunit call error
            if not AlertMgmt.Run(JobQueueEntry) then begin//begin end added
                Message('Unable to Send missing SAP Invoice Id alert:\Error:', GetLastErrorText);
                exit;
            end;
        end;

        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.FindLast();
        LineNo := SalesLine."Line No." + 10000;
        SalesLine.setrange("Line No.", 0, LineNo - 1);
        if SalesLine.FindFirst() then
            repeat
                if (SalesLine.INT_OrderId_SNY <> '') and (salesline.INT_MktOrderLineID_SNY <> '') then begin
                    SalesLine2.reset();
                    SalesLine2.SetRange("Document Type", SalesLine2."Document Type"::Order);
                    SalesLine2.setrange(INT_OrderId_SNY, SalesLine.INT_OrderId_SNY);
                    SalesLine2.SetRange(INT_MktOrderLineID_SNY, SalesLine.INT_MktOrderLineID_SNY);
                    SalesLine2.SetFilter("No.", '<>%1', SalesLine."No.");
                    if SalesLine2.FindFirst() then
                        repeat
                            InsertReturnSalesLine(SalesLine2, SalesHeader, NewSalesLine, LineNo);
                            LineNo += 10000;
                        until SalesLine2.Next() = 0
                    else begin
                        SalesShipmentLine.Reset();
                        SalesShipmentLine.setrange(INT_OrderId_SNY, SalesLine.INT_OrderId_SNY);
                        SalesShipmentLine.SetRange(INT_MktOrderLineID_SNY, SalesLine.INT_MktOrderLineID_SNY);
                        SalesShipmentLine.SetFilter("No.", '<>%1', SalesLine."No.");
                        if SalesShipmentLine.FindSet() then
                            repeat
                                SalesLine2.TransferFields(SalesShipmentLine);
                                InsertReturnSalesLine(SalesLine2, SalesHeader, NewSalesLine, LineNo);
                                LineNo += 10000;
                            until SalesShipmentLine.Next() = 0;
                    end;
                end;
            until SalesLine.Next() = 0;

        SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::Completed;
        SalesHeader.INT_InvCheck_SNY := true;
        SalesHeader.INT_OrderStatus_SNY := SalesHeader.INT_OrderStatus_SNY::Processed;

        SalesHeader.Modify();


        Commit();

    end;

    local procedure InsertReturnSalesLine(FromSalesLine: Record "Sales Line"; ToSalesHeader: Record "Sales header"; var NewSalesLine: Record "Sales Line"; LineNo: Integer)
    begin
        NewSalesLine.init();
        NewSalesLine."Document Type" := ToSalesHeader."Document Type";
        NewSalesLine."Document No." := ToSalesHeader."No.";
        NewSalesLine."Line No." := LineNo;
        NewSalesLine.Insert(true);
        NewSalesLine.Validate(type, FromSalesLine.Type);
        NewSalesLine.Validate("No.", FromSalesLine."No.");
        NewSalesLine.validate(Quantity, FromSalesLine.Quantity);
        NewSalesLine.validate("unit price", FromSalesLine."Unit Price");
        NewSalesLine."INT_Bundle Order No._SNY" := FromSalesLine."INT_Bundle Order No._SNY";
        NewSalesLine.INT_DeliveryType_SNY := FromSalesLine.INT_DeliveryType_SNY;
        NewSalesLine.INT_MktOrderLineID_SNY := FromSalesLine.INT_MktOrderLineID_SNY;
        NewSalesLine.INT_MktOrdStatus_SNY := FromSalesLine.INT_MktOrdStatus_SNY;
        NewSalesLine.INT_RelatedItemType_SNY := FromSalesLine.INT_RelatedItemType_SNY;
        NewSalesLine.INT_RelatedItemNo_SNY := FromSalesLine.INT_RelatedItemNo_SNY;
        NewSalesLine.INT_RelOrderLineNo_SNY := FromSalesLine.INT_RelOrderLineNo_SNY;
        NewSalesLine.INT_OrderId_SNY := FromSalesLine.INT_OrderId_SNY;
        NewSalesLine.INT_MktOrderLineID_SNY := FromSalesLine.INT_MktOrderLineID_SNY;
        NewSalesLine."Return Reason Code" := SalesSetup.INT_ReturnCode_SNY;
        NewSalesLine.Modify(true)
    end;

    local procedure NotifySAPForReturn()
    var
        sapapi: Codeunit INT_SAPAPI_SNY;
        SalesLine: Record "Sales Line";
    begin

        // SalesLine.reset();
        // SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        // SalesLine.setrange("Document No.", SalesHeader."No.");
        // SalesLine.SetRange(Type, SalesLine.Type::Item);
        // SalesLine.SetFilter(INT_DeliveryType_SNY, '%1', Salesline.INT_DeliveryType_SNY::"DBS Home");
        // if SalesLine.IsEmpty() then
        //     Exit;

        IF SalesHeader."Requested Delivery Date" = 0D THEN
            SalesHeader."Requested Delivery Date" := Today();

        SAPAPI.NotifySAP(SalesHeader, false);
        SalesHeader.INT_SimpleStatus_SNY := SalesHeader.INT_SimpleStatus_SNY::"Ready for Pick";
        SalesHeader.Modify();
    end;

    procedure SetOrder(pSalesHeader: Record "Sales Header")
    begin
        SalesHeader.get(pSalesHeader."Document Type", pSalesHeader."No.");
    end;

    local procedure CreateHeader(var NewSalesHeader: Record "Sales Header")
    var
    begin
        NewSalesHeader := SalesHeader;
        NewSalesHeader."No." := '';
        NewSalesHeader.Insert(true);
        NewSalesHeader.validate("Location Code", SalesHeader."Location Code");
        NewSalesHeader.Modify(true);
    end;

    local procedure FullfillmentCreateHeader(var NewSalesHeader: Record "Sales Header")
    var
        Marketplace: Record INT_MarketPlaces_SNY;
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        Marketplace.Get(SalesHeader.INT_MarketPlace_SNY);
        NewSalesHeader := SalesHeader;
        NewSalesHeader."No." := NoSeriesManagement.GetNextNo(Marketplace."Sales Order Nos.", 0D, true);
        NewSalesHeader.Insert(true);
        NewSalesHeader.validate("Location Code", SalesHeader."Location Code");
        NewSalesHeader.Modify(true);
    end;

    local procedure CreateLines(NewSalesHeader: Record "Sales Header"; var SalesLines: Record "Sales Line")
    var
        NewSalesLine: Record "Sales Line";
    begin
        if SalesLines.FindSet() then
            repeat
                NewSalesLine := SalesLines;
                NewSalesLine."Document No." := NewSalesHeader."No.";
                NewSalesLine.Insert(true);
            until SalesLines.Next() = 0;
    end;

    procedure SplitByOrderType()
    var
        SalesLine: Record "Sales Line";
        NewSalesHeader: Record "Sales Header";
        NewSalesLine: Record "Sales Line";
        Item: Record Item;
        NormalOrderExist: Boolean;
        PresalesExist: Boolean;

    begin
        clear(NormalOrderExist);
        clear(PresalesExist);
        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                item.get(SalesLine."No.");
                if item.INT_OrderType_SNY = item.INT_OrderType_SNY::Normal then
                    SalesLine.INT_OrderType_SNY := SalesLine.INT_OrderType_SNY::Normal
                else
                    SalesLine.INT_OrderType_SNY := SalesLine.INT_OrderType_SNY::Presale;
                SalesLine.Modify();
            until SalesLine.Next() = 0;

        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter(INT_OrderType_SNY, '%1', SalesLine.INT_OrderType_SNY::Normal);
        NormalOrderExist := not SalesLine.IsEmpty();

        SalesLine.SetFilter(INT_OrderType_SNY, '%1', SalesLine.INT_OrderType_SNY::Presale);
        PresalesExist := not SalesLine.IsEmpty();

        if PresalesExist and NormalOrderExist then begin
            SalesLine.SetFilter(INT_OrderType_SNY, '%1', SalesLine.INT_OrderType_SNY::Normal);
            CreateHeader(NewSalesHeader);
            CreateLines(NewSalesHeader, SalesLine);
            SalesLine.FindSet();
            SalesLine.DeleteAll(true);
            NewSalesHeader.INT_BCOrderNo_SNY := SalesHeader."No.";
            NewSalesHeader.INT_OrderType_SNY := NewSalesHeader.INT_OrderType_SNY::Normal;
            NewSalesHeader.INT_SplitInfo_SNY := 'Split';
            SalesHeader.INT_SplitInfo_SNY := 'Split';
            NewSalesHeader.Modify();
        end else
            if PresalesExist then
                SalesHeader.INT_OrderType_SNY := NewSalesHeader.INT_OrderType_SNY::Presale
            else
                SalesHeader.INT_OrderType_SNY := NewSalesHeader.INT_OrderType_SNY::Normal;
        SalesHeader.INT_BCOrderNo_SNY := SalesHeader."No.";
        SalesHeader.Modify(true);
    end;

    procedure SplitByDeliveryType()
    var
        SalesLine: Record "Sales Line";
        NewSalesHeader: Record "Sales Header";
        NewSalesLine: Record "Sales Line";
        NormalExist: Boolean;
        DBSExist: Boolean;
        DBSHomeEXist: Boolean;
    begin
        SplitByOrderType();
        clear(NormalExist);
        clear(DBSExist);
        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter(INT_DeliveryType_SNY, '%1', Salesline.INT_DeliveryType_SNY::"DBS Home");
        DBSHomeEXist := not SalesLine.IsEmpty();

        SalesLine.SetFilter(INT_DeliveryType_SNY, '%1|%2', Salesline.INT_DeliveryType_SNY::"DBS Home", SalesLine.INT_DeliveryType_SNY::"DBS Standard");
        DBSExist := not SalesLine.IsEmpty();
        SalesLine.SetFilter(INT_DeliveryType_SNY, '%1', Salesline.INT_DeliveryType_SNY::Standard);
        NormalExist := not SalesLine.IsEmpty();

        if NormalExist and DBSExist then begin
            SalesLine.SetFilter(INT_DeliveryType_SNY, '%1|%2', Salesline.INT_DeliveryType_SNY::"DBS Home", SalesLine.INT_DeliveryType_SNY::"DBS Standard");
            CreateHeader(NewSalesHeader);
            CreateLines(NewSalesHeader, SalesLine);
            SalesLine.FindSet();
            SalesLine.DeleteAll(true);
            NewSalesHeader.INT_InternalProcessing_SNY := NewSalesHeader.INT_InternalProcessing_SNY::"Delivery Split Completed";
            NewSalesHeader.INT_BCOrderNo_SNY := SalesHeader."No.";
            if DBSHomeEXist then
                NewSalesHeader.INT_DeliveryType_SNY := NewSalesHeader.INT_DeliveryType_SNY::"DBS Home"
            else
                NewSalesHeader.INT_DeliveryType_SNY := NewSalesHeader.INT_DeliveryType_SNY::"DBS Standard";
            NewSalesHeader.INT_SplitInfo_SNY := 'Split';
            NewSalesHeader.Modify();
            SalesHeader.INT_SplitInfo_SNY := 'Split';
        end;


        SalesHeader.INT_BCOrderNo_SNY := SalesHeader.INT_BCOrderNo_SNY;
        if (NormalExist and DBSExist) then
            SalesHeader.INT_DeliveryType_SNY := SalesHeader.INT_DeliveryType_SNY::Standard
        else
            if (NormalExist and not DBSExist) then
                SalesHeader.INT_DeliveryType_SNY := SalesHeader.INT_DeliveryType_SNY::Standard
            else
                if DBSHomeEXist then
                    SalesHeader.INT_DeliveryType_SNY := SalesHeader.INT_DeliveryType_SNY::"DBS Home"
                else
                    SalesHeader.INT_DeliveryType_SNY := SalesHeader.INT_DeliveryType_SNY::"DBS Standard";
        SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"Delivery Split Completed";
        SalesHeader.Modify(true);
    end;

    procedure SplitByItemType()
    var
        NewSalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        NormalExist: Boolean;
        PSGExist: Boolean;
        BunExist: Boolean;
        Amount: Decimal;
        Qty: Decimal;
    begin
        //SalesLine.INT_ItemType_SNY::
        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange(INT_ItemType_SNY, SalesLine.INT_ItemType_SNY::NPG);
        NormalExist := not SalesLine.IsEmpty();
        SalesLine.SetRange(INT_ItemType_SNY, SalesLine.INT_ItemType_SNY::PGS);
        PSGExist := not SalesLine.IsEmpty();
        SalesLine.SetRange(INT_ItemType_SNY, SalesLine.INT_ItemType_SNY::BUN);
        BunExist := not SalesLine.IsEmpty();
        if NormalExist and (BunExist or PSGExist) then begin
            //Split Normal Orders
            SalesLine.SetRange(INT_ItemType_SNY, SalesLine.INT_ItemType_SNY::NPG);
            CreateHeader(NewSalesHeader);
            CreateLines(NewSalesHeader, SalesLine);

            NewSalesHeader.INT_InternalProcessing_SNY := NewSalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split";
            NewSalesHeader.INT_BCOrderNo_SNY := SalesHeader.INT_BCOrderNo_SNY;
            NewSalesHeader.INT_SplitInfo_SNY := 'Split';
            SalesHeader.INT_SplitInfo_SNY := 'Split';
            NewSalesHeader.Modify();
            SalesLine.FindSet();
            SalesLine.Deleteall();

        end;
        if (BunExist or PSGExist) then begin
            //Check Conditions 
            Qty := 0;
            SalesLine.SetRange(INT_ItemType_SNY);//, SalesLine.INT_ItemType_SNY::BUN);
            if SalesLine.FindSet() then
                repeat
                    if SalesLine.INT_ItemType_SNY = SalesLine.INT_ItemType_SNY::BUN then
                        Qty += SalesLine.Quantity
                    else
                        if SalesLine.INT_ItemType_SNY = SalesLine.INT_ItemType_SNY::PGS then
                            Amount += SalesLine.Amount;
                until SalesLine.Next() = 0;
            if (Qty > 140) or (Amount > 10000) then begin
                clear(AlertMgmt);
                JobQueueEntry."Parameter String" := 'CHECK_BUNDLE_SPLIT';
                AlertMgmt.SetSalesHeader(SalesHeader);
                if not AlertMgmt.Run(JobQueueEntry) then
                    Message('Unable to Send Manual Bundle Split alert:\Error:', GetLastErrorText);
            end else
                if BunExist and PSGExist then begin
                    SalesLine.SetRange(INT_ItemType_SNY, SalesLine.INT_ItemType_SNY::BUN);
                    CreateHeader(NewSalesHeader);
                    CreateLines(NewSalesHeader, SalesLine);
                    SalesLine.DeleteAll(true);
                    NewSalesHeader.INT_InternalProcessing_SNY := NewSalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split";
                    NewSalesHeader.INT_BCOrderNo_SNY := SalesHeader.INT_BCOrderNo_SNY;
                    NewSalesHeader.INT_SplitInfo_SNY := 'Split';
                    NewSalesHeader.Modify();
                    SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split";
                    SalesHeader.INT_SplitInfo_SNY := 'Split';
                    SalesHeader.Modify();
                end else begin
                    SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split";
                    SalesHeader.Modify();
                end;
        end else begin
            SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split";
            SalesHeader.Modify();
        end;
    end;

    procedure ExplodeOrder()
    var
        SalesLine: Record "Sales Line";
        BundleHeader: Record INT_BundleHeader_SNY;
        BundleLine: Record INT_BundleLine_SNY;
        FocBundleHeader: Record INT_BundleHeader_SNY;
        FocBundleLine: Record INT_BundleLine_SNY;
        NewSalesLine: Record "Sales Line";

        Item: Record Item;
        BundleAmount: Decimal;
        NewLineNo: Integer;
        MainModelLineNo: Integer;
        HaveBundleHeader: Boolean;
        HaveFocBundleHeader: Boolean;
        BundlePackageDetailsErr: Label 'Bundle Details could not found package no. %1';
    begin
        //Explode Bundle
        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            NewLineNo := SalesLine."Line No." + 10000
        ELSE
            NewLineNo := 10000;
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange(INT_RelatedItemType_SNY, SalesLine.INT_RelatedItemType_SNY::Main);
        SalesLine.SetRange("Line No.", 0, NewLineNo - 1);
        if SalesLine.findset() then
            repeat

                item.get(SalesLine."No.");
                if item.INT_MainModel_SNY <> '' then begin
                    MainModelLineNo := 0;
                    BundleAmount := 0;
                    BundleHeader.Reset();
                    BundleHeader.SETRANGE(Marketplace, SalesHeader.INT_MarketPlace_SNY);
                    BundleHeader.Setrange(Type, BundleHeader.Type::Package);
                    BundleHeader.Setrange("Item No.", SalesLine."No.");
                    BundleHeader.SetFilter(Status, '%1|%2', BundleHeader.Status::Certified, BundleHeader.Status::Expired);
                    if 1 = 1 then begin

                        HaveBundleHeader := false;
                        if BundleHeader.FindFirst() then
                            repeat
                                if SalesHeader."Order Date" in [BundleHeader."Starting Date" .. BundleHeader."Ending Date"] then
                                    HaveBundleHeader := true;
                            until (BundleHeader.Next() = 0) or HaveBundleHeader = true;
                    end else
                        HaveBundleHeader := true;
                    if not HaveBundleHeader then
                        Error(BundlePackageDetailsErr, SalesLine."No.");
                    BundleLine.Reset();
                    BundleLine.SetRange(Type, BundleHeader.Type);
                    BundleLine.SetRange("No.", BundleHeader."No.");
                    if BundleLine.FindSet() then
                        repeat
                            newsalesline := SalesLine;
                            NewSalesLine.INT_RelatedItemType_SNY := BundleLine."Related Item Type";
                            NewSalesLine.INT_RelatedItemNo_SNY := BundleLine."Related Item No.";
                            NewSalesLine."Line No." := NewLineNo;
                            NewLineNo += 10000;
                            NewSalesLine.insert(true);
                            NewSalesLine.validate("No.", BundleLine."Item No.");
                            NewSalesLine.validate(Quantity, BundleLine.Quantity);
                            if BundleLine."Promotional Price" <> 0 then
                                NewSalesLine.validate("Unit Price", BundleLine."Promotional Price" / BundleLine.Quantity)
                            else
                                NewSalesLine.validate("Unit Price", BundleLine."SRP Price" / BundleLine.Quantity);

                            NewSalesLine."INT_Bundle Order No._SNY" := BundleLine."No.";
                            NewSalesLine.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;
                            NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                            NewSalesLine.INT_MktOrdStatus_SNY := SalesLine.INT_MktOrdStatus_SNY;
                            NewSalesLine.INT_RelatedItemType_SNY := BundleLine."Related Item Type";
                            NewSalesLine.INT_RelatedItemNo_SNY := BundleLine."Related Item No.";
                            NewSalesLine.INT_RelOrderLineNo_SNY := SalesLine."Line No.";
                            NewSalesLine.INT_OrderId_SNY := SalesLine.INT_OrderId_SNY;
                            NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;

                            NewSalesLine.INT_DeliverFee_SNY := 0;
                            BundleAmount += NewSalesLine."Line Amount";
                            NewSalesLine.Modify(true);
                            if (MainModelLineNo = 0) and BundleLine."Main Item for Delivery" then
                                MainModelLineNo := NewSalesLine."Line No.";

                            if BundleLine."Main Item for Delivery" then begin
                                Item.get(BundleLine."Item No.");
                                item.TestField("Retail Product Code");
                                SalesLine."Retail Product Code" := item."Retail Product Code";
                                SalesLine.Org_INT_RelatedItemType_SNY := SalesLine.INT_RelatedItemType_SNY;//US 25nov2020
                                SalesLine.INT_RelatedItemType_SNY := SalesLine.INT_RelatedItemType_SNY::Virtual;
                                SalesLine.INT_RelatedItemNo_SNY := BundleLine."Item No.";
                                SalesLine.Modify();
                            end;
                            if BundleLine."Explode FOC Item" then begin
                                HaveFocBundleHeader := false;
                                FocBundleHeader.Reset();
                                FocBundleHeader.SETRANGE(Marketplace, SalesHeader.INT_MarketPlace_SNY);
                                FocBundleHeader.Setrange(Type, FocBundleHeader.Type::FOC);
                                FocBundleHeader.Setrange("Item No.", BundleLine."Item No.");
                                //FocBundleHeader.SetFilter(Status, '%1|%2', FocBundleHeader.Status::Certified, FocBundleHeader.Status::Expired);
                                if FocBundleHeader.FindFirst() then
                                    repeat

                                        HaveFocBundleHeader := (SalesHeader."Order Date" in [FocBundleHeader."Starting Date" .. FocBundleHeader."Ending Date"]) and (BundleHeader."Is Active" = true);

                                        if HaveFocBundleHeader then begin
                                            FocBundleLine.Reset();
                                            FocBundleLine.SetRange(Type, FocBundleHeader.Type);
                                            FocBundleLine.SetRange("No.", FocBundleHeader."No.");
                                            if FocBundleLine.FindSet() then
                                                repeat
                                                    newsalesline := SalesLine;
                                                    NewSalesLine.INT_RelatedItemType_SNY := FocBundleLine."Related Item Type";
                                                    NewSalesLine.INT_RelatedItemNo_SNY := FocBundleLine."Related Item No.";
                                                    NewSalesLine."Line No." := NewLineNo;
                                                    NewLineNo += 10000;
                                                    NewSalesLine.insert(true);
                                                    NewSalesLine.validate("No.", FocBundleLine."Item No.");
                                                    NewSalesLine.validate(Quantity, FocBundleLine.Quantity);
                                                    if FocBundleLine."Promotional Price" <> 0 then
                                                        NewSalesLine.validate("Unit Price", FocBundleLine."Promotional Price" / FocBundleLine.Quantity)
                                                    else
                                                        NewSalesLine.validate("Unit Price", FocBundleLine."SRP Price" / FocBundleLine.Quantity);

                                                    NewSalesLine."INT_Bundle Order No._SNY" := FocBundleLine."No.";
                                                    NewSalesLine.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;
                                                    NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                                                    NewSalesLine.INT_MktOrdStatus_SNY := SalesLine.INT_MktOrdStatus_SNY;
                                                    NewSalesLine.INT_RelatedItemType_SNY := FocBundleLine."Related Item Type";
                                                    NewSalesLine.INT_RelatedItemNo_SNY := FocBundleLine."Related Item No.";
                                                    NewSalesLine.INT_RelOrderLineNo_SNY := SalesLine."Line No.";
                                                    NewSalesLine.INT_OrderId_SNY := SalesLine.INT_OrderId_SNY;
                                                    NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                                                    NewSalesLine.INT_DeliverFee_SNY := 0;
                                                    NewSalesLine.Modify(true);
                                                until FocBundleLine.Next() = 0;
                                        end;
                                    until (FocBundleHeader.Next() = 0);// or (HaveFocBundleHeader = true);
                            end;

                        until BundleLine.Next() = 0;


                    if BundleAmount <> SalesLine.Amount then begin
                        if MainModelLineNo = 0 then
                            Error('Bundle Main Model Not Defined');
                        NewSalesLine.get(SalesLine."Document Type", SalesLine."Document No.", MainModelLineNo);
                        NewSalesLine.Validate("Unit Price", (NewSalesLine."Line Amount" - (BundleAmount - SalesLine.Amount)) / NewSalesLine.Quantity);
                        NewSalesLine.Modify(true);
                    end;
                    SalesLine.Original_Quantity := SalesLine.Quantity;
                    SalesLine.Validate(Quantity, 0);
                    SalesLine.Modify(true);
                end;
            until SalesLine.Next() = 0;

        //Explore Foc
        SalesLine.SetFilter(INT_RelatedItemType_SNY, '<>%1&<>%2', SalesLine.INT_RelatedItemType_SNY::FOC, SalesLine.INT_RelatedItemType_SNY::"FOC Dummy");
        if SalesLine.FindSet() then
            repeat
                HaveBundleHeader := false;
                if SalesLine.Quantity <> 0 then begin
                    BundleHeader.Reset();
                    BundleHeader.SETRANGE(Marketplace, SalesHeader.INT_MarketPlace_SNY);
                    BundleHeader.Setrange(Type, BundleHeader.Type::FOC);
                    BundleHeader.Setrange("Item No.", SalesLine."No.");
                    //BundleHeader.SetFilter(Status, '%1|%2', BundleHeader.Status::Certified, BundleHeader.Status::Expired);
                    if BundleHeader.FindFirst() then
                        repeat
                            HaveBundleHeader := (SalesHeader."Order Date" in [BundleHeader."Starting Date" .. BundleHeader."Ending Date"]) and (BundleHeader."Is Active" = true);
                            if HaveBundleHeader then begin
                                BundleLine.Reset();
                                BundleLine.SetRange(Type, BundleHeader.Type);
                                BundleLine.SetRange("No.", BundleHeader."No.");
                                if BundleLine.FindSet() then
                                    repeat
                                        newsalesline := SalesLine;
                                        NewSalesLine.INT_RelatedItemType_SNY := BundleLine."Related Item Type";
                                        NewSalesLine.INT_RelatedItemNo_SNY := BundleLine."Related Item No.";
                                        NewSalesLine."Line No." := NewLineNo;
                                        NewLineNo += 10000;
                                        NewSalesLine.insert(true);
                                        NewSalesLine.validate("No.", BundleLine."Item No.");
                                        NewSalesLine.validate(Quantity, BundleLine.Quantity);
                                        if BundleLine."Promotional Price" <> 0 then
                                            NewSalesLine.validate("Unit Price", BundleLine."Promotional Price" / BundleLine.Quantity)
                                        else
                                            NewSalesLine.validate("Unit Price", BundleLine."SRP Price" / BundleLine.Quantity);

                                        NewSalesLine."INT_Bundle Order No._SNY" := BundleLine."No.";
                                        NewSalesLine.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;
                                        NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                                        NewSalesLine.INT_MktOrdStatus_SNY := SalesLine.INT_MktOrdStatus_SNY;
                                        NewSalesLine.INT_RelatedItemType_SNY := BundleLine."Related Item Type";
                                        NewSalesLine.INT_RelatedItemNo_SNY := BundleLine."Related Item No.";
                                        NewSalesLine.INT_RelOrderLineNo_SNY := SalesLine."Line No.";
                                        NewSalesLine.INT_OrderId_SNY := SalesLine.INT_OrderId_SNY;
                                        NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                                        NewSalesLine.INT_DeliverFee_SNY := 0;
                                        NewSalesLine.Modify(true);
                                    until BundleLine.Next() = 0;
                            end;
                        until (BundleHeader.Next() = 0);// or (HaveBundleHeader = true);


                end;
            until SalesLine.Next() = 0;
        SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"Explode SO";
        SalesHeader.Modify(true);
    end;

    procedure InsertDeliveryFee()
    var
        SalesLine: Record "Sales Line";
        NewSalesLine: Record "Sales Line";
        BundleSalesLine: Record "Sales Line";
        DeliveryModel: Record INT_DelDummyModel_SNY;
        Item: Record Item;
        NewLineNo: Integer;
        HavePresales: Boolean;
    begin
        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(type, SalesLine.Type::Item);
        if SalesLine.FindLast() then
            NewLineNo := SalesLine."Line No." + 10000
        else
            NewLineNo := 10000;
        SalesLine.setrange("INT_Delivery Line_SNY", false);
        //salesline.SetFilter(INT_DeliverFee_SNY, '>0');
        if SalesLine.FindSet() then
            repeat
                if SalesLine.INT_RelatedItemType_SNY = SalesLine.INT_RelatedItemType_SNY::Virtual then
                    Item.get(SalesLine.INT_RelatedItemNo_SNY)
                else
                    Item.get(SalesLine."No.");
                item.TestField("Retail Product Code");
                if not HavePresales then
                    HavePresales := SalesLine.INT_OrderType_SNY = SalesLine.INT_OrderType_SNY::Presale;
                if not DeliveryModel.get(Item."Retail Product Code") then
                    Error('Define Dummy Delivery Model for Retail Prorduct Group (6D Code) %1', item."Retail Product Code");

                DeliveryModel.TestField("Item No.");
                if SalesLine.INT_DeliverFee_SNY > 0 then begin
                    NewSalesLine.init();
                    NewSalesLine."Document Type" := SalesHeader."Document Type";
                    NewSalesLine."Document No." := SalesHeader."No.";
                    NewSalesLine."Line No." := NewLineNo;
                    NewSalesLine.Insert(true);
                    NewLineNo += 10000;
                    NewSalesLine.validate(type, newsalesline.type::Item);
                    NewSalesLine.validate("no.", DeliveryModel."Item No.");
                    NewSalesLine.validate(Quantity, 1);
                    NewSalesLine.validate("Unit Price", SalesLine.INT_DeliverFee_SNY);
                    NewSalesLine."INT_Delivery Line_SNY" := true;

                    NewSalesLine.INT_RelatedItemType_SNY := NewSalesLine.INT_RelatedItemType_SNY::"Main Delivery";

                    if SalesLine.INT_RelatedItemType_SNY = SalesLine.INT_RelatedItemType_SNY::Virtual then
                        NewSalesLine.INT_RelatedItemNo_SNY := SalesLine.INT_RelatedItemNo_SNY
                    else
                        NewSalesLine.INT_RelatedItemNo_SNY := SalesLine."No.";
                    NewSalesLine.INT_MktOrdStatus_SNY := SalesLine.INT_MktOrdStatus_SNY;
                    NewSalesLine.INT_MktOrderLineID_SNY := salesline.INT_MktOrderLineID_SNY;
                    NewSalesLine.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;
                    NewSalesLine.INT_OrderType_SNY := SalesLine.INT_OrderType_SNY;
                    NewSalesLine.INT_ItemType_SNY := SalesLine.INT_ItemType_SNY;
                    NewSalesLine.INT_OrderId_SNY := SalesLine.INT_OrderId_SNY;
                    NewSalesLine.Modify(true);
                end;
            until SalesLine.Next() = 0;
        if HavePresales then begin
            SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::Presales;
            SalesHeader.INT_OrderType_SNY := SalesHeader.INT_OrderType_SNY::Presale;
        end else
            SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"Inventory N/A";
        SalesHeader.Modify(true);

    end;
    //skip delivery fee
    procedure skipInsertDeliveryFee()
    var
        SalesLine: Record "Sales Line";
        NewSalesLine: Record "Sales Line";
        BundleSalesLine: Record "Sales Line";
        DeliveryModel: Record INT_DelDummyModel_SNY;
        Item: Record Item;
        NewLineNo: Integer;
        HavePresales: Boolean;
    begin

        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(type, SalesLine.Type::Item);
        // if SalesLine.FindLast() then
        //    NewLineNo := SalesLine."Line No." + 10000
        //else
        //    NewLineNo := 10000;
        //SalesLine.setrange("INT_Delivery Line_SNY", false);
        //salesline.SetFilter(INT_DeliverFee_SNY, '>0');
        if SalesLine.FindSet() then
            repeat
                if SalesLine.INT_RelatedItemType_SNY = SalesLine.INT_RelatedItemType_SNY::Virtual then
                    Item.get(SalesLine.INT_RelatedItemNo_SNY)
                else
                    Item.get(SalesLine."No.");
                item.TestField("Retail Product Code");
                if not HavePresales then
                    HavePresales := SalesLine.INT_OrderType_SNY = SalesLine.INT_OrderType_SNY::Presale;
            //If not DeliveryModel.get(Item."Retail Product Code") then
            //    Error('Define Dummy Delivery Model for Retail Prorduct Group (6D Code) %1', item."Retail Product Code");
            /*
            DeliveryModel.TestField("Item No.");
            if SalesLine.INT_DeliverFee_SNY > 0 then begin
                NewSalesLine.init();
                NewSalesLine."Document Type" := SalesHeader."Document Type";
                NewSalesLine."Document No." := SalesHeader."No.";
                NewSalesLine."Line No." := NewLineNo;
                NewSalesLine.Insert(true);
                NewLineNo += 10000;
                NewSalesLine.validate(type, newsalesline.type::Item);
                NewSalesLine.validate("no.", DeliveryModel."Item No.");
                NewSalesLine.validate(Quantity, 1);
                NewSalesLine.validate("Unit Price", SalesLine.INT_DeliverFee_SNY);
                NewSalesLine."INT_Delivery Line_SNY" := true;

                NewSalesLine.INT_RelatedItemType_SNY := NewSalesLine.INT_RelatedItemType_SNY::"Main Delivery";

                if SalesLine.INT_RelatedItemType_SNY = SalesLine.INT_RelatedItemType_SNY::Virtual then
                    NewSalesLine.INT_RelatedItemNo_SNY := SalesLine.INT_RelatedItemNo_SNY
                else
                    NewSalesLine.INT_RelatedItemNo_SNY := SalesLine."No.";
                NewSalesLine.INT_MktOrdStatus_SNY := SalesLine.INT_MktOrdStatus_SNY;
                NewSalesLine.INT_MktOrderLineID_SNY := salesline.INT_MktOrderLineID_SNY;
                NewSalesLine.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;
                NewSalesLine.INT_OrderType_SNY := SalesLine.INT_OrderType_SNY;
                NewSalesLine.INT_ItemType_SNY := SalesLine.INT_ItemType_SNY;
                NewSalesLine.INT_OrderId_SNY := SalesLine.INT_OrderId_SNY;
                NewSalesLine.Modify(true);
            end;
            */
            until SalesLine.Next() = 0;
        if HavePresales then begin
            SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::Presales;
            SalesHeader.INT_OrderType_SNY := SalesHeader.INT_OrderType_SNY::Presale;
        end else
            SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"Inventory N/A";
        SalesHeader.Modify(true);

    end;
    //
    procedure ProcessPreslaesOrder()
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        HasPendingPresales: Boolean;
        PresalesDate: date;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Type", SalesLine."Type"::Item);
        if SalesLine.FindSet() then
            repeat
                Item.Get(SalesLine."No.");
                HasPendingPresales := Item.INT_PresaleCloseDate_SNY > Today();
                if PresalesDate = 0D THEN
                    PresalesDate := Item.INT_PresaleCloseDate_SNY;
                IF PresalesDate < ITEM.INT_PresaleCloseDate_SNY then
                    PresalesDate := ITEM.INT_PresaleCloseDate_SNY;

            until (SalesLine.Next() = 0) or HasPendingPresales;

        if HasPendingPresales then
            exit;

        /*JobQueueEntry."Parameter String" := 'CHECK_PRESALES';
        AlertMgmt.SetSalesHeader(SalesHeader);
        if not AlertMgmt.Run(JobQueueEntry) then
            Message('Unable to Send Preales alert:\Error:', GetLastErrorText);*/
        //SalesHeader."Requested Delivery Date" := PresalesDate;
        SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"Inventory N/A";
        //SalesHeader.INT_OrderType_SNY := SalesHeader.INT_OrderType_SNY::Presale;
        SalesHeader.Modify(true);
    end;

    procedure CheckInventory()
    var
        SalesLine: Record "Sales Line";
        Item: record item;
        OtherSalesHeader: Record "Sales Header";
        OtherSalesLine: Record "Sales Line";
        InventoryBuffer: Record "Inventory Buffer" temporary;
        QuantityAllocated: Decimal;
        InventoryNotAvaiable: Boolean;

    begin
        //Item No.,Variant Code,Dimension Entry No.,Location Code,Bin Code,Lot No.,Serial No.
        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(type, SalesLine.Type::Item);
        SalesLine.SetFilter(Quantity, '>0');
        SalesLine.SetFilter(INT_RelatedItemType_SNY, '%1|%2|%3', SalesLine.INT_RelatedItemType_SNY::Main, SalesLine.INT_RelatedItemType_SNY::"Package", SalesLine.INT_RelatedItemType_SNY::FOC);
        SalesLine.SetAutoCalcFields(INT_Inventory_SNY);
        if SalesLine.FindSet() then
            repeat
                if SalesLine.INT_MktOrdStatus_SNY <> 'canceled' then
                    if InventoryBuffer.get(Salesline."No.", salesline."Variant Code", 0, salesline."Location Code", '', '', '') then begin
                        InventoryBuffer.Quantity += SalesLine."Outstanding Qty. (Base)";
                        InventoryBuffer.Modify();
                    end else begin
                        InventoryBuffer.Init();
                        InventoryBuffer."Item No." := Salesline."No.";
                        InventoryBuffer."Variant Code" := salesline."Variant Code";
                        InventoryBuffer."Location Code" := Salesline."Location Code";
                        InventoryBuffer."Bin Code" := '';
                        InventoryBuffer."Lot No." := '';
                        InventoryBuffer."Serial No." := '';
                        InventoryBuffer.Quantity := SalesLine."Outstanding Qty. (Base)";
                        InventoryBuffer.Insert();
                    end;
            until SalesLine.Next() = 0;
        InventoryNotAvaiable := false;
        InventoryBuffer.Reset();
        if InventoryBuffer.FindSet() then
            repeat
                QuantityAllocated := 0;
                OtherSalesLine.Reset();
                OtherSalesLine.setrange("Document Type", SalesHeader."Document Type");
                OtherSalesline.setrange(type, OtherSalesline.Type::Item);
                OtherSalesLine.setrange("No.", InventoryBuffer."Item No.");
                OtherSalesLine.setrange("Variant Code", InventoryBuffer."Variant Code");
                OtherSalesLine.setrange("Location Code", InventoryBuffer."Location Code");
                OtherSalesLine.SetFilter("Document No.", '<>%1', SalesHeader."No.");
                OtherSalesLine.SetFilter(INT_MktOrdStatus_SNY, '<>%1', 'canceled');

                if OtherSalesLine.FindSet() then
                    repeat
                        if OtherSalesHeader."No." <> OtherSalesLine."Document No." then
                            OtherSalesHeader.get(SalesHeader."Document Type", OtherSalesLine."Document No.");

                        if OtherSalesheader.INT_InvCheck_SNY then begin
                            QuantityAllocated += OtherSalesLine."Outstanding Qty. (Base)";
                        end;
                    until OtherSalesLine.Next() = 0;

                item.Reset();
                item.SetFilter("Location Filter", InventoryBuffer."Location Code");
                item.setfilter("Variant Filter", InventoryBuffer."Variant Code");
                item.Setrange("No.", InventoryBuffer."Item No.");
                item.FindFirst();
                item.CalcFields(Inventory);
                if not InventoryNotAvaiable then
                    InventoryNotAvaiable := (item.Inventory - (QuantityAllocated + InventoryBuffer.Quantity)) < 0;
            until (InventoryBuffer.Next() = 0);
        if not InventoryNotAvaiable then begin
            SalesHeader.INT_InvCheck_SNY := true;
            SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"Inventory Checked";
            SalesHeader.INT_OrderStatus_SNY := SalesHeader.INT_OrderStatus_SNY::Processed;
            SalesHeader.Modify(true);
        end else begin
            /*
                JobQueueEntry."Parameter String" := 'CHECK_INVENTORY';
                AlertMgmt.SetSalesHeader(SalesHeader);
                if not AlertMgmt.Run(JobQueueEntry) then
                    Message('Unable to Send Check Inventory alert:\Error:', GetLastErrorText);
            */
        end;
    end;

    procedure DeliveryConfirm(Manual: Boolean)
    var
        ProcessConfig: Record INT_ProcessConfig_SNY;
        SyncToSapMsg: Label 'Do you want to notify SAP to pick this order?';
        EcomInterface: Codeunit INT_EcomInterface_SNY;
    begin
        if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::Completed then
            Error('Status is already completed!');
        SalesHeader.testfield(INT_InternalProcessing_SNY, SalesHeader.INT_InternalProcessing_SNY::"Inventory Checked");
        SalesHeader.TestField(INT_InvCheck_SNY);
        if Manual then
            if SalesHeader.INT_DeliveryType_SNY = SalesHeader.INT_DeliveryType_SNY::Standard then
                Error('Delivery Type must be DBS Home or DBS Standard!');
        if not Manual then begin
            ProcessConfig.get(SalesHeader.INT_MarketPlace_SNY, salesHeader.INT_DeliveryType_SNY);
            if not ProcessConfig."Enable Auto Delivery" then
                Exit;
        end;

        //Confirm Delivery Address only for DBS Home and DBS Consignment of Shopify Order
        EcomInterface.SetStatusToConfirmDelivery(SalesHeader);
        SalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
        SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::Completed;
        SalesHeader.INT_OrderStatus_SNY := SalesHeader.INT_OrderStatus_SNY::"Delivery Confirmed";
        SalesHeader.INT_DelConfirmed_SNY := true;
        SalesHeader.Modify(true);
    end;

    procedure CollectConfirm(ShowConfirm: Boolean)
    var
        ProcessConfig: Record INT_ProcessConfig_SNY;
        SyncToSapMsg: Label 'Do you want to notify SAP to pick this order?';
        EcomInterface: Codeunit INT_EcomInterface_SNY;
    begin
        if SalesHeader.INT_DeliveryType_SNY = SalesHeader.INT_DeliveryType_SNY::"DBS Home" then
            Error('Delivery Type must be standard or dbs standard!');
        if SalesHeader.INT_DelConfirmed_SNY then
            Error('Collected already Confirmed!');
        if ShowConfirm then
            if not Confirm('Do you want to confirm Collect?', false) then
                exit;

        SalesHeader.testfield(INT_InvCheck_SNY);

        //Confirm Collect only for DBS Standard of Shopify Order
        EcomInterface.SetStatusToConfirmCollect(SalesHeader);
        SalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
        SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::Completed;
        if SalesHeader.INT_OrderStatus_SNY < SalesHeader.INT_OrderStatus_SNY::"Delivery Confirmed" then
            SalesHeader.INT_OrderStatus_SNY := SalesHeader.INT_OrderStatus_SNY::"Delivery Confirmed";
        SalesHeader.INT_DelConfirmed_SNY := true;
        SalesHeader.Modify(true);
    end;



    procedure SynctoSAP(Manual: Boolean)

    var
        ProcessConfig: Record INT_ProcessConfig_SNY;
        SAPAPI: Codeunit INT_SAPAPI_SNY;
        SucessMsg: Label 'Notified SAP Sucessfully!';
    begin
        if SalesHeader.INT_SimpleStatus_SNY <> SalesHeader.INT_SimpleStatus_SNY::"Not Started" then
            exit;

        /* 
         if not Manual then begin
             ProcessConfig.get(SalesHeader.INT_MarketPlace_SNY, salesHeader.INT_DeliveryType_SNY);
             if not ProcessConfig."Enable Auto Sync" then
                 exit;
         end;
         */
        if SalesHeader.INT_DeliveryType_SNY = SalesHeader.INT_DeliveryType_SNY::Standard then begin
            if (SalesHeader.INT_OrderStatus_SNY < SalesHeader.INT_OrderStatus_SNY::"Ready to Ship") or (not SalesHeader.INT_DelConfirmed_SNY) then
                exit;

        end else begin
            if (SalesHeader.INT_OrderStatus_SNY < SalesHeader.INT_OrderStatus_SNY::"Delivery Confirmed") or (not SalesHeader.INT_DelConfirmed_SNY) then
                exit;
        end;

        IF SalesHeader."Requested Delivery Date" = 0D THEN
            SalesHeader."Requested Delivery Date" := CalculateRDDDate(Today());

        SalesHeader.TestField("Requested Delivery Date");
        SalesHeader.Modify();
        Commit();
        SAPAPI.NotifySAP(SalesHeader, false);
        SalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
        SalesHeader.INT_SimpleStatus_SNY := SalesHeader.INT_SimpleStatus_SNY::"Ready for Pick";
        SalesHeader.Modify(true);
        if Manual then
            Message(SucessMsg);
    end;

    procedure CalculateRDDDate(OrderDate: Date): Date
    var
        SalesSetup: Record "Sales & Receivables Setup";
        Holidays: Record "Employee Absence";
        AcceptedOrderEndDate: Date;
        HaveOrderDate: Boolean;
        HolidayNotDefinedErr: Label 'Please define holiday for year %1', Comment = '%1 - Year';
        ToAdjust: Integer;
    begin
        SalesSetup.Get();
        SalesSetup.TestField(INT_HolidayMapping_SNY);
        SalesSetup.TestField(INT_NoofDaysAdjust_SNY);
        AcceptedOrderEndDate := CalcDate('CM', OrderDate);

        Holidays.Reset();
        Holidays.SetRange("Employee No.", 'HOLIDAY');
        HaveOrderDate := false;

        while (ToAdjust <> SalesSetup.INT_NoofDaysAdjust_SNY) do begin
            Holidays.SetRange("From Date", AcceptedOrderEndDate);
            //Message('date: %1: no: %2', AcceptedOrderEndDate, Date2DWY(AcceptedOrderEndDate, 1));
            if (Date2DWY(AcceptedOrderEndDate, 1) in [1 .. 5]) and (Holidays.IsEmpty()) then
                ToAdjust += 1;
            AcceptedOrderEndDate := AcceptedOrderEndDate - 1;
        end;

        if OrderDate <= AcceptedOrderEndDate then
            exit(OrderDate);

        HaveOrderDate := false;
        AcceptedOrderEndDate := CalcDate('CM+1D', OrderDate);
        /*
        Holidays.Reset();
        Holidays.SetRange("Employee No.", 'HOLIDAY');
        Holidays.SetRange("From Date", DMY2Date(1, 1, Date2DMY(OrderDate, 3)), DMY2Date(31, 12, Date2DMY(OrderDate, 3)));
        IF Holidays.IsEmpty() THEN
            IF Holidays.IsEmpty() then
                Error(HolidayNotDefinedErr, Date2DMY(OrderDate, 3));
        */
        Holidays.Reset();
        Holidays.SetRange("Employee No.", 'HOLIDAY');
        Holidays.SetRange("From Date");
        while not HaveOrderDate do begin
            Holidays.SetRange("From Date", AcceptedOrderEndDate);
            if (not Holidays.FindFirst()) and (Date2DWY(AcceptedOrderEndDate, 1) in [1 .. 5]) then
                Exit(AcceptedOrderEndDate)
            else
                AcceptedOrderEndDate := AcceptedOrderEndDate + 1;
        end;
    end;

    procedure ReprocessSalesOrder(SH: Record "Sales Header")
    var
        UpdateStatus: Codeunit INT_SyncMktStatus_SNY;
        UpdateSalesHeader: Record "Sales Header";
        InterfaceSetup: Record INT_InterfaceSetup_SNY;
        SalesLineL: Record "Sales Line";
    begin
        SetOrder(SH);
        SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split";
        salesheader.INT_ProcessErr_SNY := '';
        SalesHeader.Modify();
        DeleteSystemCreatedSalesLine();
        InterfaceSetup.Get();
        if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split" then begin
            ExplodeOrder();
            Commit();
        end;

        if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Explode SO" then begin
            //InsertDeliveryFee();
            skipInsertDeliveryFee();
            Commit();
        end;

        if (SalesHeader.INT_InternalProcessing_SNY in [SalesHeader.INT_InternalProcessing_SNY::"Explode SO", SalesHeader.INT_InternalProcessing_SNY::Presales])
                and (SalesHeader.INT_OrderType_SNY = SalesHeader.INT_OrderType_SNY::Presale) then begin
            ProcessPreslaesOrder();
            Commit();
        end;

        if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Inventory N/A" then begin
            CheckInventory();
            Commit();
        end;

        if (SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Inventory Checked")
         and (not SalesHeader.INT_DelConfirmed_SNY) then begin
            DeliveryConfirm(false);
            Commit();
        end;

        /*
        if ((SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Inventory Checked") or
            (SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::Completed))
            and (SalesHeader.INT_SimpleStatus_SNY = SalesHeader.INT_SimpleStatus_SNY::"Not Started") then begin
            SynctoSAP(false);
        end;
        */
        if InterfaceSetup."Auto Set Lazada Inv" then
            if SalesHeader.INT_InvCheck_SNY then begin
                Commit();
                clear(UpdateStatus);
                UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                UpdateStatus.SetOrder(UpdateSalesHeader, 10);
                if not UpdateStatus.Run() then begin
                    UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                    UpdateSalesHeader.INT_ProcessErr_SNY := GetLastErrorText;
                    UpdateSalesHeader.Modify();
                end;
                Commit();
                clear(UpdateStatus);
                UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                UpdateStatus.SetOrder(UpdateSalesHeader, 20);
                if not UpdateStatus.run() then begin
                    UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                    UpdateSalesHeader.INT_ProcessErr_SNY := GetLastErrorText;
                    UpdateSalesHeader.Modify();
                    Commit();
                end;
            end;

        if SalesHeader.INT_SAPOrderID_SNY <> '' then
            PostingShipments();

    end;

    procedure DeleteSystemCreatedSalesLine()
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(INT_RelatedItemType_SNY, '%1|%2|%3|%4|%5', SalesLine.INT_RelatedItemType_SNY::"Main Delivery", SalesLine.INT_RelatedItemType_SNY::"Package", SalesLine.INT_RelatedItemType_SNY::"FOC", SalesLine.INT_RelatedItemType_SNY::"Package Dummy", SalesLine.INT_RelatedItemType_SNY::"FOC Dummy");
        if SalesLine.FindSet() then
            SalesLine.DeleteAll();
        SalesLine.reset;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        // SalesLine.SetFilter(INT_RelatedItemType_SNY, '%1|%2|%3|%4|%5', SalesLine.INT_RelatedItemType_SNY::"Main Delivery", SalesLine.INT_RelatedItemType_SNY::"Package", SalesLine.INT_RelatedItemType_SNY::"FOC", SalesLine.INT_RelatedItemType_SNY::"Package Dummy", SalesLine.INT_RelatedItemType_SNY::"FOC Dummy");
        if SalesLine.FindSet() then
            repeat
                if SalesLine.Quantity = 0 then begin
                    if SalesLine.Original_Quantity <> 0 then begin
                        SalesLine.SetHideValidationDialog(true);
                        SalesLine.Validate(Quantity, SalesLine.Original_Quantity);

                    end;
                end;
                SalesLine.INT_RelatedItemType_SNY := SalesLine.Org_INT_RelatedItemType_SNY;
                SalesLine.Modify();
            until SalesLine.Next() = 0;

    end;

    procedure ReCheckInventory(SL: Record "Sales Line")
    var
        SalesLine: Record "Sales Line";
        Item: record item;
        OtherSalesHeader: Record "Sales Header";
        OtherSalesLine: Record "Sales Line";
        InventoryBuffer: Record "Inventory Buffer" temporary;
        QuantityAllocated: Decimal;
        InventoryNotAvaiable: Boolean;

    begin
        //Item No.,Variant Code,Dimension Entry No.,Location Code,Bin Code,Lot No.,Serial No.
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SL."Document Type");
        SalesHeader.SetRange("No.", SL."Document No.");
        if SalesHeader.FindFirst() then;
        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(type, SalesLine.Type::Item);
        SalesLine.SetFilter(Quantity, '>0');
        SalesLine.SetFilter(INT_RelatedItemType_SNY, '%1|%2|%3', SalesLine.INT_RelatedItemType_SNY::Main, SalesLine.INT_RelatedItemType_SNY::"Package", SalesLine.INT_RelatedItemType_SNY::FOC);
        SalesLine.SetAutoCalcFields(INT_Inventory_SNY);
        if SalesLine.FindSet() then
            repeat
                if SalesLine.INT_MktOrdStatus_SNY <> 'canceled' then
                    if InventoryBuffer.get(Salesline."No.", salesline."Variant Code", 0, salesline."Location Code", '', '', '') then begin
                        InventoryBuffer.Quantity += SalesLine."Outstanding Qty. (Base)";
                        InventoryBuffer.Modify();
                    end else begin
                        InventoryBuffer.Init();
                        InventoryBuffer."Item No." := Salesline."No.";
                        InventoryBuffer."Variant Code" := salesline."Variant Code";
                        InventoryBuffer."Location Code" := Salesline."Location Code";
                        InventoryBuffer."Bin Code" := '';
                        InventoryBuffer."Lot No." := '';
                        InventoryBuffer."Serial No." := '';
                        InventoryBuffer.Quantity := SalesLine."Outstanding Qty. (Base)";
                        InventoryBuffer.Insert();
                    end;
            until SalesLine.Next() = 0;
        InventoryNotAvaiable := false;
        InventoryBuffer.Reset();
        if InventoryBuffer.FindSet() then
            repeat
                QuantityAllocated := 0;
                OtherSalesLine.Reset();
                OtherSalesLine.setrange("Document Type", SalesHeader."Document Type");
                OtherSalesline.setrange(type, OtherSalesline.Type::Item);
                OtherSalesLine.setrange("No.", InventoryBuffer."Item No.");
                OtherSalesLine.setrange("Variant Code", InventoryBuffer."Variant Code");
                OtherSalesLine.setrange("Location Code", InventoryBuffer."Location Code");
                OtherSalesLine.SetFilter("Document No.", '<>%1', SalesHeader."No.");
                OtherSalesLine.SetFilter(INT_MktOrdStatus_SNY, '<>%1', 'canceled');

                if OtherSalesLine.FindSet() then
                    repeat
                        if OtherSalesHeader."No." <> OtherSalesLine."Document No." then
                            OtherSalesHeader.get(SalesHeader."Document Type", OtherSalesLine."Document No.");

                        if OtherSalesheader.INT_InvCheck_SNY then begin
                            QuantityAllocated += OtherSalesLine."Outstanding Qty. (Base)";
                        end;
                    until OtherSalesLine.Next() = 0;

                item.Reset();
                item.SetFilter("Location Filter", InventoryBuffer."Location Code");
                item.setfilter("Variant Filter", InventoryBuffer."Variant Code");
                item.Setrange("No.", InventoryBuffer."Item No.");
                item.FindFirst();
                item.CalcFields(Inventory);
                if not InventoryNotAvaiable then
                    InventoryNotAvaiable := (item.Inventory - (QuantityAllocated + InventoryBuffer.Quantity)) < 0;
            until (InventoryBuffer.Next() = 0);
        if not InventoryNotAvaiable then begin
            SalesHeader.INT_InvCheck_SNY := true;
            SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"Inventory Checked";
            SalesHeader.INT_OrderStatus_SNY := SalesHeader.INT_OrderStatus_SNY::Processed;
            SalesHeader.Modify(true);
        end else begin
            /*
                JobQueueEntry."Parameter String" := 'CHECK_INVENTORY';
                AlertMgmt.SetSalesHeader(SalesHeader);
                if not AlertMgmt.Run(JobQueueEntry) then
                    Message('Unable to Send Check Inventory alert:\Error:', GetLastErrorText);
            */
        end;
    end;
    //////////////////////////////////////////////////SHOPIFY-FUNCTIONS///////////////////////////////////////////
    procedure SplitByDeliveryType2()
    var
        SalesLine: Record "Sales Line";
        NewSalesHeader: Record "Sales Header";
        NewSalesHeader2: Record "Sales Header";
        NewSalesHeader3: Record "Sales Header";
        NewSalesHeader4: Record "Sales Header";
        NewSalesLine: Record "Sales Line";
        NormalExist: Boolean;
        DBSExist: Boolean;
        DBSHomeEXist: Boolean;
        CosignmentExist: Boolean;
    begin
        SplitByOrderType2();
        clear(NormalExist);
        clear(DBSExist);
        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);

        SalesLine.SetFilter(INT_DeliveryType_SNY, '%1', Salesline.INT_DeliveryType_SNY::"DBS Home");
        DBSHomeEXist := not SalesLine.IsEmpty();
        SalesLine.SetFilter(INT_DeliveryType_SNY, '%1', Salesline.INT_DeliveryType_SNY::"DBS Standard");
        NormalExist := not SalesLine.IsEmpty();
        SalesLine.SetFilter(INT_DeliveryType_SNY, '%1', Salesline.INT_DeliveryType_SNY::"DBS Consignment");
        CosignmentExist := not SalesLine.IsEmpty();
        //Message('%1 %2', Salesline.INT_DeliveryType_SNY, CosignmentExist);
        if NormalExist and DBSHomeEXist then begin
            SalesLine.SetFilter(INT_DeliveryType_SNY, '%1', SalesLine.INT_DeliveryType_SNY::"DBS Standard");
            FullfillmentCreateHeader(NewSalesHeader);
            CreateLines(NewSalesHeader, SalesLine);
            // MergingDiscountLine(NewSalesHeader, SalesLine);
            NewSalesHeader.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;

            SalesLine.FindSet();
            SalesLine.DeleteAll(true);

            NewSalesHeader.INT_InternalProcessing_SNY := NewSalesHeader.INT_InternalProcessing_SNY::"Delivery Split Completed";
            NewSalesHeader.INT_BCOrderNo_SNY := SalesHeader."No.";

            NewSalesHeader.INT_SplitInfo_SNY := 'Split';
            NewSalesHeader.Modify();
            //
            if CosignmentExist then begin
                SalesLine.SetFilter(INT_DeliveryType_SNY, '%1', SalesLine.INT_DeliveryType_SNY::"DBS Consignment");
                FullfillmentCreateHeader(NewSalesHeader2);
                CreateLines(NewSalesHeader2, SalesLine);
                // MergingDiscountLine(NewSalesHeader, SalesLine);
                NewSalesHeader2.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;

                SalesLine.FindSet();
                SalesLine.DeleteAll(true);

                NewSalesHeader2.INT_InternalProcessing_SNY := NewSalesHeader2.INT_InternalProcessing_SNY::"Delivery Split Completed";
                NewSalesHeader2.INT_BCOrderNo_SNY := SalesHeader."No.";

                NewSalesHeader2.INT_SplitInfo_SNY := 'Split';
                NewSalesHeader2.Modify();
                SalesHeader.INT_SplitInfo_SNY := 'Split';
            end;
            //      
            SalesHeader.INT_SplitInfo_SNY := 'Split';
        end;
        //
        if DBSHomeEXist and CosignmentExist and not NormalExist then begin
            SalesLine.SetFilter(INT_DeliveryType_SNY, '%1', SalesLine.INT_DeliveryType_SNY::"DBS Consignment");
            FullfillmentCreateHeader(NewSalesHeader3);
            CreateLines(NewSalesHeader3, SalesLine);
            // MergingDiscountLine(NewSalesHeader, SalesLine);
            NewSalesHeader3.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;

            SalesLine.FindSet();
            SalesLine.DeleteAll(true);

            NewSalesHeader3.INT_InternalProcessing_SNY := NewSalesHeader3.INT_InternalProcessing_SNY::"Delivery Split Completed";
            NewSalesHeader3.INT_BCOrderNo_SNY := SalesHeader."No.";

            NewSalesHeader3.INT_SplitInfo_SNY := 'Split';
            NewSalesHeader3.Modify();
            SalesHeader.INT_SplitInfo_SNY := 'Split';
        end;
        if NormalExist and CosignmentExist and not DBSHomeEXist then begin
            SalesLine.SetFilter(INT_DeliveryType_SNY, '%1', SalesLine.INT_DeliveryType_SNY::"DBS Consignment");
            FullfillmentCreateHeader(NewSalesHeader4);
            CreateLines(NewSalesHeader4, SalesLine);
            // MergingDiscountLine(NewSalesHeader, SalesLine);
            NewSalesHeader4.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;

            SalesLine.FindSet();
            SalesLine.DeleteAll(true);

            NewSalesHeader4.INT_InternalProcessing_SNY := NewSalesHeader4.INT_InternalProcessing_SNY::"Delivery Split Completed";
            NewSalesHeader4.INT_BCOrderNo_SNY := SalesHeader."No.";


            NewSalesHeader4.INT_SplitInfo_SNY := 'Split';
            NewSalesHeader4.Modify();
            SalesHeader.INT_SplitInfo_SNY := 'Split';
        end;
        //

        SalesHeader.INT_BCOrderNo_SNY := SalesHeader.INT_BCOrderNo_SNY;

        if DBSHomeEXist and not NormalExist and not CosignmentExist then
            SalesHeader.INT_DeliveryType_SNY := SalesHeader.INT_DeliveryType_SNY::"DBS Home"
        else
            if NormalExist and not DBSHomeEXist and not CosignmentExist then
                SalesHeader.INT_DeliveryType_SNY := SalesHeader.INT_DeliveryType_SNY::"DBS Standard"
            else
                if CosignmentExist and not DBSHomeEXist and not NormalExist then
                    SalesHeader.INT_DeliveryType_SNY := SalesHeader.INT_DeliveryType_SNY::"DBS Consignment"
                else
                    if NormalExist and CosignmentExist then
                        SalesHeader.INT_DeliveryType_SNY := SalesHeader.INT_DeliveryType_SNY::"DBS Standard"
                    else
                        SalesHeader.INT_DeliveryType_SNY := SalesHeader.INT_DeliveryType_SNY::"DBS Home";


        SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"Delivery Split Completed";
        SalesHeader.Modify(true);
    end;


    procedure DeliveryConfirm2(Manual: Boolean)
    var
        ProcessConfig: Record INT_ProcessConfig_SNY;
        SyncToSapMsg: Label 'Do you want to notify SAP to pick this order?';
        EcomInterface: Codeunit INT_EcomInterface_SNY;
    begin
        if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::Completed then
            Error('Status is already completed!');
        SalesHeader.testfield(INT_InternalProcessing_SNY, SalesHeader.INT_InternalProcessing_SNY::"Inventory Checked");
        SalesHeader.TestField(INT_InvCheck_SNY);
        if Manual then
            if SalesHeader.INT_DeliveryType_SNY = SalesHeader.INT_DeliveryType_SNY::"DBS Standard" then
                Error('Delivery Type must be DBS Home or DBS Consignment!');
        if not Manual then begin
            ProcessConfig.get(SalesHeader.INT_MarketPlace_SNY, salesHeader.INT_DeliveryType_SNY);
            if not ProcessConfig."Enable Auto Delivery" then
                Exit;
        end;

        //Confirm Delivery Address only for DBS Home and DBS Consignment of Shopify Order
        EcomInterface.SetStatusToConfirmDelivery(SalesHeader);
        SalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
        SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::Completed;
        SalesHeader.INT_OrderStatus_SNY := SalesHeader.INT_OrderStatus_SNY::"Delivery Confirmed";
        SalesHeader.INT_DelConfirmed_SNY := true;
        SalesHeader.Modify(true);
    end;

    procedure FullfillmentInventoryCheck(Salesline: Record "Sales Line"; FinalLocation: Code[10]): Boolean
    var
        Item: record item;
        OtherSalesLine: Record "Sales Line";
        InventoryBuffer: Record "Inventory Buffer" temporary;
        QuantityAllocated: Decimal;
        InventoryNotAvaiable: Boolean;
    begin
        QuantityAllocated := 0;
        OtherSalesLine.Reset;
        OtherSalesLine.setrange("Document Type", SalesLine."Document Type");
        OtherSalesline.setrange(type, SalesLine.Type::Item);
        OtherSalesLine.setrange("No.", SalesLine."No.");
        OtherSalesLine.setrange("Variant Code", SalesLine."Variant Code");
        OtherSalesLine.setrange("Location Code", FinalLocation);
        OtherSalesLine.SetFilter("Document No.", '<>%1', SalesLine."Document No.");
        if OtherSalesLine.FindSet() then
            repeat
                QuantityAllocated += OtherSalesLine."Outstanding Qty. (Base)";
            until OtherSalesLine.Next() = 0;
        item.Reset();
        item.SetFilter("Location Filter", FinalLocation);
        item.setfilter("Variant Filter", SalesLine."Variant Code");
        item.Setrange("No.", SalesLine."No.");
        item.FindFirst();
        item.CalcFields(Inventory);
        InventoryNotAvaiable := (item.Inventory - (QuantityAllocated + SalesLine."Outstanding Qty. (Base)")) < 0;

        exit(InventoryNotAvaiable);
    end;

    procedure FullfillmentCollectConfirm(ShowConfirm: Boolean)
    var
        ProcessConfig: Record INT_ProcessConfig_SNY;
        SyncToSapMsg: Label 'Do you want to notify SAP to pick this order?';
        EcomInterface: Codeunit INT_EcomInterface_SNY;
    begin
        if (SalesHeader.INT_DeliveryType_SNY = SalesHeader.INT_DeliveryType_SNY::"DBS Home")
            or (SalesHeader.INT_DeliveryType_SNY = SalesHeader.INT_DeliveryType_SNY::"DBS Consignment") then
            Error('Delivery Type must be dbs standard!');
        if SalesHeader.INT_DelConfirmed_SNY then
            Error('Collected already Confirmed!');
        if ShowConfirm then
            if not Confirm('Do you want to confirm Collect?', false) then
                exit;

        SalesHeader.testfield(INT_InvCheck_SNY);

        //Confirm Collect only for DBS Standard of Shopify Order
        EcomInterface.SetStatusToConfirmCollect(SalesHeader);
        SalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
        SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::Completed;
        if SalesHeader.INT_OrderStatus_SNY < SalesHeader.INT_OrderStatus_SNY::"Delivery Confirmed" then
            SalesHeader.INT_OrderStatus_SNY := SalesHeader.INT_OrderStatus_SNY::"Delivery Confirmed";
        SalesHeader.INT_DelConfirmed_SNY := true;
        SalesHeader.Modify(true);
    end;

    procedure SplitByItemType2()
    var
        NewSalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        NormalExist: Boolean;
        PSGExist: Boolean;
        BunExist: Boolean;
        Amount: Decimal;
        Qty: Decimal;
    begin
        //SalesLine.INT_ItemType_SNY::
        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange(INT_ItemType_SNY, SalesLine.INT_ItemType_SNY::NPG);
        NormalExist := not SalesLine.IsEmpty();
        SalesLine.SetRange(INT_ItemType_SNY, SalesLine.INT_ItemType_SNY::PGS);
        PSGExist := not SalesLine.IsEmpty();
        SalesLine.SetRange(INT_ItemType_SNY, SalesLine.INT_ItemType_SNY::BUN);
        BunExist := not SalesLine.IsEmpty();
        if NormalExist and (BunExist or PSGExist) then begin
            //Split Normal Orders
            SalesLine.SetRange(INT_ItemType_SNY, SalesLine.INT_ItemType_SNY::NPG);
            FullfillmentCreateHeader(NewSalesHeader);
            CreateLines(NewSalesHeader, SalesLine);
            // MergingDiscountLine(NewSalesHeader, SalesLine);
            NewSalesHeader.INT_InternalProcessing_SNY := NewSalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split";
            NewSalesHeader.INT_BCOrderNo_SNY := SalesHeader.INT_BCOrderNo_SNY;
            NewSalesHeader.INT_SplitInfo_SNY := 'Split';
            SalesHeader.INT_SplitInfo_SNY := 'Split';
            NewSalesHeader.Modify();
            SalesLine.FindSet();
            SalesLine.Deleteall();

        end;
        if (BunExist or PSGExist) then begin
            //Check Conditions 
            Qty := 0;
            SalesLine.SetRange(INT_ItemType_SNY);//, SalesLine.INT_ItemType_SNY::BUN);
            if SalesLine.FindSet() then
                repeat
                    if SalesLine.INT_ItemType_SNY = SalesLine.INT_ItemType_SNY::BUN then
                        Qty += SalesLine.Quantity
                    else
                        if SalesLine.INT_ItemType_SNY = SalesLine.INT_ItemType_SNY::PGS then
                            Amount += SalesLine.Amount;
                until SalesLine.Next() = 0;
            if (Qty > 140) or (Amount > 10000) then begin
                clear(AlertMgmt);
                JobQueueEntry."Parameter String" := 'CHECK_BUNDLE_SPLIT';
                AlertMgmt.SetSalesHeader(SalesHeader);
                if not AlertMgmt.Run(JobQueueEntry) then
                    Message('Unable to Send Manual Bundle Split alert:\Error:', GetLastErrorText);
            end else
                if BunExist and PSGExist then begin
                    SalesLine.SetRange(INT_ItemType_SNY, SalesLine.INT_ItemType_SNY::BUN);
                    FullfillmentCreateHeader(NewSalesHeader);
                    CreateLines(NewSalesHeader, SalesLine);
                    // MergingDiscountLine(NewSalesHeader, SalesLine);
                    SalesLine.DeleteAll(true);
                    NewSalesHeader.INT_InternalProcessing_SNY := NewSalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split";
                    NewSalesHeader.INT_BCOrderNo_SNY := SalesHeader.INT_BCOrderNo_SNY;
                    NewSalesHeader.INT_SplitInfo_SNY := 'Split';
                    NewSalesHeader.Modify();
                    SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split";
                    SalesHeader.INT_SplitInfo_SNY := 'Split';
                    SalesHeader.Modify();
                end else begin
                    SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split";
                    SalesHeader.Modify();
                end;
        end else begin
            SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split";
            SalesHeader.Modify();
        end;
    end;

    procedure SplitByOrderType2()
    var
        SalesLine: Record "Sales Line";
        NewSalesHeader: Record "Sales Header";
        NewSalesLine: Record "Sales Line";
        Item: Record Item;
        NormalOrderExist: Boolean;
        PresalesExist: Boolean;

    begin
        clear(NormalOrderExist);
        clear(PresalesExist);
        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                item.get(SalesLine."No.");
                if item.INT_OrderType_SNY = item.INT_OrderType_SNY::Normal then
                    SalesLine.INT_OrderType_SNY := SalesLine.INT_OrderType_SNY::Normal
                else
                    SalesLine.INT_OrderType_SNY := SalesLine.INT_OrderType_SNY::Presale;
                SalesLine.Modify();
            until SalesLine.Next() = 0;

        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter(INT_OrderType_SNY, '%1', SalesLine.INT_OrderType_SNY::Normal);
        NormalOrderExist := not SalesLine.IsEmpty();

        SalesLine.SetFilter(INT_OrderType_SNY, '%1', SalesLine.INT_OrderType_SNY::Presale);
        PresalesExist := not SalesLine.IsEmpty();

        if PresalesExist and NormalOrderExist then begin
            SalesLine.SetFilter(INT_OrderType_SNY, '%1', SalesLine.INT_OrderType_SNY::Normal);
            FullfillmentCreateHeader(NewSalesHeader);
            CreateLines(NewSalesHeader, SalesLine);
            // MergingDiscountLine(NewSalesHeader, SalesLine);
            SalesLine.FindSet();
            SalesLine.DeleteAll(true);
            NewSalesHeader.INT_BCOrderNo_SNY := SalesHeader."No.";
            NewSalesHeader.INT_OrderType_SNY := NewSalesHeader.INT_OrderType_SNY::Normal;
            NewSalesHeader.INT_SplitInfo_SNY := 'Split';
            SalesHeader.INT_SplitInfo_SNY := 'Split';
            NewSalesHeader.Modify();
        end else
            if PresalesExist then
                SalesHeader.INT_OrderType_SNY := NewSalesHeader.INT_OrderType_SNY::Presale
            else
                SalesHeader.INT_OrderType_SNY := NewSalesHeader.INT_OrderType_SNY::Normal;
        SalesHeader.INT_BCOrderNo_SNY := SalesHeader."No.";
        SalesHeader.Modify(true);
    end;

    Procedure MergingDiscountLine(var NewSalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        DiscountSalesLine: Record "Sales Line";
    begin
        if SalesLine.findset then
            Repeat
                DiscountSalesLine.reset();
                DiscountSalesLine.SetRange("Document Type", SalesLine."Document Type");
                DiscountSalesLine.setrange("Document No.", SalesLine."Document No.");
                DiscountSalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
                DiscountSalesLine.Setrange("INT_MktOrderLineID_SNY", SalesLine."INT_MktOrderLineID_SNY");

                if DiscountSalesLine.Findfirst() then begin
                    CreateLines(NewSalesHeader, DiscountSalesLine);
                    DiscountSalesLine.DeleteAll(true)
                end;

            until SalesLine.Next() = 0;
    end;

    procedure ExplodeOrder2()
    var
        SalesLine: Record "Sales Line";
        BundleHeader: Record INT_BundleHeader_SNY;
        BundleLine: Record INT_BundleLine_SNY;
        FocBundleHeader: Record INT_BundleHeader_SNY;
        FocBundleLine: Record INT_BundleLine_SNY;
        NewSalesLine: Record "Sales Line";
        BufferUnitprice: Decimal;
        Item: Record Item;
        BundleAmount: Decimal;
        NewLineNo: Integer;
        MainModelLineNo: Integer;
        HaveBundleHeader: Boolean;
        HaveFocBundleHeader: Boolean;
        BundlePackageDetailsErr: Label 'Bundle Details could not found package no. %1';
    begin
        // Message('%1,%2', SalesHeader."Document Type", SalesHeader."No.");
        //Explode Bundle
        Clear(BufferUnitprice);
        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            NewLineNo := SalesLine."Line No." + 10000
        ELSE
            NewLineNo := 10000;
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange(INT_RelatedItemType_SNY, SalesLine.INT_RelatedItemType_SNY::Main);
        SalesLine.SetRange("Line No.", 0, NewLineNo - 1);
        if SalesLine.findset() then
            repeat

                item.get(SalesLine."No.");
                if item.INT_MainModel_SNY <> '' then begin
                    MainModelLineNo := 0;
                    BundleAmount := 0;
                    BundleHeader.Reset();
                    BundleHeader.SETRANGE(Marketplace, SalesHeader.INT_MarketPlace_SNY);
                    BundleHeader.Setrange(Type, BundleHeader.Type::Package);
                    BundleHeader.Setrange("Item No.", SalesLine."No.");
                    BundleHeader.SetFilter(Status, '%1|%2', BundleHeader.Status::Certified, BundleHeader.Status::Expired);
                    if 1 = 1 then begin

                        HaveBundleHeader := false;
                        if BundleHeader.FindFirst() then
                            repeat
                                if SalesHeader."Order Date" in [BundleHeader."Starting Date" .. BundleHeader."Ending Date"] then
                                    HaveBundleHeader := true;
                            until (BundleHeader.Next() = 0) or HaveBundleHeader = true;
                    end else
                        HaveBundleHeader := true;
                    if not HaveBundleHeader then
                        Error(BundlePackageDetailsErr, SalesLine."No.");
                    BundleLine.Reset();
                    BundleLine.SetRange(Type, BundleHeader.Type);
                    BundleLine.SetRange("No.", BundleHeader."No.");
                    if BundleLine.FindSet() then
                        repeat
                            newsalesline := SalesLine;
                            NewSalesLine.INT_RelatedItemType_SNY := BundleLine."Related Item Type";
                            NewSalesLine.INT_RelatedItemNo_SNY := BundleLine."Related Item No.";
                            NewSalesLine."Line No." := NewLineNo;
                            NewLineNo += 10000;
                            NewSalesLine.insert(true);
                            NewSalesLine.validate("No.", BundleLine."Item No.");
                            NewSalesLine.validate(Quantity, BundleLine.Quantity * SalesLine.Quantity);
                            if BundleLine."Promotional Price" <> 0 then
                                NewSalesLine.validate("Unit Price", BundleLine."Promotional Price" / BundleLine.Quantity)
                            else
                                NewSalesLine.validate("Unit Price", BundleLine."SRP Price" / BundleLine.Quantity);
                            NewSalesLine."Location Code" := SalesLine."Location Code";
                            NewSalesLine."INT_Bundle Order No._SNY" := BundleLine."No.";
                            NewSalesLine.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;
                            NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                            NewSalesLine.INT_MktOrdStatus_SNY := SalesLine.INT_MktOrdStatus_SNY;
                            NewSalesLine.INT_RelatedItemType_SNY := BundleLine."Related Item Type";
                            NewSalesLine.INT_RelatedItemNo_SNY := BundleLine."Related Item No.";
                            NewSalesLine.INT_RelOrderLineNo_SNY := SalesLine."Line No.";
                            NewSalesLine.INT_OrderId_SNY := SalesLine.INT_OrderId_SNY;
                            NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;

                            NewSalesLine.INT_DeliverFee_SNY := 0;
                            BundleAmount += NewSalesLine."Line Amount";
                            NewSalesLine.Modify(true);
                            if (MainModelLineNo = 0) and BundleLine."Main Item for Delivery" then
                                MainModelLineNo := NewSalesLine."Line No.";

                            if BundleLine."Main Item for Delivery" then begin
                                Item.get(BundleLine."Item No.");
                                item.TestField("Retail Product Code");
                                SalesLine."Retail Product Code" := item."Retail Product Code";
                                SalesLine.Org_INT_RelatedItemType_SNY := SalesLine.INT_RelatedItemType_SNY;//US 25nov2020
                                SalesLine.INT_RelatedItemType_SNY := SalesLine.INT_RelatedItemType_SNY::Virtual;
                                SalesLine.INT_RelatedItemNo_SNY := BundleLine."Item No.";
                                SalesLine.Modify();
                            end;
                            if BundleLine."Explode FOC Item" then begin
                                HaveFocBundleHeader := false;
                                FocBundleHeader.Reset();
                                FocBundleHeader.SETRANGE(Marketplace, SalesHeader.INT_MarketPlace_SNY);
                                FocBundleHeader.Setrange(Type, FocBundleHeader.Type::FOC);
                                FocBundleHeader.Setrange("Item No.", BundleLine."Item No.");
                                //FocBundleHeader.SetFilter(Status, '%1|%2', FocBundleHeader.Status::Certified, FocBundleHeader.Status::Expired);
                                if FocBundleHeader.FindFirst() then
                                    repeat

                                        HaveFocBundleHeader := (SalesHeader."Order Date" in [FocBundleHeader."Starting Date" .. FocBundleHeader."Ending Date"]) and (BundleHeader."Is Active" = true);

                                        if HaveFocBundleHeader then begin
                                            FocBundleLine.Reset();
                                            FocBundleLine.SetRange(Type, FocBundleHeader.Type);
                                            FocBundleLine.SetRange("No.", FocBundleHeader."No.");
                                            if FocBundleLine.FindSet() then
                                                repeat
                                                    newsalesline := SalesLine;
                                                    NewSalesLine.INT_RelatedItemType_SNY := FocBundleLine."Related Item Type";
                                                    NewSalesLine.INT_RelatedItemNo_SNY := FocBundleLine."Related Item No.";
                                                    NewSalesLine."Line No." := NewLineNo;
                                                    NewLineNo += 10000;
                                                    NewSalesLine.insert(true);
                                                    NewSalesLine.validate("No.", FocBundleLine."Item No.");
                                                    NewSalesLine.validate(Quantity, FocBundleLine.Quantity * SalesLine.Quantity);
                                                    if FocBundleLine."Promotional Price" <> 0 then
                                                        NewSalesLine.validate("Unit Price", FocBundleLine."Promotional Price" / FocBundleLine.Quantity)
                                                    else
                                                        NewSalesLine.validate("Unit Price", FocBundleLine."SRP Price" / FocBundleLine.Quantity);
                                                    NewSalesLine."Location Code" := SalesLine."Location Code";
                                                    NewSalesLine."INT_Bundle Order No._SNY" := FocBundleLine."No.";
                                                    NewSalesLine.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;
                                                    NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                                                    NewSalesLine.INT_MktOrdStatus_SNY := SalesLine.INT_MktOrdStatus_SNY;
                                                    NewSalesLine.INT_RelatedItemType_SNY := FocBundleLine."Related Item Type";
                                                    NewSalesLine.INT_RelatedItemNo_SNY := FocBundleLine."Related Item No.";
                                                    NewSalesLine.INT_RelOrderLineNo_SNY := SalesLine."Line No.";
                                                    NewSalesLine.INT_OrderId_SNY := SalesLine.INT_OrderId_SNY;
                                                    NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                                                    NewSalesLine.INT_DeliverFee_SNY := 0;
                                                    NewSalesLine.Modify(true);
                                                until FocBundleLine.Next() = 0;
                                        end;
                                    until (FocBundleHeader.Next() = 0);// or (HaveFocBundleHeader = true);
                            end;

                        until BundleLine.Next() = 0;


                    if BundleAmount <> SalesLine.Amount then begin
                        if MainModelLineNo = 0 then
                            Error('Bundle Main Model Not Defined');
                        NewSalesLine.get(SalesLine."Document Type", SalesLine."Document No.", MainModelLineNo);
                        NewSalesLine.Validate("Unit Price", (NewSalesLine."Line Amount" - (BundleAmount - SalesLine.Amount)) / NewSalesLine.Quantity);
                        NewSalesLine.Modify(true);
                    end;
                    SalesLine.Original_Quantity := SalesLine.Quantity;
                    //
                    BufferUnitprice := SalesLine."Unit Price";
                    //
                    SalesLine.Validate(Quantity, 0);
                    SalesLine."Unit Price" := BufferUnitprice;
                    SalesLine.Modify(true);
                end;
            until SalesLine.Next() = 0;

        //Explore Foc
        SalesLine.SetFilter(INT_RelatedItemType_SNY, '<>%1&<>%2', SalesLine.INT_RelatedItemType_SNY::FOC, SalesLine.INT_RelatedItemType_SNY::"FOC Dummy");
        if SalesLine.FindSet() then
            repeat
                HaveBundleHeader := false;
                if SalesLine.Quantity <> 0 then begin
                    BundleHeader.Reset();
                    BundleHeader.SETRANGE(Marketplace, SalesHeader.INT_MarketPlace_SNY);
                    BundleHeader.Setrange(Type, BundleHeader.Type::FOC);
                    BundleHeader.Setrange("Item No.", SalesLine."No.");
                    //BundleHeader.SetFilter(Status, '%1|%2', BundleHeader.Status::Certified, BundleHeader.Status::Expired);
                    if BundleHeader.FindFirst() then
                        repeat
                            HaveBundleHeader := (SalesHeader."Order Date" in [BundleHeader."Starting Date" .. BundleHeader."Ending Date"]) and (BundleHeader."Is Active" = true);
                            if HaveBundleHeader then begin
                                BundleLine.Reset();
                                BundleLine.SetRange(Type, BundleHeader.Type);
                                BundleLine.SetRange("No.", BundleHeader."No.");
                                if BundleLine.FindSet() then
                                    repeat
                                        newsalesline := SalesLine;
                                        NewSalesLine.INT_RelatedItemType_SNY := BundleLine."Related Item Type";
                                        NewSalesLine.INT_RelatedItemNo_SNY := BundleLine."Related Item No.";
                                        NewSalesLine."Line No." := NewLineNo;
                                        NewLineNo += 10000;
                                        NewSalesLine.insert(true);
                                        NewSalesLine.validate("No.", BundleLine."Item No.");
                                        NewSalesLine.validate(Quantity, BundleLine.Quantity * SalesLine.Quantity);
                                        if BundleLine."Promotional Price" <> 0 then
                                            NewSalesLine.validate("Unit Price", BundleLine."Promotional Price" / BundleLine.Quantity)
                                        else
                                            NewSalesLine.validate("Unit Price", BundleLine."SRP Price" / BundleLine.Quantity);
                                        NewSalesLine."Location Code" := SalesLine."Location Code";
                                        NewSalesLine."INT_Bundle Order No._SNY" := BundleLine."No.";
                                        NewSalesLine.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;
                                        NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                                        NewSalesLine.INT_MktOrdStatus_SNY := SalesLine.INT_MktOrdStatus_SNY;
                                        NewSalesLine.INT_RelatedItemType_SNY := BundleLine."Related Item Type";
                                        NewSalesLine.INT_RelatedItemNo_SNY := BundleLine."Related Item No.";
                                        NewSalesLine.INT_RelOrderLineNo_SNY := SalesLine."Line No.";
                                        NewSalesLine.INT_OrderId_SNY := SalesLine.INT_OrderId_SNY;
                                        NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                                        NewSalesLine.INT_DeliverFee_SNY := 0;
                                        NewSalesLine.Modify(true);
                                    until BundleLine.Next() = 0;
                            end;
                        until (BundleHeader.Next() = 0);// or (HaveBundleHeader = true);


                end;
            until SalesLine.Next() = 0;
        SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"Explode SO";
        SalesHeader.Modify(true);
    end;

    procedure InsertDeliveryFee2()
    var
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        NewSalesLine: Record "Sales Line";
        BundleSalesLine: Record "Sales Line";
        DeliveryModel: Record INT_DelDummyModel_SNY;
        Item: Record Item;
        NewLineNo: Integer;
        HavePresales: Boolean;
        TotalAmount: Decimal;
        DeliveryFee: Decimal;
    begin
        // Start
        TotalAmount := 0;
        DeliveryFee := 0;
        SalesLine2.reset();
        SalesLine2.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine2.setrange("Document No.", SalesHeader."No.");
        SalesLine2.SetRange(type, SalesLine.Type::Item);
        SalesLine2.Setrange("INT_Delivery Line_SNY", false);
        if SalesLine2.findset() then
            repeat
                TotalAmount += SalesLine2."Line Amount";
            until SalesLine2.next() = 0;

        //End


        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(type, SalesLine.Type::Item);
        if SalesLine.FindLast() then
            NewLineNo := SalesLine."Line No." + 10000
        else
            NewLineNo := 10000;
        SalesLine.setrange("INT_Delivery Line_SNY", false);
        //salesline.SetFilter(INT_DeliverFee_SNY, '>0');
        if SalesLine.FindSet() then
            repeat
                if SalesLine.INT_RelatedItemType_SNY = SalesLine.INT_RelatedItemType_SNY::Virtual then
                    Item.get(SalesLine.INT_RelatedItemNo_SNY)
                else
                    Item.get(SalesLine."No.");
                item.TestField("Retail Product Code");
                if not HavePresales then
                    HavePresales := SalesLine.INT_OrderType_SNY = SalesLine.INT_OrderType_SNY::Presale;
                if not DeliveryModel.get(Item."Retail Product Code") then
                    Error('Define Dummy Delivery Model for Retail Prorduct Group (6D Code) %1', item."Retail Product Code");

                if SalesLine.INT_DeliverFee_SNY > 0 then
                    DeliveryFee := SalesLine.INT_DeliverFee_SNY;

                DeliveryModel.TestField("Item No.");
                if DeliveryFee > 0 then begin
                    NewSalesLine.init();
                    NewSalesLine."Document Type" := SalesHeader."Document Type";
                    NewSalesLine."Document No." := SalesHeader."No.";
                    NewSalesLine."Line No." := NewLineNo;
                    NewSalesLine.Insert(true);
                    NewLineNo += 10000;
                    NewSalesLine.validate(type, newsalesline.type::Item);
                    NewSalesLine.validate("no.", DeliveryModel."Item No.");
                    NewSalesLine.validate(Quantity, SalesLine.Quantity);
                    NewSalesLine.validate("Unit Price", (DeliveryFee / TotalAmount * SalesLine."Line Amount") / SalesLine.Quantity);
                    NewSalesLine."INT_Delivery Line_SNY" := true;

                    NewSalesLine.INT_RelatedItemType_SNY := NewSalesLine.INT_RelatedItemType_SNY::"Main Delivery";

                    if SalesLine.INT_RelatedItemType_SNY = SalesLine.INT_RelatedItemType_SNY::Virtual then
                        NewSalesLine.INT_RelatedItemNo_SNY := SalesLine.INT_RelatedItemNo_SNY
                    else
                        NewSalesLine.INT_RelatedItemNo_SNY := SalesLine."No.";
                    NewSalesLine.INT_MktOrdStatus_SNY := SalesLine.INT_MktOrdStatus_SNY;
                    NewSalesLine.INT_MktOrderLineID_SNY := salesline.INT_MktOrderLineID_SNY;
                    NewSalesLine.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;
                    NewSalesLine.INT_OrderType_SNY := SalesLine.INT_OrderType_SNY;
                    NewSalesLine.INT_ItemType_SNY := SalesLine.INT_ItemType_SNY;
                    NewSalesLine.INT_OrderId_SNY := SalesLine.INT_OrderId_SNY;
                    //
                    NewSalesLine."INT_Rebate Amount_SNY" := 0;
                    //
                    NewSalesLine.Modify(true);
                end;
            until SalesLine.Next() = 0;
        if HavePresales then begin
            SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::Presales;
            SalesHeader.INT_OrderType_SNY := SalesHeader.INT_OrderType_SNY::Presale;
        end else
            SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"Inventory N/A";
        SalesHeader.Modify(true);

    end;

    procedure ReprocessSalesOrder2(SH: Record "Sales Header")
    var
        UpdateStatus: Codeunit INT_SyncMktStatus_SNY;
        UpdateSalesHeader: Record "Sales Header";
        InterfaceSetup: Record INT_InterfaceSetup_SNY;
        SalesLineL: Record "Sales Line";
    begin
        SetOrder(SH);
        SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split";
        salesheader.INT_ProcessErr_SNY := '';
        SalesHeader.Modify();
        DeleteSystemCreatedSalesLine();
        InterfaceSetup.Get();
        if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"PSG/BUN Split" then begin
            ExplodeOrder2();
            Commit();
        end;

        if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Explode SO" then begin
            InsertDeliveryFee2();
            Commit();
        end;

        if (SalesHeader.INT_InternalProcessing_SNY in [SalesHeader.INT_InternalProcessing_SNY::"Delivery Fee", SalesHeader.INT_InternalProcessing_SNY::Presales])
                and (SalesHeader.INT_OrderType_SNY = SalesHeader.INT_OrderType_SNY::Presale) then begin
            ProcessPreslaesOrder();
            Commit();
        end;

        if SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Inventory N/A" then begin
            CheckInventory();
            Commit();
        end;

        //SellVoucherCalculate 
        SalesHeader.CalcFields(Amount);
        if (SalesHeader."Seller Voucher Amount" <> 0) and (SalesHeader."Amount" <> 0) then begin
            SellVoucherCalculate();
        end;
        //SellVoucherCalculate 


        if (SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Inventory Checked")
         and (not SalesHeader.INT_DelConfirmed_SNY) then begin
            DeliveryConfirm2(false);
            Commit();
        end;

        /*
        if ((SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::"Inventory Checked") or
            (SalesHeader.INT_InternalProcessing_SNY = SalesHeader.INT_InternalProcessing_SNY::Completed))
            and (SalesHeader.INT_SimpleStatus_SNY = SalesHeader.INT_SimpleStatus_SNY::"Not Started") then begin
            SynctoSAP(false);
        end;
        */
        if InterfaceSetup."Auto Set Lazada Inv" then
            if SalesHeader.INT_InvCheck_SNY then begin
                Commit();
                clear(UpdateStatus);
                UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                UpdateStatus.SetOrder(UpdateSalesHeader, 10);
                if not UpdateStatus.Run() then begin
                    UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                    UpdateSalesHeader.INT_ProcessErr_SNY := GetLastErrorText;
                    UpdateSalesHeader.Modify();
                end;
                Commit();
                clear(UpdateStatus);
                UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                UpdateStatus.SetOrder(UpdateSalesHeader, 20);
                if not UpdateStatus.run() then begin
                    UpdateSalesHeader.get(SalesHeader."Document Type", SalesHeader."No.");
                    UpdateSalesHeader.INT_ProcessErr_SNY := GetLastErrorText;
                    UpdateSalesHeader.Modify();
                    Commit();
                end;
            end;

        if SalesHeader.INT_SAPOrderID_SNY <> '' then
            PostingShipments();

    end;

    procedure FullfillmentReturnOrder(ReturnSalesHeader: Record "Sales Header")
    var
        ReturnSalesLine: Record "Sales Line";
        FullfillmentSalesHeader: Record "Sales Header";
        FullfillmentSalesLine: Record "Sales Line";
    begin
        FullfillmentSalesHeader.Reset;
        FullfillmentSalesLine.Reset;

        FullfillmentSalesHeader.Setrange("External Document No.", ReturnSalesHeader."External Document No.");
        if FullfillmentSalesHeader.FindFirst() then begin
            FullfillmentSalesLine.SetRange("Document Type", FullfillmentSalesHeader."Document Type");
            FullfillmentSalesLine.SetRange("Document No.", FullfillmentSalesHeader."No.");
            if FullfillmentSalesLine.FindSet() then
                repeat
                    ReturnSalesLine.Reset;
                    ReturnSalesLine.Setrange("Document Type", ReturnSalesHeader."Document Type");
                    ReturnSalesLine.Setrange("Document No.", ReturnSalesHeader."No.");
                    ReturnSalesLine.Setrange("No.", FullfillmentSalesLine."No.");
                    if ReturnSalesLine.findfirst() then begin
                        ReturnSalesLine.INT_DeliveryType_SNY := FullfillmentSalesLine.INT_DeliveryType_SNY;
                        ReturnSalesHeader.INT_DeliveryType_SNY := FullfillmentSalesLine.INT_DeliveryType_SNY;
                        ReturnSalesLine.Modify();
                        ReturnSalesHeader.Modify();
                        Commit();
                    end;
                until FullfillmentSalesLine.next() = 0;
        end;

    end;

    local procedure ProcessReturnOrder2()
    var
        SalesHeader2: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        NewSalesLine: Record "Sales Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        LineNo: Integer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        HaveSAPId: Boolean;
    begin
        //Get SAP Invoice ID
        SalesSetup.get();
        SalesSetup.TestField(INT_ReturnCode_SNY);
        HaveSAPId := false;
        if SalesHeader.INT_SAPInvoiceID_SNY = '' then begin
            SalesLine.reset();
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.setrange("Document No.", SalesHeader."No.");
            SalesLine.FindLast();
            SalesLine.RESET();

            SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
            Salesline.setrange(INT_OrderId_SNY, SalesHeader.INT_MktplaceOrderID_SNY);
            SalesLine.SETRANGE(INT_MktOrderLineID_SNY, SalesLine.INT_MktOrderLineID_SNY);
            SalesLine.SetRange("Document No.");

            IF SalesLine.FindFirst() THEN begin
                SalesHeader2.get(SalesLine."Document Type", SalesLine."Document No.");
                HaveSAPId := SalesHeader2.INT_SAPInvoiceID_SNY <> '';
            end;
            if not HaveSAPId then begin
                SalesShipmentLine.Reset();
                SalesShipmentLine.SETRANGE(int_orderid_sny, SalesHeader.INT_MktplaceOrderID_SNY);
                SalesShipmentLine.SETRANGE(INT_MktOrderLineID_SNY, SalesLine.INT_MktOrderLineID_SNY);
                HaveSAPId := (not SalesShipmentLine.IsEmpty());
                SalesShipmentHeader.Init();
                if HaveSAPId then begin
                    SalesShipmentLine.FindFirst();
                    SalesShipmentHeader.get(SalesShipmentLine."Document No.");
                end;
                SalesHeader2.TransferFields(SalesShipmentHeader);

            end;
            if HaveSAPId then begin
                SalesHeader.INT_SAPInvoiceID_SNY := SalesHeader2.INT_SAPInvoiceID_SNY;
                SalesHeader.INT_SAPOrderID_SNY := SalesHeader2.INT_SAPOrderID_SNY;
                SalesHeader.Modify();
            end;

        end;
        //Code to pick SAP Invoice ID from Sales Invoice 13/Oct/2020
        if SalesHeader.INT_SAPInvoiceID_SNY = '' then begin
            SalesInvoiceLine.Reset();
            SalesInvoiceLine.SETRANGE(int_orderid_sny, SalesHeader.INT_MktplaceOrderID_SNY);
            SalesInvoiceLine.SETRANGE(INT_MktOrderLineID_SNY, SalesLine.INT_MktOrderLineID_SNY);
            // HaveSAPId := (not SalesInvoiceLine.IsEmpty());
            SalesInvoiceHeader.Init();
            // if HaveSAPId then begin
            if SalesInvoiceLine.FindFirst() then begin
                SalesInvoiceHeader.get(SalesInvoiceLine."Document No.");
                // end;
                // SalesHeader2.TransferFields(SalesShipmentHeader);
                SalesHeader.INT_SAPInvoiceID_SNY := SalesInvoiceHeader.INT_SAPInvoiceID_SNY;
                SalesHeader.INT_SAPOrderID_SNY := SalesInvoiceHeader.INT_SAPOrderID_SNY;
                SalesHeader.Modify();
            end;

        end;
        if SalesHeader.INT_SAPInvoiceID_SNY = '' then begin
            if SalesHeader2.INT_BCOrderNo_SNY <> '' then begin
                SalesHeader.INT_BCOrderNo_SNY := SalesHeader2.INT_BCOrderNo_SNY;
                SalesHeader.Modify();
            end;
            clear(AlertMgmt);
            JobQueueEntry."Parameter String" := 'CHECK_RET_SAPINV';
            AlertMgmt.SetSalesHeader(SalesHeader);
            Commit();//added to remove codeunit call error
            if not AlertMgmt.Run(JobQueueEntry) then begin//begin end added
                Message('Unable to Send missing SAP Invoice Id alert:\Error:', GetLastErrorText);
                exit;
            end;
        end;

        /* SalesLine.reset();
         SalesLine.SetRange("Document Type", SalesHeader."Document Type");
         SalesLine.setrange("Document No.", SalesHeader."No.");
         SalesLine.FindLast();
         LineNo := SalesLine."Line No." + 10000;
         SalesLine.setrange("Line No.", 0, LineNo - 1);
         if SalesLine.FindFirst() then
             repeat
                 if (SalesLine.INT_OrderId_SNY <> '') and (salesline.INT_MktOrderLineID_SNY <> '') then begin
                     SalesLine2.reset();
                     SalesLine2.SetRange("Document Type", SalesLine2."Document Type"::Order);
                     SalesLine2.setrange(INT_OrderId_SNY, SalesLine.INT_OrderId_SNY);
                     SalesLine2.SetRange(INT_MktOrderLineID_SNY, SalesLine.INT_MktOrderLineID_SNY);
                     SalesLine2.SetFilter("No.", '<>%1', SalesLine."No.");
                     if SalesLine2.FindFirst() then
                         repeat
                             InsertReturnSalesLine2(SalesLine2, SalesHeader, NewSalesLine, LineNo);
                             LineNo += 10000;
                         until SalesLine2.Next() = 0
                     else begin
                         SalesShipmentLine.Reset();
                         SalesShipmentLine.setrange(INT_OrderId_SNY, SalesLine.INT_OrderId_SNY);
                         SalesShipmentLine.SetRange(INT_MktOrderLineID_SNY, SalesLine.INT_MktOrderLineID_SNY);
                         SalesShipmentLine.SetFilter("No.", '<>%1', SalesLine."No.");
                         if SalesShipmentLine.FindSet() then
                             repeat
                                 SalesLine2.TransferFields(SalesShipmentLine);

                                 InsertReturnSalesLine2(SalesLine2, SalesHeader, NewSalesLine, LineNo);
                                 LineNo += 10000;
                             until SalesShipmentLine.Next() = 0;
                     end;
                 end;
             until SalesLine.Next() = 0;
            */
        SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::Completed;
        SalesHeader.INT_InvCheck_SNY := true;
        SalesHeader.INT_OrderStatus_SNY := SalesHeader.INT_OrderStatus_SNY::Processed;

        SalesHeader.Modify();


        Commit();

    end;

    local procedure InsertReturnSalesLine2(FromSalesLine: Record "Sales Line"; ToSalesHeader: Record "Sales header"; var NewSalesLine: Record "Sales Line"; LineNo: Integer)
    begin
        NewSalesLine.init();
        NewSalesLine."Document Type" := ToSalesHeader."Document Type";
        NewSalesLine."Document No." := ToSalesHeader."No.";
        NewSalesLine."Line No." := LineNo;
        NewSalesLine.Insert(true);
        NewSalesLine.Validate(type, FromSalesLine.Type);
        NewSalesLine.Validate("No.", FromSalesLine."No.");
        NewSalesLine.validate(Quantity, FromSalesLine.Quantity);
        // NewSalesLine.validate("unit price", FromSalesLine."Unit Price");
        NewSalesLine."INT_Bundle Order No._SNY" := FromSalesLine."INT_Bundle Order No._SNY";
        NewSalesLine.INT_DeliveryType_SNY := FromSalesLine.INT_DeliveryType_SNY;
        NewSalesLine.INT_MktOrderLineID_SNY := FromSalesLine.INT_MktOrderLineID_SNY;
        NewSalesLine.INT_MktOrdStatus_SNY := FromSalesLine.INT_MktOrdStatus_SNY;
        NewSalesLine.INT_RelatedItemType_SNY := FromSalesLine.INT_RelatedItemType_SNY;
        NewSalesLine.INT_RelatedItemNo_SNY := FromSalesLine.INT_RelatedItemNo_SNY;
        NewSalesLine.INT_RelOrderLineNo_SNY := FromSalesLine.INT_RelOrderLineNo_SNY;
        NewSalesLine.INT_OrderId_SNY := FromSalesLine.INT_OrderId_SNY;
        NewSalesLine.INT_MktOrderLineID_SNY := FromSalesLine.INT_MktOrderLineID_SNY;
        NewSalesLine."Return Reason Code" := SalesSetup.INT_ReturnCode_SNY;
        NewSalesLine.Modify(true)
    end;

    procedure ReturnInsertDeliveryFee()
    var
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        NewSalesLine: Record "Sales Line";
        BundleSalesLine: Record "Sales Line";
        DeliveryModel: Record INT_DelDummyModel_SNY;
        Item: Record Item;
        NewLineNo: Integer;
        HavePresales: Boolean;
        TotalAmount: Decimal;
        DeliveryFee: Decimal;
    begin
        // Start
        TotalAmount := 0;
        DeliveryFee := 0;
        SalesLine2.reset();
        SalesLine2.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine2.setrange("Document No.", SalesHeader."No.");
        SalesLine2.SetRange(type, SalesLine.Type::Item);
        SalesLine2.Setrange("INT_Delivery Line_SNY", false);
        if SalesLine2.findset() then
            repeat
                TotalAmount += SalesLine2."Line Amount";
            until SalesLine2.next() = 0;

        //End


        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(type, SalesLine.Type::Item);
        if SalesLine.FindLast() then
            NewLineNo := SalesLine."Line No." + 10000
        else
            NewLineNo := 10000;
        SalesLine.setrange("INT_Delivery Line_SNY", false);
        //salesline.SetFilter(INT_DeliverFee_SNY, '>0');
        if SalesLine.FindSet() then
            repeat
                if SalesLine.INT_RelatedItemType_SNY = SalesLine.INT_RelatedItemType_SNY::Virtual then
                    Item.get(SalesLine.INT_RelatedItemNo_SNY)
                else
                    Item.get(SalesLine."No.");
                item.TestField("Retail Product Code");
                if not HavePresales then
                    HavePresales := SalesLine.INT_OrderType_SNY = SalesLine.INT_OrderType_SNY::Presale;
                if not DeliveryModel.get(Item."Retail Product Code") then
                    Error('Define Dummy Delivery Model for Retail Prorduct Group (6D Code) %1', item."Retail Product Code");

                if SalesLine.INT_DeliverFee_SNY > 0 then
                    DeliveryFee := SalesLine.INT_DeliverFee_SNY;

                DeliveryModel.TestField("Item No.");
                if DeliveryFee > 0 then begin
                    NewSalesLine.init();
                    NewSalesLine."Document Type" := SalesHeader."Document Type";
                    NewSalesLine."Document No." := SalesHeader."No.";
                    NewSalesLine."Line No." := NewLineNo;
                    NewSalesLine.Insert(true);
                    NewLineNo += 10000;
                    NewSalesLine.validate(type, newsalesline.type::Item);
                    NewSalesLine.validate("no.", DeliveryModel."Item No.");
                    NewSalesLine.validate(Quantity, SalesLine.Quantity);
                    NewSalesLine.validate("Unit Price", (DeliveryFee / TotalAmount * SalesLine."Line Amount") / SalesLine.Quantity);
                    NewSalesLine."INT_Delivery Line_SNY" := true;

                    NewSalesLine.INT_RelatedItemType_SNY := NewSalesLine.INT_RelatedItemType_SNY::"Main Delivery";

                    if SalesLine.INT_RelatedItemType_SNY = SalesLine.INT_RelatedItemType_SNY::Virtual then
                        NewSalesLine.INT_RelatedItemNo_SNY := SalesLine.INT_RelatedItemNo_SNY
                    else
                        NewSalesLine.INT_RelatedItemNo_SNY := SalesLine."No.";
                    NewSalesLine.INT_MktOrdStatus_SNY := SalesLine.INT_MktOrdStatus_SNY;
                    NewSalesLine.INT_MktOrderLineID_SNY := salesline.INT_MktOrderLineID_SNY;
                    NewSalesLine.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;
                    NewSalesLine.INT_OrderType_SNY := SalesLine.INT_OrderType_SNY;
                    NewSalesLine.INT_ItemType_SNY := SalesLine.INT_ItemType_SNY;
                    NewSalesLine.INT_OrderId_SNY := SalesLine.INT_OrderId_SNY;
                    NewSalesLine.Modify(true);
                end;
            until SalesLine.Next() = 0;
    end;

    procedure ReturnExplodeOrder2()
    var
        SalesLine: Record "Sales Line";
        BundleHeader: Record INT_BundleHeader_SNY;
        BundleLine: Record INT_BundleLine_SNY;
        FocBundleHeader: Record INT_BundleHeader_SNY;
        FocBundleLine: Record INT_BundleLine_SNY;
        NewSalesLine: Record "Sales Line";

        Item: Record Item;
        BundleAmount: Decimal;
        NewLineNo: Integer;
        MainModelLineNo: Integer;
        HaveBundleHeader: Boolean;
        HaveFocBundleHeader: Boolean;
        BundlePackageDetailsErr: Label 'Bundle Details could not found package no. %1';
    begin
        // Message('%1,%2', SalesHeader."Document Type", SalesHeader."No.");
        //Explode Bundle
        SalesLine.reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            NewLineNo := SalesLine."Line No." + 10000
        ELSE
            NewLineNo := 10000;
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange(INT_RelatedItemType_SNY, SalesLine.INT_RelatedItemType_SNY::Main);
        SalesLine.SetRange("Line No.", 0, NewLineNo - 1);
        if SalesLine.findset() then
            repeat

                item.get(SalesLine."No.");
                if item.INT_MainModel_SNY <> '' then begin
                    MainModelLineNo := 0;
                    BundleAmount := 0;
                    BundleHeader.Reset();
                    BundleHeader.SETRANGE(Marketplace, SalesHeader.INT_MarketPlace_SNY);
                    BundleHeader.Setrange(Type, BundleHeader.Type::Package);
                    BundleHeader.Setrange("Item No.", SalesLine."No.");
                    BundleHeader.SetFilter(Status, '%1|%2', BundleHeader.Status::Certified, BundleHeader.Status::Expired);
                    if 1 = 1 then begin

                        HaveBundleHeader := false;
                        if BundleHeader.FindFirst() then
                            repeat
                                if SalesHeader."Order Date" in [BundleHeader."Starting Date" .. BundleHeader."Ending Date"] then
                                    HaveBundleHeader := true;
                            until (BundleHeader.Next() = 0) or HaveBundleHeader = true;
                    end else
                        HaveBundleHeader := true;
                    if not HaveBundleHeader then
                        Error(BundlePackageDetailsErr, SalesLine."No.");
                    BundleLine.Reset();
                    BundleLine.SetRange(Type, BundleHeader.Type);
                    BundleLine.SetRange("No.", BundleHeader."No.");
                    if BundleLine.FindSet() then
                        repeat
                            newsalesline := SalesLine;
                            NewSalesLine.INT_RelatedItemType_SNY := BundleLine."Related Item Type";
                            NewSalesLine.INT_RelatedItemNo_SNY := BundleLine."Related Item No.";
                            NewSalesLine."Line No." := NewLineNo;
                            NewLineNo += 10000;
                            NewSalesLine.insert(true);
                            NewSalesLine.validate("No.", BundleLine."Item No.");
                            NewSalesLine.validate(Quantity, BundleLine.Quantity * SalesLine.Quantity);
                            if BundleLine."Promotional Price" <> 0 then
                                NewSalesLine.validate("Unit Price", BundleLine."Promotional Price" / BundleLine.Quantity)
                            else
                                NewSalesLine.validate("Unit Price", BundleLine."SRP Price" / BundleLine.Quantity);
                            NewSalesLine."Location Code" := SalesLine."Location Code";
                            NewSalesLine."INT_Bundle Order No._SNY" := BundleLine."No.";
                            NewSalesLine.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;
                            NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                            NewSalesLine.INT_MktOrdStatus_SNY := SalesLine.INT_MktOrdStatus_SNY;
                            NewSalesLine.INT_RelatedItemType_SNY := BundleLine."Related Item Type";
                            NewSalesLine.INT_RelatedItemNo_SNY := BundleLine."Related Item No.";
                            NewSalesLine.INT_RelOrderLineNo_SNY := SalesLine."Line No.";
                            NewSalesLine.INT_OrderId_SNY := SalesLine.INT_OrderId_SNY;
                            NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;

                            NewSalesLine.INT_DeliverFee_SNY := 0;
                            BundleAmount += NewSalesLine."Line Amount";
                            NewSalesLine.Modify(true);
                            if (MainModelLineNo = 0) and BundleLine."Main Item for Delivery" then
                                MainModelLineNo := NewSalesLine."Line No.";

                            if BundleLine."Main Item for Delivery" then begin
                                Item.get(BundleLine."Item No.");
                                item.TestField("Retail Product Code");
                                SalesLine."Retail Product Code" := item."Retail Product Code";
                                SalesLine.Org_INT_RelatedItemType_SNY := SalesLine.INT_RelatedItemType_SNY;//US 25nov2020
                                SalesLine.INT_RelatedItemType_SNY := SalesLine.INT_RelatedItemType_SNY::Virtual;
                                SalesLine.INT_RelatedItemNo_SNY := BundleLine."Item No.";
                                SalesLine.Modify();
                            end;
                            if BundleLine."Explode FOC Item" then begin
                                HaveFocBundleHeader := false;
                                FocBundleHeader.Reset();
                                FocBundleHeader.SETRANGE(Marketplace, SalesHeader.INT_MarketPlace_SNY);
                                FocBundleHeader.Setrange(Type, FocBundleHeader.Type::FOC);
                                FocBundleHeader.Setrange("Item No.", BundleLine."Item No.");
                                //FocBundleHeader.SetFilter(Status, '%1|%2', FocBundleHeader.Status::Certified, FocBundleHeader.Status::Expired);
                                if FocBundleHeader.FindFirst() then
                                    repeat

                                        HaveFocBundleHeader := (SalesHeader."Order Date" in [FocBundleHeader."Starting Date" .. FocBundleHeader."Ending Date"]) and (BundleHeader."Is Active" = true);

                                        if HaveFocBundleHeader then begin
                                            FocBundleLine.Reset();
                                            FocBundleLine.SetRange(Type, FocBundleHeader.Type);
                                            FocBundleLine.SetRange("No.", FocBundleHeader."No.");
                                            if FocBundleLine.FindSet() then
                                                repeat
                                                    newsalesline := SalesLine;
                                                    NewSalesLine.INT_RelatedItemType_SNY := FocBundleLine."Related Item Type";
                                                    NewSalesLine.INT_RelatedItemNo_SNY := FocBundleLine."Related Item No.";
                                                    NewSalesLine."Line No." := NewLineNo;
                                                    NewLineNo += 10000;
                                                    NewSalesLine.insert(true);
                                                    NewSalesLine.validate("No.", FocBundleLine."Item No.");
                                                    NewSalesLine.validate(Quantity, FocBundleLine.Quantity * SalesLine.Quantity);
                                                    if FocBundleLine."Promotional Price" <> 0 then
                                                        NewSalesLine.validate("Unit Price", FocBundleLine."Promotional Price" / FocBundleLine.Quantity)
                                                    else
                                                        NewSalesLine.validate("Unit Price", FocBundleLine."SRP Price" / FocBundleLine.Quantity);
                                                    NewSalesLine."Location Code" := SalesLine."Location Code";
                                                    NewSalesLine."INT_Bundle Order No._SNY" := FocBundleLine."No.";
                                                    NewSalesLine.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;
                                                    NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                                                    NewSalesLine.INT_MktOrdStatus_SNY := SalesLine.INT_MktOrdStatus_SNY;
                                                    NewSalesLine.INT_RelatedItemType_SNY := FocBundleLine."Related Item Type";
                                                    NewSalesLine.INT_RelatedItemNo_SNY := FocBundleLine."Related Item No.";
                                                    NewSalesLine.INT_RelOrderLineNo_SNY := SalesLine."Line No.";
                                                    NewSalesLine.INT_OrderId_SNY := SalesLine.INT_OrderId_SNY;
                                                    NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                                                    NewSalesLine.INT_DeliverFee_SNY := 0;
                                                    NewSalesLine.Modify(true);
                                                until FocBundleLine.Next() = 0;
                                        end;
                                    until (FocBundleHeader.Next() = 0);// or (HaveFocBundleHeader = true);
                            end;

                        until BundleLine.Next() = 0;


                    if BundleAmount <> SalesLine.Amount then begin
                        if MainModelLineNo = 0 then
                            Error('Bundle Main Model Not Defined');
                        NewSalesLine.get(SalesLine."Document Type", SalesLine."Document No.", MainModelLineNo);
                        NewSalesLine.Validate("Unit Price", (NewSalesLine."Line Amount" - (BundleAmount - SalesLine.Amount)) / NewSalesLine.Quantity);
                        NewSalesLine.Modify(true);
                    end;
                    SalesLine.Original_Quantity := SalesLine.Quantity;
                    SalesLine.Validate(Quantity, 0);
                    SalesLine.Modify(true);
                end;
            until SalesLine.Next() = 0;

        //Explore Foc
        SalesLine.SetFilter(INT_RelatedItemType_SNY, '<>%1&<>%2', SalesLine.INT_RelatedItemType_SNY::FOC, SalesLine.INT_RelatedItemType_SNY::"FOC Dummy");
        if SalesLine.FindSet() then
            repeat
                HaveBundleHeader := false;
                if SalesLine.Quantity <> 0 then begin
                    BundleHeader.Reset();
                    BundleHeader.SETRANGE(Marketplace, SalesHeader.INT_MarketPlace_SNY);
                    BundleHeader.Setrange(Type, BundleHeader.Type::FOC);
                    BundleHeader.Setrange("Item No.", SalesLine."No.");
                    //BundleHeader.SetFilter(Status, '%1|%2', BundleHeader.Status::Certified, BundleHeader.Status::Expired);
                    if BundleHeader.FindFirst() then
                        repeat
                            HaveBundleHeader := (SalesHeader."Order Date" in [BundleHeader."Starting Date" .. BundleHeader."Ending Date"]) and (BundleHeader."Is Active" = true);
                            if HaveBundleHeader then begin
                                BundleLine.Reset();
                                BundleLine.SetRange(Type, BundleHeader.Type);
                                BundleLine.SetRange("No.", BundleHeader."No.");
                                if BundleLine.FindSet() then
                                    repeat
                                        newsalesline := SalesLine;
                                        NewSalesLine.INT_RelatedItemType_SNY := BundleLine."Related Item Type";
                                        NewSalesLine.INT_RelatedItemNo_SNY := BundleLine."Related Item No.";
                                        NewSalesLine."Line No." := NewLineNo;
                                        NewLineNo += 10000;
                                        NewSalesLine.insert(true);
                                        NewSalesLine.validate("No.", BundleLine."Item No.");
                                        NewSalesLine.validate(Quantity, BundleLine.Quantity * SalesLine.Quantity);
                                        if BundleLine."Promotional Price" <> 0 then
                                            NewSalesLine.validate("Unit Price", BundleLine."Promotional Price" / BundleLine.Quantity)
                                        else
                                            NewSalesLine.validate("Unit Price", BundleLine."SRP Price" / BundleLine.Quantity);
                                        NewSalesLine."Location Code" := SalesLine."Location Code";
                                        NewSalesLine."INT_Bundle Order No._SNY" := BundleLine."No.";
                                        NewSalesLine.INT_DeliveryType_SNY := SalesLine.INT_DeliveryType_SNY;
                                        NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                                        NewSalesLine.INT_MktOrdStatus_SNY := SalesLine.INT_MktOrdStatus_SNY;
                                        NewSalesLine.INT_RelatedItemType_SNY := BundleLine."Related Item Type";
                                        NewSalesLine.INT_RelatedItemNo_SNY := BundleLine."Related Item No.";
                                        NewSalesLine.INT_RelOrderLineNo_SNY := SalesLine."Line No.";
                                        NewSalesLine.INT_OrderId_SNY := SalesLine.INT_OrderId_SNY;
                                        NewSalesLine.INT_MktOrderLineID_SNY := SalesLine.INT_MktOrderLineID_SNY;
                                        NewSalesLine.INT_DeliverFee_SNY := 0;
                                        NewSalesLine.Modify(true);
                                    until BundleLine.Next() = 0;
                            end;
                        until (BundleHeader.Next() = 0);// or (HaveBundleHeader = true);


                end;
            until SalesLine.Next() = 0;
        // SalesHeader.INT_InternalProcessing_SNY := SalesHeader.INT_InternalProcessing_SNY::"Explode SO";
        // SalesHeader.Modify(true);
    end;

    procedure SellVoucherCalculate()
    var
        totalamount: Decimal;
        checksenario: Boolean;
        resetsalesline: Record "Sales Line";

    begin
        //reset linediscount
        resetsalesline.reset;

        resetsalesline.SetRange("Document Type", SalesHeader."Document Type");
        resetsalesline.SetRange("Document No.", SalesHeader."No.");
        resetsalesline.SetRange(Type, resetsalesline.Type::Item);
        resetsalesline.SetFilter("Line Discount Amount", '>%1', 0);
        if resetsalesline.Find('-') then begin
            repeat
                resetsalesline.Validate("Line Discount Amount", 0);
                resetsalesline.Modify();
                Commit();
            until resetsalesline.next = 0;
        end;
        //reset linediscount

        //calculatediscount 
        checksenario := false;
        checkLine := 0;
        SalesHeader.CalcFields("Amount Including VAT");
        SalesHeader.CalcFields(Amount);
        totalamount := 0;
        if (SalesHeader."Seller Voucher Amount" <> 0) and (SalesHeader."Amount" <> 0) then begin
            //SellVourcher := SalesHeader."Seller Voucher Amount";
            //count discount line
            INT_salesline3.reset;
            INT_salesline3.SetRange("Document Type", SalesHeader."Document Type");
            INT_salesline3.SetRange("Document No.", SalesHeader."No.");
            INT_salesline3.SetRange(Type, INT_salesline3.Type::Item);
            INT_salesline3.SetFilter(Quantity, '>%1', 0);
            if INT_salesline3.find('-') then begin
                INT_salesline3.CalcSums("Line Amount");
                totalamount := INT_salesline3."Line Amount";
            end;

            INT_salesline3.reset;
            INT_salesline3.SetRange("Document Type", SalesHeader."Document Type");
            INT_salesline3.SetRange("Document No.", SalesHeader."No.");
            INT_salesline3.SetRange(Type, INT_salesline3.Type::Item);
            INT_salesline3.SetFilter(Quantity, '>%1', 0);
            INT_salesline3.SetRange(INT_Exclude_Discount_SNY, false);
            if INT_salesline3.find('-') then begin
                checkLine := INT_salesline3.Count;
            end;
            //count discount line
            if checkLine = 1 then begin
                //first senario
                SellVourcher := 0;
                INT_salesline3.reset;
                INT_salesline3.SetRange("Document Type", SalesHeader."Document Type");
                INT_salesline3.SetRange("Document No.", SalesHeader."No.");
                INT_salesline3.SetRange(Type, INT_salesline3.Type::Item);
                INT_salesline3.SetFilter(Quantity, '>%1', 0);
                INT_salesline3.SetRange(INT_Exclude_Discount_SNY, false);
                if INT_salesline3.find('-') then begin
                    if SalesHeader."Seller Voucher Amount" <= INT_salesline3."Line Amount" then begin
                        INT_salesline3.Validate("Line Discount Amount", SalesHeader."Seller Voucher Amount");
                        INT_salesline3.Modify();
                        Commit();
                        checksenario := true;
                    end;
                end;
                //first senario

                //Third senario
                if checksenario = false then begin
                    INT_salesline3.reset;
                    INT_salesline3.SetRange("Document Type", SalesHeader."Document Type");
                    INT_salesline3.SetRange("Document No.", SalesHeader."No.");
                    INT_salesline3.SetRange(Type, INT_salesline3.Type::Item);
                    INT_salesline3.SetFilter(Quantity, '>%1', 0);
                    INT_salesline3.SetRange(INT_Exclude_Discount_SNY, false);
                    if INT_salesline3.find('-') then begin
                        if SalesHeader."Seller Voucher Amount" > INT_salesline3."Line Amount" then begin
                            SellVourcher := SalesHeader."Seller Voucher Amount" - INT_salesline3."Line Amount";
                            INT_salesline3.Validate("Line Discount Amount", INT_salesline3."Line Amount");
                            INT_salesline3.Modify();
                            Commit();
                        end;

                        INT_salesline4.reset;
                        INT_salesline3.SetCurrentKey("Amount Including VAT");
                        INT_salesline4.SetRange("Document Type", SalesHeader."Document Type");
                        INT_salesline4.SetRange("Document No.", SalesHeader."No.");
                        INT_salesline4.SetRange(Type, INT_salesline3.Type::Item);
                        INT_salesline4.SetFilter(Quantity, '>%1', 0);
                        INT_salesline4.SetRange(INT_Exclude_Discount_SNY, true);
                        if INT_salesline4.find('+') then begin
                            repeat
                                if totalamount > SellVourcher then begin
                                    INT_salesline4.Validate("Line Discount Amount", SellVourcher);
                                    SellVourcher := 0;
                                end;
                                if SellVourcher > 0 then begin
                                    INT_salesline4.Validate("Line Discount Amount", SellVourcher);
                                    SellVourcher := SellVourcher - (INT_salesline4."Line Discount Amount");
                                end;
                                INT_salesline4.Modify();
                                Commit();
                            until (INT_salesline4.Next(-1) = 0) or (SellVourcher = 0);
                        end;
                    end;
                end;
                //Third senario
            end;

            //Second senario
            if checkLine > 1 then begin
                SellVourcher := 0;
                checkLine2 := 0;
                INT_salesline3.reset;
                INT_salesline3.SetCurrentKey("Amount Including VAT");
                INT_salesline3.SetRange("Document Type", SalesHeader."Document Type");
                INT_salesline3.SetRange("Document No.", SalesHeader."No.");
                INT_salesline3.SetRange(Type, INT_salesline3.Type::Item);
                INT_salesline3.SetFilter(Quantity, '>%1', 0);
                INT_salesline3.SetRange(INT_Exclude_Discount_SNY, false);
                if INT_salesline3.find('+') then begin
                    repeat

                        checkLine2 += 1;
                        if checkLine = checkLine2 then begin
                            INT_salesline3.Validate("Line Discount Amount", SalesHeader."Seller Voucher Amount" - SellVourcher);
                        end else begin
                            calculatelineamount := ((INT_salesline3."Line Amount" * SalesHeader."Seller Voucher Amount") / totalamount);
                            INT_salesline3.Validate("Line Discount Amount", calculatelineamount);
                            SellVourcher += calculatelineamount;
                        end;
                        INT_salesline3.Modify();
                        Commit();

                    until INT_salesline3.Next(-1) = 0;
                end;
            end;
            //Second senario
        end;
        //calculatediscount
    end;
}