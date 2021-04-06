codeunit 60006 "INT_Inventory_allocation_SNY"
{
    trigger OnRun()
    begin

    end;

    procedure GetDataToCalitemAllcation(itemjournal: Record "Item Journal Line"; xItem: Record Item)
    var
        xItemJour: Record "Item Journal Line";
        INT_EcomInterface_SNY: Codeunit INT_EcomInterface_SNY;
        CustomQTY: Decimal;
        GetLOCQTY: Decimal;
        UseCustomInventory: Boolean;
        Getitem: Record item;
        inventorysetup: Record "Inventory Setup";
    begin
        UseCustomInventory := false;
        inventorysetup.get;
        xItemJour := itemjournal;
        xItemJour.reset;
        xItemJour.SetRange("No.", '<>%1', '');
        if xItemJour.find('-') then begin
            repeat
                //Message('%1', xItemJour."Item No.");
                INT_EcomInterface_SNY.GetCustomInventory('', xItemJour."Item No.", xItemJour."Unit of Measure Code", CustomQTY,
                inventorysetup.INT_LOCATION_MAIN, 100, true, UseCustomInventory);
                GetLOCQTY := GetLocInventory(inventorysetup.INT_LOCATION_MAIN, 100, true, xItemJour."Item No.");

                if Getitem.get(xItemJour."Item No.") then begin
                    if CustomQTY > GetLOCQTY then
                        AllcationItem(Getitem, CustomQTY)
                    else
                        AllcationItem(Getitem, GetLOCQTY);
                end
            //Message('CustomQTY %1 LOCQTY%2', CustomQTY, GetLOCQTY);
            until xItemJour.Next() = 0;
        end else begin
            if Getitem.get(xItem."No.") then begin
                //Message('%1', xItemJour."Item No.");
                INT_EcomInterface_SNY.GetCustomInventory('', Getitem."No.", xItemJour."Unit of Measure Code", CustomQTY,
                inventorysetup.INT_LOCATION_MAIN, 100, true, UseCustomInventory);
                GetLOCQTY := GetLocInventory(inventorysetup.INT_LOCATION_MAIN, 100, true, Getitem."No.");

                if CustomQTY > GetLOCQTY then
                    AllcationItem(Getitem, CustomQTY)
                else
                    AllcationItem(Getitem, GetLOCQTY);
                //Message('CustomQTY %1 LOCQTY%2', CustomQTY, GetLOCQTY);
            end
        end;

    end;

    procedure GetLocInventory(
             LocationCode: code[20]; InventoryPercent: Decimal; IncludeOpenSO: Boolean;
             ItemNo: Code[20]) QTY: Decimal;
    var
        Location: Record Location;
        Item: Record Item;
        PendingQty: Decimal;
    begin
        Item.SetRange("No.", ItemNo);
        item.FindFirst();
        if (item.INT_PresaleCloseDate_SNY < Today()) and (item.INT_OrderType_SNY = item.INT_OrderType_SNY::Presale) then
            exit(0);
        Location.Reset();
        Location.SetRange(Code, LocationCode);
        if Location.FindSet() then
            repeat
                Item.SetFilter("Location Filter", Location.Code);
                Item.SetAutoCalcFields(Inventory, "Qty. on Sales Order");
                Item.FindFirst();
                if IncludeOpenSO then
                    Qty := QTY + ((Item.Inventory * InventoryPercent / 100) - Item."Qty. on Sales Order" + GetCanceledOrderQty(ItemNo, Location.Code))
                else
                    Qty := QTY + ((Item.Inventory * InventoryPercent / 100) + GetCanceledOrderQty(ItemNo, Location.Code));
            until Location.Next() = 0;

        PendingQty := GetPendingOrderQty(ItemNo, LocationCode);
        if (QTY + PendingQty) <= 0 then
            QTY := PendingQty
        else
            QTY := QTY + PendingQty;
        exit(QTY);
    end;

    procedure GetPendingOrderQty(ItemNo: Code[20]; LocationCode: code[20]): Decimal;
    var
        SalesLine: Record "Sales Line";
        Location: Record Location;
        Qty: Decimal;
    begin
        Qty := 0;
        Location.Reset();
        Location.SetRange(Code, LocationCode);
        if Location.FindSet() then
            repeat
                SalesLine.reset();
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                SalesLine.setrange(Type, SalesLine.Type::Item);
                SalesLine.SetRange("No.", ItemNo);
                SalesLine.SetRange("Location Code", Location.Code);
                SalesLine.SetRange(INT_MktOrdStatus_SNY, 'pending');
                if not SalesLine.IsEmpty() then
                    if SalesLine.FindSet() then
                        repeat
                            Qty += SalesLine."Outstanding Qty. (Base)";
                        until SalesLine.Next() = 0;
            until Location.Next() = 0;
        exit(Qty);
    end;

    local procedure GetCanceledOrderQty(ItemNo: Code[20]; LocationCode: Code[20]): Decimal;
    var
        SalesLine: Record "Sales Line";
        Location: Record Location;
        Qty: Decimal;
    begin
        Qty := 0;
        Location.Reset();
        Location.SetRange(Code, LocationCode);
        if (LocationCode <> '') then
            Location.SetRange(Code, LocationCode);
        if Location.FindSet() then
            repeat
                SalesLine.reset();
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                SalesLine.setrange(Type, SalesLine.Type::Item);
                SalesLine.SetRange("No.", ItemNo);
                SalesLine.SetRange("Location code", Location.Code);
                SalesLine.SetRange(INT_MktOrdStatus_SNY, 'canceled');
                if not SalesLine.IsEmpty() then
                    if SalesLine.FindSet() then
                        repeat
                            Qty += SalesLine."Outstanding Qty. (Base)";
                        until SalesLine.Next() = 0;
            until Location.Next() = 0;
        exit(Qty);
    end;

    procedure AllcationItem(xitem: Record item; xQTY: Decimal)
    var

        Marketplace: Record INT_MarketPlaces_SNY;
        itemmrkplace: Record INT_MktPlaceItem_SNY;
        allocalteQTY: array[10] of Decimal;
        totalQty: Decimal;
        Calitem: Record item;
        i: Integer;
        y: Integer;
    begin
        totalQty := xQTY;
        Calitem := xitem;
        //calculate allocation qty by marketplace
        Marketplace.reset;
        Marketplace.SetCurrentKey(INT_Priority_SNY);
        Marketplace.SetFilter(INT_Priority_SNY, '<>%1', 0);
        if Marketplace.Find('-') then begin
            repeat
                i += 1;
                allocalteQTY[i] := ROUND(xQTY * (Marketplace."INT_Allocation Percen_SNY" / 100), 1, '=');
            until Marketplace.Next() = 0;
            if ((allocalteQTY[1] + allocalteQTY[2] + allocalteQTY[3]) <> totalQty) then
                allocalteQTY[3] := totalQty - allocalteQTY[1] - allocalteQTY[2];
            //Message('%1 %2 %3 %4', totalQty, allocalteQTY[1], allocalteQTY[2], allocalteQTY[3]);
        end;
        //calculate allocation qty by marketplace

        // fill in item market place
        Marketplace.reset;
        Marketplace.SetCurrentKey(INT_Priority_SNY);
        Marketplace.SetFilter(INT_Priority_SNY, '<>%1', 0);
        if Marketplace.Find('-') then begin
            repeat
                y += 1;
                itemmrkplace.reset;
                itemmrkplace.SetRange("Item No.", Calitem."No.");
                itemmrkplace.SetRange(Marketplace, Marketplace.Marketplace);
                if itemmrkplace.Find('-') then begin
                    itemmrkplace.INT_Inventory_SNY := allocalteQTY[y];
                    itemmrkplace.Modify();
                    Commit();
                end;
            until (Marketplace.Next() = 0);
        end;
        // fill in item market place

    end;

    procedure GetItemMarketplace(ItemNO: code[20]; MarketPlace: code[20]): Decimal;
    var
        itemmarketplace: Record INT_MktPlaceItem_SNY;
    begin
        itemmarketplace.Reset;
        itemmarketplace.SetRange("Item No.", ItemNO);
        itemmarketplace.SetRange(Marketplace, MarketPlace);
        if itemmarketplace.Find('-') then
            exit(itemmarketplace.INT_Inventory_SNY)
        else
            exit(0);
    end;

    var
        myInt: Integer;


}