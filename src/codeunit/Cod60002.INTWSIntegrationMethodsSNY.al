codeunit 60002 "INT_WS_Integration Methods_SNY"
{
    trigger OnRun()
    begin
        Init();
        case FunctionName of
            'HANDLEITEMJNLINVENTORY':
                HandleItemJnlInventory();
            'UPLOADSALESPRICE':
                UploadSalesPrice();
            //'BCUPLOAD4DCODE':
            //BCUpload4DCode();
            //'BCUPLOAD6DCODE':
            //BCUpload6DCode();
            'LSUPLOAD4DCODE':
                LSUpload4DCode();
            'LSUPLOAD6DCODE':
                LSUpload6DCode();
            'UPDATEITEMATTRIBUTES':
                UpdateItemAttributes();
            'UPLOADITEM':
                UploadItem();
            'GETGWTFORREFERSH':
                GetGWTForRefresh();
            'UPDATEGWTINFO':
                HandleGWTUpdate();
            'GETSFYGWTFORREFERSH':
                GetSFYGWTForRefresh();
            'UPDATESFYGWTINFO':
                HandleSFYGWTUpdate();
            else
                Error(FunctionNameInvalidErr, FunctionName);
        end;
    end;

    var
        InterfaceSetup: Record INT_InterfaceSetup_SNY;
        ItemJnlLine: Record "Item Journal Line";
        TempItemJnlLine: Record "Item Journal Line" temporary;
        Item: Record Item;
        JsonMgmt: Codeunit "WS_JSON Mgmt._SNY";
        RootJsonObj: JsonObject;
        ResponsseJsonObj: JsonObject;
        DataJsonArr: JsonArray;
        GotInterfaceSetup: Boolean;
        FunctionName: Code[50];
        Status: Code[10];
        ResponseMsg: Text;
        FunctionNameInvalidErr: Label 'Function name ''%1'' is invalid.', Comment = '%1 = Function name.';
        FunctionNameJKeyLbl: Label 'function_name';
        StatusJKeyLbl: Label 'status';
        SellerSKULbl: Label 'seller_sku';
        GWTSellerSKULbl: Label 'gwtseller_sku';
        MainSellerSKULbl: Label 'main_sku';
        MainGWTSellerSKULbl: Label 'main_gwt_sku';
        DataJKeyLbl: Label 'data';
        ResponseMsgJKeyLbl: Label 'message';
        AttributeNameJkeyLbl: Label 'attribute_name';
        AttributeValueJkeyLbl: Label 'attribute_value';
        ItemNoJKeyLbl: Label 'item_no';
        VariantCodeJKeyLbl: Label 'variant_code';
        CurrencyCodeJKeyLbl: Label 'currency_code';
        ItemNameJKeyLbl: Label 'item_name';
        GWTModelSlugJKeyLbl: Label 'gwt_modelslug';
        GWTSuperModelSlugJKeyLbl: Label 'gwt_supermodeslug';
        GWTRelatedModelJKeyLbl: Label 'gwt_relatedmodel';
        GWTModelNameJKeyLbl: Label 'gwt_modelname';
        GWTModelBazaarVoiceIdJKeyLbl: Label 'gwt_modelbazarvoiceid';
        GWTVariantBazaarVoiceIdJKeyLbl: Label 'gwt_variantbazarvoiceid';
        ColorfamilyJKeyLbl: Label 'color_family';
        VariantArrayJKeyLbl: Label 'variants';
        //PackagCcontentJKeyLbl: Label 'package_content';
        ShortDescJKeyLbl: Label 'short_description';
        LongDescJKeyLbl: Label 'long_description';
        //ImageArrayJKeyLbl: Label 'images';
        UOMJKeyLbl: Label 'uom';
        LocationCodeJKeyLbl: Label 'location_code';
        QuantityJKeyLbl: Label 'quantity';
        SalesTypeJkeyLbl: Label 'sales_type';
        SalesCodeJkeyLbl: Label 'sales_code';
        DivisionCodeJKeyLbl: Label 'division_code';
        ItemCategoryCodeJKeyLbl: Label 'item_category_code';
        ItemCategoryDescJKeyLbl: Label 'item_category_desc';
        ProductGroupCodeJKeyLbl: Label 'product_group_code';
        ProductGroupDescJKeyLbl: Label 'product_group_desc';
        MinQuantityJkeyLbl: Label 'minimum_quantity';
        UnitPriceJkeyLbl: Label 'unit_price';
        StartingDateJkeyLbl: Label 'starting_date';
        EndingDateJkeyLbl: Label 'ending_date';
        ItemTypeJKeyLbl: Label 'item_type';
        //OrderTypeJKeyLbl: Label 'order_type';
        //PresaleLaunchDateJKeyLbl: Label 'presale_launchdate';
        //SellerSKUJKeyLbl: Label 'seller_sku';
        //PresaleCloseDateJKeyLbl: Label 'presale_closedate';
        ModelDescJKeyLbl: Label 'model_desc';
        SellerSKUJKeyLbl: Label 'seller_sku';
        MaterialTypeJKeyLbl: Label 'material_type';
        ModelDesc1JKeyLbl: Label 'model_desc1';
        Biz4DJKeyLbl: Label 'biz4d';
        Biz4DDescJKeyLbl: Label 'biz4d_desc';
        Code6DJKeyLbl: Label 'code6d';
        Code6DDescJKeyLbl: Label 'code6d_desc';
        LocalHierarchy4DescJKeyLbl: Label 'local_hierarchy_4desc';
        LocalHierarchy5JKeyLbl: Label 'local_hierarchy5';
        LocalHierarchy5DescJKeyLbl: Label 'local_hierarchy5_desc';
        EANPOSCodeJKeyLbl: Label 'eanpos_code';
        KATABANJKeyLbl: Label 'kataban';
        SrlNoIndJKeyLbl: Label 'srlnoind';
        CompanyCodeJKeyLbl: Label 'company_code';
        SafetyStockQtyJKeyLbl: Label 'safety_stock_qty';
        InventoryTypeJKeyLbl: Label 'inventory_type';
        GetItemAllcation: code[20];

    local procedure HandleItemJnlInventory()
    var
        inventorysetup: Record "Inventory Setup";
        inventoryallocation: Codeunit INT_Inventory_allocation_SNY;
    begin
        GetInterfaceSetup();
        HandleItemInfoInDataJsonArr();
        TempItemJnlLine.Reset();
        if not TempItemJnlLine.FindSet() then begin
            ResponseMsg := 'All inventory are upto date.';
            //SOTHAI Calculate Allocation stock
            inventorysetup.get;
            if inventorysetup.INT_Item_Allocation_SNY then begin
                inventoryallocation.GetDataToCalitemAllcation(GetItemAllcation, '');
            end;
            //SOTHAI Calculate Allocation stock
            exit;
        end;
        repeat
            ItemJnlLine := TempItemJnlLine;
            ItemJnlLine.Insert(true);
        until TempItemJnlLine.Next() = 0;
        Codeunit.Run(Codeunit::"Item Jnl.-Post Batch", ItemJnlLine);
        //SOTHAI Calculate Allocation stock
        inventorysetup.get;
        if inventorysetup.INT_Item_Allocation_SNY then begin
            inventoryallocation.GetDataToCalitemAllcation(GetItemAllcation, '');
        end;
        //SOTHAI Calculate Allocation stock
        ResponseMsg := 'The journal lines were successfully posted.';
    end;

    local procedure HandleItemInfoInDataJsonArr()
    var
        ItemUOM: Record "Item Unit of Measure";
        CurrJsonObj: JsonObject;
        NeedToAdjInventory: Boolean;
        ItemNo: Code[20];
        UOMCode: Code[10];
        LocationCode: Code[10];
        ItemJnlBatchName: Code[10];
        DataArrLen: Integer;
        i: Integer;
        LastLineNo: Integer;
        ActualQuantity: Decimal;
        AdjustmentQty: Decimal;
        CurrentInventory: Decimal;
        IsFirst: Boolean;
    begin
        DataArrLen := DataJsonArr.Count();
        ItemJnlBatchName := GetItemJnlBatchNameFromIntSetup();
        ItemJnlLine.SetRange("Journal Template Name", 'ITEM');
        ItemJnlLine.SetRange("Journal Batch Name", ItemJnlBatchName);
        LastLineNo := GetLastItemJnlLineNo();
        TempItemJnlLine."Journal Template Name" := 'ITEM';
        TempItemJnlLine."Journal Batch Name" := ItemJnlBatchName;
        IsFirst := true;
        for i := 0 to DataArrLen - 1 do begin
            CurrJsonObj := JsonMgmt.GetJsonObject(StrSubstNo('[%1]', i), DataJsonArr, false);
            ItemNo := CopyStr(JsonMgmt.GetCode(ItemNoJKeyLbl, CurrJsonObj, false), 1, 20);
            ActualQuantity := JsonMgmt.GetDecimal(QuantityJKeyLbl, CurrJsonObj, false);
            if not HasDuplicateTempItemJnlEntry(CurrJsonObj, ItemJnlBatchName) and (ActualQuantity >= 0) then begin
                Clear(NeedToAdjInventory);
                UOMCode := CopyStr(JsonMgmt.GetCode(UOMJKeyLbl, CurrJsonObj, false), 1, 10);
                if not ItemUOM.get(ItemNo, UOMCode) then Error('Invalid UOM :%1, Item No:%2', UOMCode, ItemNo);
                LocationCode := CopyStr(JsonMgmt.GetCode(LocationCodeJKeyLbl, CurrJsonObj, false), 1, 10);
                GetItem(ItemNo);
                Item.SetRange("Location Filter", LocationCode);
                Item.CalcFields(Inventory);
                CurrentInventory := Item.Inventory;
                //SOTHAI
                GetItemAllcation := Item."No.";
                //SOTHAI
                NeedToAdjInventory := CurrentInventory <> ActualQuantity;
                if (Item.Type <> Item.Type::Inventory) then NeedToAdjInventory := false;
                if NeedToAdjInventory then begin
                    AdjustmentQty := ActualQuantity - CurrentInventory;
                    LastLineNo += 10000;
                    TempItemJnlLine.Init();
                    ItemJnlLine.Validate("Item No.", '');
                    if not IsFirst then
                        TempItemJnlLine.TransferFields(ItemJnlLine)
                    else
                        TempItemJnlLine.SetUpNewLine(ItemJnlLine);
                    TempItemJnlLine."Line No." := LastLineNo;
                    TempItemJnlLine."Unit of Measure Code" := '';
                    TempItemJnlLine.Validate("Item No.", '');
                    if AdjustmentQty >= 0 then
                        TempItemJnlLine.Validate("Entry Type", TempItemJnlLine."Entry Type"::"Positive Adjmt.")
                    else
                        TempItemJnlLine.Validate("Entry Type", TempItemJnlLine."Entry Type"::"Negative Adjmt.");
                    TempItemJnlLine.Validate("Item No.", ItemNo);
                    TempItemJnlLine.Validate("Unit of Measure Code", UOMCode);
                    TempItemJnlLine.Validate("Location Code", LocationCode);
                    TempItemJnlLine.Validate(Quantity, Abs(AdjustmentQty));
                    TempItemJnlLine.Insert(true);
                    ItemJnlLine := TempItemJnlLine;
                    IsFirst := false;
                end;
            end;
        end;
    end;

    local procedure HasDuplicateTempItemJnlEntry(JsonObj: JsonObject;
    ItemJnlBatchName: Code[10]): Boolean
    var
        ItemNo: Code[20];
        LocationCode: Code[10];
    begin
        ItemNo := CopyStr(JsonMgmt.GetCode(ItemNoJKeyLbl, JsonObj, false), 1, 20);
        LocationCode := CopyStr(JsonMgmt.GetCode(LocationCodeJKeyLbl, JsonObj, false), 1, 10);
        TempItemJnlLine.Reset();
        TempItemJnlLine.SetRange("Journal Template Name", 'ITEM');
        TempItemJnlLine.SetRange("Journal Batch Name", ItemJnlBatchName);
        TempItemJnlLine.SetRange("Item No.", ItemNo);
        TempItemJnlLine.SetRange("Location Code", LocationCode);
        exit(not TempItemJnlLine.IsEmpty());
    end;

    Procedure UploadSalesPrice()
    Var
        SalesPrice2: Record "Sales Price";
        SalesPrice: Record "Sales Price";
        SalesPrice3: Record "Sales Price";
        CurrJsonObj: JsonObject;
        ItemNo: Code[20];
        VariantCode: code[10];
        CurrencyCode: code[10];
        UOMCode: Code[10];
        SalesCode: code[20];
        SalesType: Text[30];
        DataArrLen: Integer;
        i: Integer;
        MinQuantity: Decimal;
        UnitPrice: Decimal;
        StartingDate: Date;
        EndingDate: Date;
    begin
        DataArrLen := DataJsonArr.Count();
        //Insert New Sales Price if not exists or update price.
        for i := 0 to DataArrLen - 1 do begin
            CurrJsonObj := JsonMgmt.GetJsonObject(StrSubstNo('[%1]', i), DataJsonArr, false);
            UnitPrice := JsonMgmt.GetDecimal(UnitPriceJkeyLbl, CurrJsonObj, false);
            if unitprice < 0 then Error('Price cannot be less than zero');
            MinQuantity := JsonMgmt.GetDecimal(MinQuantityJkeyLbl, CurrJsonObj, false);
            if MinQuantity < 0 then Error('Quantity cannot be less than zero');
            SalesType := CopyStr(JsonMgmt.GetText(SalesTypeJkeyLbl, CurrJsonObj, false), 1, 30);
            SalesCode := CopyStr(JsonMgmt.GetCode(SalesCodeJkeyLbl, CurrJsonObj, false), 1, 20);
            ItemNo := CopyStr(JsonMgmt.GetCode(ItemNoJKeyLbl, CurrJsonObj, false), 1, 20);
            VariantCode := copystr(JsonMgmt.GetCode(VariantCodeJKeyLbl, CurrJsonObj, true), 1, 10);
            UOMCode := CopyStr(JsonMgmt.GetCode(UOMJKeyLbl, CurrJsonObj, false), 1, 10);
            StartingDate := JsonMgmt.GetDate(StartingDateJkeyLbl, CurrJsonObj, false);
            EndingDate := JsonMgmt.GetDate(EndingDateJkeyLbl, CurrJsonObj, false);
            CurrencyCode := copystr(JsonMgmt.GetCode(CurrencyCodeJKeyLbl, CurrJsonObj, true), 1, 10);
            JsonMgmt.ShowErrorIfBlank(ItemNoJKeyLbl, ItemNo);
            JsonMgmt.ShowErrorIfBlank(UOMJKeyLbl, ItemNo);
            JsonMgmt.ShowErrorIfBlank(UnitPriceJkeyLbl, UnitPrice);
            JsonMgmt.ShowErrorIfBlank(MinQuantityJkeyLbl, MinQuantity);
            JsonMgmt.ShowErrorIfBlank(StartingDateJkeyLbl, StartingDate);
            JsonMgmt.ShowErrorIfBlank(EndingDateJkeyLbl, EndingDate);
            SalesPrice2.RESET();
            SalesPrice2.SETRANGE("Ending Date", EndingDate);
            SalesPrice2.SETRANGE("Item No.", ItemNo);
            SalesPrice2.SETRANGE("Variant Code", VariantCode);
            SalesPrice2.SetRange("Currency Code", CurrencyCode);
            Case SalesType of
                'Customer Price Group':
                    SalesPrice2.SetRange("Sales Type", SalesPrice2."Sales Type"::"Customer Price Group");
                'Customer':
                    SalesPrice2.SetRange("Sales Type", SalesPrice2."Sales Type"::"Customer");
                'All Customers':
                    begin
                        SalesPrice2.Validate("Sales Type", SalesPrice2."Sales Type"::"All Customers"); //SOTH
                        SalesPrice2.SetRange("Sales Type", SalesPrice2."Sales Type"::"All Customers");
                    end;
                else
                    Error('Undefined Sales Type!');
            end;
            if SalesType <> 'All Customers' then //SOTH
                SalesPrice2.setrange("Sales Code", SalesCode);
            SalesPrice2.setrange("Unit of Measure Code", UOMCode);
            SalesPrice2.SetRange("Minimum Quantity", MinQuantity);
            SalesPrice2.SetRange("Starting Date", StartingDate);
            if SalesPrice2.IsEmpty() then begin
                SalesPrice2.Init();
                Case SalesType of
                    'Customer Price Group':
                        SalesPrice2.validate("Sales Type", SalesPrice2."Sales Type"::"Customer Price Group");
                    'Customer':
                        SalesPrice2.validate("Sales Type", SalesPrice2."Sales Type"::"Customer");
                    'All Customers':
                        begin
                            SalesPrice2.SetRange("Sales Type", SalesPrice2."Sales Type"::"All Customers");
                            SalesPrice2.Validate("Sales Type", SalesPrice2."Sales Type"::"All Customers"); //SOTH
                        end;
                    else
                        Error('Undefined Sales Type!');
                end;
                //if SalesPrice2."Sales Type" <> SalesPrice2."Sales Type"::"All Customers" then //SOTH
                if SalesType <> 'All Customers' then //SOTH
                    SalesPrice2.validate("Sales Code", SalesCode);
                SalesPrice2.validate("Item No.", ItemNo);
                if VariantCode <> '' then SalesPrice2.validate("Variant Code", VariantCode);
                SalesPrice2.Validate("Unit of Measure Code", UOMCode);
                if CurrencyCode <> '' then SalesPrice2.Validate("Currency Code", CurrencyCode);
                SalesPrice2.Validate("Minimum Quantity", MinQuantity);
                SalesPrice2.Validate("Starting Date", StartingDate);
                SalesPrice2.Validate("Unit Price", UnitPrice);
                SalesPrice2.Validate("Ending Date", EndingDate);
                SalesPrice2.insert(true);
            end
            else begin
                SalesPrice2.FindFirst();
                if SalesPrice2."Unit Price" <> UnitPrice then begin
                    SalesPrice2.Validate("Unit Price", UnitPrice);
                    SalesPrice2.Modify(true);
                end;
            end;
            SalesPrice.RESET();
            SalesPrice.SETRANGE("Item No.", SalesPrice2."Item No.");
            SalesPrice.SETRANGE("Sales Type", SalesPrice2."Sales Type");
            SalesPrice.SETRANGE("Sales Code", SalesPrice2."Sales Code");
            SalesPrice.SETFILTER("Starting Date", '<%1', SalesPrice2."Starting Date");
            SalesPrice.SETRANGE("Currency Code", SalesPrice2."Currency Code");
            SalesPrice.SETRANGE("Variant Code", SalesPrice2."Variant Code");
            SalesPrice.SETRANGE("Unit of Measure Code", SalesPrice2."Unit of Measure Code");
            SalesPrice.SETRANGE("Minimum Quantity", SalesPrice2."Minimum Quantity");
            IF SalesPrice.FINDFIRST() THEN
                repeat
                    SalesPrice3.RESET();
                    SalesPrice3.CopyFilters(SalesPrice);
                    SalesPrice3.SETFILTER("Starting Date", '>%1', SalesPrice."Starting Date");
                    SalesPrice3.SetRange("Ending Date");
                    IF SalesPrice3.FINDFIRST() THEN SalesPrice."Ending Date" := SalesPrice3."Starting Date" - 1;
                    SalesPrice.MODIFY();
                UNTIL SalesPrice.NEXT() = 0;
            //Update End date for previous records
            /*
                    SalesPrice2.RESET();
                    SalesPrice2.SETRANGE("Ending Date", 0D);
                    SalesPrice2.SETRANGE("Item No.", ItemNo);
                    Case SalesType of
                        'Customer Price Group':
                            SalesPrice2.SetRange("Sales Type", SalesPrice2."Sales Type"::"Customer Price Group");
                        'Customer':
                            SalesPrice2.SetRange("Sales Type", SalesPrice2."Sales Type"::"Customer");
                                        'All Customers':
                    SalesPrice2.SetRange("Sales Type", SalesPrice2."Sales Type"::"All Customers");
                        else
                            Error('Undefined Sales Type!');
                    end;
                    if SalesPrice2."Sales Type" <> SalesPrice2."Sales Type"::"All Customers" then //SOTH
                    SalesPrice2.setrange("Sales Code", SalesCode);
                    SalesPrice2.setrange("Unit of Measure Code", UOMCode);
                    SalesPrice2.SetRange("Minimum Quantity", MinQuantity);
                    //SalesPrice2.SetRange("Starting Date", StartingDate);
                    IF SalesPrice2.FINDSET() THEN
                        Repeat
                            SalesPrice.RESET();
                            SalesPrice.SETRANGE("Item No.", SalesPrice2."Item No.");
                            SalesPrice.SETRANGE("Sales Type", SalesPrice2."Sales Type");
                            SalesPrice.SETRANGE("Sales Code", SalesPrice2."Sales Code");
                            SalesPrice.SETFILTER("Starting Date", '>%1', SalesPrice2."Starting Date");
                            SalesPrice.SETRANGE("Currency Code", SalesPrice2."Currency Code");
                            SalesPrice.SETRANGE("Variant Code", SalesPrice2."Variant Code");
                            SalesPrice.SETRANGE("Unit of Measure Code", SalesPrice2."Unit of Measure Code");
                            SalesPrice.SETRANGE("Minimum Quantity", SalesPrice2."Minimum Quantity");
                            IF SalesPrice.FINDFIRST() THEN BEGIN
                                SalesPrice2."Ending Date" := SalesPrice."Starting Date" - 1;
                                SalesPrice2.MODIFY();
                                SalesPrice2."Ending Date" := 0D;
                            END;
                        UNTIL SalesPrice2.NEXT() = 0;
                        */
        end;
    end;

    Procedure UpdateItemAttributes()
    Var
        AttributeMaster: Record "Item Attribute";
        AttributeValueMaster: Record "Item Attribute Value";
        ItemAttributeMapping: Record "Item Attribute Value Mapping";
        CurrJsonObj: JsonObject;
        ItemNo: Code[20];
        AttributeName: Text[250];
        AttributeValue: Text[250];
        i: Integer;
        DataArrLen: Integer;
    begin
        DataArrLen := DataJsonArr.Count();
        for i := 0 to DataArrLen - 1 do begin
            CurrJsonObj := JsonMgmt.GetJsonObject(StrSubstNo('[%1]', i), DataJsonArr, false);
            ItemNo := CopyStr(JsonMgmt.GetCode(ItemNoJKeyLbl, CurrJsonObj, false), 1, 20);
            AttributeName := CopyStr(JsonMgmt.GetText(AttributeNameJkeyLbl, CurrJsonObj, false), 1, 250);
            AttributeValue := CopyStr(JsonMgmt.GetText(AttributeValueJkeyLbl, CurrJsonObj, false), 1, 250);
            JsonMgmt.ShowErrorIfBlank(ItemNoJKeyLbl, ItemNo);
            JsonMgmt.ShowErrorIfBlank(AttributeNameJkeyLbl, AttributeName);
            JsonMgmt.ShowErrorIfBlank(AttributeValueJkeyLbl, AttributeValue);
            if Item."No." <> ItemNo then Item.get(ItemNo);
            AttributeMaster.Reset();
            AttributeMaster.SetRange(Name, AttributeName);
            if AttributeMaster.IsEmpty() then Error('Attribute Name: %1 not exist in master!', AttributeName);
            AttributeMaster.FindFirst();
            //if (AttributeValueMaster.Value <> AttributeValue) or (AttributeMaster.Name <> AttributeName) then begin
            AttributeValueMaster.Reset();
            AttributeValueMaster.SetRange("Attribute ID", AttributeMaster.ID);
            AttributeValueMaster.SetRange(Value, AttributeValue);
            if AttributeValueMaster.IsEmpty() then Error('Attribute Name: %1, Attribute Value: %2 not exist in master!', AttributeMaster, AttributeValue);
            AttributeValueMaster.FindFirst();
            //end;
            if not ItemAttributeMapping.Get(Database::Item, ItemNo, AttributeMaster.ID) then begin
                ItemAttributeMapping.Init();
                ItemAttributeMapping."Table ID" := Database::Item;
                ItemAttributeMapping."No." := ItemNo;
                ItemAttributeMapping."Item Attribute ID" := AttributeMaster.ID;
                ItemAttributeMapping."Item Attribute Value ID" := AttributeValueMaster.ID;
                ItemAttributeMapping.Insert();
            end
            else begin
                ItemAttributeMapping."Item Attribute Value ID" := AttributeValueMaster.ID;
                ItemAttributeMapping.Modify();
            end;
        end;
    end;

    Procedure BCUpload4DCode()
    Var
        ItemCategory: Record "Item Category";
        CurrJsonObj: JsonObject;
        ItemCategoryCode: Code[10];
        Description: Text[100];
        i: Integer;
        DataArrLen: Integer;
    begin
        DataArrLen := DataJsonArr.Count();
        for i := 0 to DataArrLen - 1 do begin
            CurrJsonObj := JsonMgmt.GetJsonObject(StrSubstNo('[%1]', i), DataJsonArr, false);
            ItemCategoryCode := CopyStr(JsonMgmt.GetText(ItemCategoryCodeJKeyLbl, CurrJsonObj, false), 1, 10);
            Description := CopyStr(JsonMgmt.GetText(ItemCategoryDescJKeyLbl, CurrJsonObj, false), 1, 100);
            JsonMgmt.ShowErrorIfBlank(ItemCategoryCodeJKeyLbl, ItemCategoryCode);
            JsonMgmt.ShowErrorIfBlank(ItemCategoryDescJKeyLbl, Description);
            if not ItemCategory.get(ItemCategoryCode) then begin
                ItemCategory.init();
                ItemCategory.Code := ItemCategoryCode;
                ItemCategory.Description := Description;
                ItemCategory.Insert(true);
            end
            else begin
                ItemCategory.Description := Description;
                ItemCategory.Modify(true);
            end;
        end;
    end;

    Procedure BCUpload6DCode()
    Var
        ItemCategory: Record "Item Category";
        CurrJsonObj: JsonObject;
        ItemCategoryCode: Code[10];
        ProductGroupCode: code[10];
        Description: Text[100];
        i: Integer;
        DataArrLen: Integer;
    begin
        DataArrLen := DataJsonArr.Count();
        for i := 0 to DataArrLen - 1 do begin
            CurrJsonObj := JsonMgmt.GetJsonObject(StrSubstNo('[%1]', i), DataJsonArr, false);
            ItemCategoryCode := CopyStr(JsonMgmt.GetText(ItemCategoryCodeJKeyLbl, CurrJsonObj, false), 1, 10);
            ProductGroupCode := CopyStr(JsonMgmt.GetCode(ProductGroupCodeJKeyLbl, CurrJsonObj, false), 1, 10);
            Description := CopyStr(JsonMgmt.GetText(ProductGroupDescJKeyLbl, CurrJsonObj, false), 1, 100);
            JsonMgmt.ShowErrorIfBlank(ItemCategoryCodeJKeyLbl, ItemCategoryCode);
            JsonMgmt.ShowErrorIfBlank(ProductGroupCodeJKeyLbl, ProductGroupCode);
            JsonMgmt.ShowErrorIfBlank(ProductGroupCodeJKeyLbl, Description);
            if not ItemCategory.get(ProductGroupCode) then begin
                ItemCategory.init();
                ItemCategory.Validate(code, ProductGroupCode);
                ItemCategory.validate(Description, Description);
                ItemCategory.validate("Parent Category", ItemCategoryCode);
                ItemCategory.Insert(true);
            end
            else begin
                ItemCategory.validate(Description, Description);
                ItemCategory.validate("Parent Category", ItemCategoryCode);
                ItemCategory.Modify(true);
            end;
        end;
    end;

    Procedure LSUpload4DCode()
    Var
        ItemCategory: Record "Item Category";
        CurrJsonObj: JsonObject;
        ItemCategoryCode: Code[10];
        DivisionCode: code[10];
        Description: Text[100];
        i: Integer;
        DataArrLen: Integer;
    begin
        DataArrLen := DataJsonArr.Count();
        for i := 0 to DataArrLen - 1 do begin
            CurrJsonObj := JsonMgmt.GetJsonObject(StrSubstNo('[%1]', i), DataJsonArr, false);
            ItemCategoryCode := CopyStr(JsonMgmt.GetText(ItemCategoryCodeJKeyLbl, CurrJsonObj, false), 1, 10);
            Description := CopyStr(JsonMgmt.GetText(ItemCategoryDescJKeyLbl, CurrJsonObj, false), 1, 100);
            DivisionCode := CopyStr(JsonMgmt.GetCode(DivisionCodeJKeyLbl, CurrJsonObj, false), 1, 10);
            JsonMgmt.ShowErrorIfBlank(ItemCategoryCodeJKeyLbl, ItemCategoryCode);
            JsonMgmt.ShowErrorIfBlank(ItemCategoryDescJKeyLbl, Description);
            if not ItemCategory.get(ItemCategoryCode) then begin
                ItemCategory.init();
                ItemCategory.Code := ItemCategoryCode;
                ItemCategory.Description := Description;
                // ItemCategory."Division Code" := DivisionCode;
                ItemCategory.Insert(true);
            end
            else
                if ItemCategory.Description <> Description then begin
                    ItemCategory.Description := Description;
                    // ItemCategory.validate("Division Code", DivisionCode);
                    ItemCategory.Modify(true);
                end;
        end;
    end;

    Procedure UploadItem()
    Var
        Item2: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        UnitOfMeasure: Record "Unit of Measure";
        CurrJsonObj: JsonObject;
        UOM: code[10];
        i: Integer;
        DataArrLen: Integer;
        ItemNo: code[20];
    begin
        GetInterfaceSetup();
        InterfaceSetup.TestField("VAT. Prod. Posting Group");
        InterfaceSetup.TestField("Gen. Prod. Posting Group");
        InterfaceSetup.TestField("Inventory Posting Group");
        DataArrLen := DataJsonArr.Count();
        for i := 0 to DataArrLen - 1 do begin
            CurrJsonObj := JsonMgmt.GetJsonObject(StrSubstNo('[%1]', i), DataJsonArr, false);
            ItemNo := CopyStr(JsonMgmt.GetCode(ItemNoJKeyLbl, CurrJsonObj, false), 1, 20);
            if not Item.get(ItemNo) then begin
                item.Init();
                item."No." := ItemNo;
                item."Date Created" := Today;
                item.INT_OrderType_SNY := item.INT_OrderType_SNY::Normal;
                item."Created by User" := copystr(UserId, 1, 50);
                item.Insert(true);
            end;
            /*if CopyStr(JsonMgmt.GetText(ModelDescJKeyLbl, CurrJsonObj, false), 1, 100) <> item.Description then
                      Item.Validate(Description, CopyStr(JsonMgmt.GetText(ModelDescJKeyLbl, CurrJsonObj, false), 1, 100));

                  item.INT_ModelDesc_SNY := copystr(item.Description, 1, 50);            
                  item.TestField(INT_ModelDesc_SNY);
                  Item.Validate("INT_SellerSKU_SNY", item.Description);*/
            if CopyStr(JsonMgmt.GetText(ModelDescJKeyLbl, CurrJsonObj, false), 1, 100) <> item.Description then Item.Validate(Description, CopyStr(JsonMgmt.GetText(ModelDescJKeyLbl, CurrJsonObj, false), 1, 100));
            item.INT_ModelDesc_SNY := copystr(item.Description, 1, 50);
            item.TestField(INT_ModelDesc_SNY);
            if CopyStr(JsonMgmt.GetText(SellerSKUJKeyLbl, CurrJsonObj, false), 1, 100) <> item.Description then Item.Validate("INT_SellerSKU_SNY", CopyStr(JsonMgmt.GetText(SellerSKUJKeyLbl, CurrJsonObj, false), 1, 100));
            if item.INT_SellerSKU_SNY = '' then Item.Validate("INT_SellerSKU_SNY", item.Description);
            Item2.SetRange(INT_SellerSKU_SNY, item.INT_SellerSKU_SNY);
            Item2.SetFilter("No.", '<>%1', ItemNo);
            if not Item2.IsEmpty() then begin
                Item2.FindFirst();
                Error('Duplicate Item Find %1. Model Description: %2', Item2."No.", item.INT_ModelDesc_SNY);
            end;
            UOM := CopyStr(JsonMgmt.GetCode(UOMJKeyLbl, CurrJsonObj, false), 1, 10);
            if UOM <> item."Base Unit of Measure" then begin
                if UnitOfMeasure.Code <> UOM then UnitOfMeasure.get(UOM);
                if not ItemUOM.get(ItemNo, UOM) then begin
                    ItemUOM.Init();
                    ItemUOM."Item No." := ItemNo;
                    ItemUOM.Code := UOM;
                    ItemUOM."Qty. per Unit of Measure" := 1;
                    ItemUOM.Insert(true);
                end
                else
                    ItemUOM.TestField("Qty. per Unit of Measure", 1);
                item.Validate("Base Unit of Measure", CopyStr(JsonMgmt.GetCode(UOMJKeyLbl, CurrJsonObj, false), 1, 10));
            end;
            Item.Validate("INT_ModelDesc_SNY", CopyStr(JsonMgmt.GetText(ModelDescJKeyLbl, CurrJsonObj, false), 1, 50));
            case JsonMgmt.GetOption(ItemTypeJKeyLbl, CurrJsonObj, false) of
                0:
                    item.INT_ItemType_SNY := item.INT_ItemType_SNY::NPG;
                1:
                    item.INT_ItemType_SNY := item.INT_ItemType_SNY::PGS;
                2:
                    item.INT_ItemType_SNY := item.INT_ItemType_SNY::BUN;
                else
                    error('Invalid Item Type Item No. : %1. Accepted Values: 0 -> NPG, 1 -> PGS ,2 -> BUN', ItemNo);
            end;
            //Item.Validate("INT_ItemType_SNY", JsonMgmt.GetOption(ItemTypeJKeyLbl, CurrJsonObj, false));
            /*case JsonMgmt.GetOption(OrderTypeJKeyLbl, CurrJsonObj, false) of
                      0:
                          item.INT_OrderType_SNY := item.INT_OrderType_SNY::Normal;
                      1:
                          item.INT_OrderType_SNY := item.INT_OrderType_SNY::Presale;
                      else
                          error('Invalid Order Type - Item No. : %1. Accepted Values: 0 -> Normal, 1 -> Presales', ItemNo);
                  end;
                  if item.INT_OrderType_SNY = item.INT_OrderType_SNY::Presale then begin
                      Item.Validate("INT_PresaleLaunchDate_SNY", JsonMgmt.GetDate(PresaleLaunchDateJKeyLbl, CurrJsonObj, false));
                      Item.Validate("INT_PresaleCloseDate_SNY", JsonMgmt.GetDate(PresaleCloseDateJKeyLbl, CurrJsonObj, false));
                  end;
                  */
            Item.Validate("INT_MaterialType_SNY", CopyStr(JsonMgmt.GetCode(MaterialTypeJKeyLbl, CurrJsonObj, false), 1, 20));
            Item.Validate("INT_ModelDesc1_SNY", CopyStr(JsonMgmt.GetText(ModelDesc1JKeyLbl, CurrJsonObj, false), 1, 25));
            Item.Validate("INT_Biz4D_SNY", CopyStr(JsonMgmt.GetCode(Biz4DJKeyLbl, CurrJsonObj, false), 1, 4));
            Item.Validate("INT_Biz4DDesc_SNY", CopyStr(JsonMgmt.GetText(Biz4DDescJKeyLbl, CurrJsonObj, false), 1, 30));
            Item.Validate("INT_Code6D_SNY", CopyStr(JsonMgmt.GetCode(Code6DJKeyLbl, CurrJsonObj, false), 1, 6));
            Item.Validate("INT_Code6DDesc_SNY", CopyStr(JsonMgmt.GetText(Code6DDescJKeyLbl, CurrJsonObj, false), 1, 30));
            Item.Validate("INT_LocalHierarchy4Desc_SNY", CopyStr(JsonMgmt.GetText(LocalHierarchy4DescJKeyLbl, CurrJsonObj, false), 1, 40));
            Item.Validate("INT_LocalHierarchy5_SNY", CopyStr(JsonMgmt.GetCode(LocalHierarchy5JKeyLbl, CurrJsonObj, false), 1, 3));
            Item.Validate("INT_LocalHierarchy5Desc_SNY", CopyStr(JsonMgmt.GetText(LocalHierarchy5DescJKeyLbl, CurrJsonObj, false), 1, 40));
            Item.Validate("INT_EANPOSCode_SNY", CopyStr(JsonMgmt.GetCode(EANPOSCodeJKeyLbl, CurrJsonObj, false), 1, 13));
            Item.Validate("INT_KATABAN_SNY", CopyStr(JsonMgmt.GetCode(KATABANJKeyLbl, CurrJsonObj, false), 1, 11));
            item.Validate(INT_ProductCode_SNY, item.INT_KATABAN_SNY);
            Item.Validate(INT_SrlNoInd_SNY, JsonMgmt.GetBoolean(SrlNoIndJKeyLbl, CurrJsonObj, false));
            Item.Validate("INT_CompanyCode_SNY", CopyStr(JsonMgmt.GetText(CompanyCodeJKeyLbl, CurrJsonObj, false), 1, 10));
            if (item.INT_Biz4D_SNY <> '') and (item.INT_Biz4D_SNY <> item."Item Category Code") then item.Validate(item."Item Category Code", item.INT_Biz4D_SNY);
            if (item.INT_Code6D_SNY <> '') and (item.INT_Code6D_SNY <> item."Retail Product Code") then item.Validate("Retail Product Code", item.INT_Code6D_SNY);
            Item."Safety Stock Quantity" := JsonMgmt.GetDecimal(SafetyStockQtyJKeyLbl, CurrJsonObj, true);
            case JsonMgmt.GetOption(InventoryTypeJKeyLbl, CurrJsonObj, false) of
                0:
                    if Item.Type <> item.Type::Inventory then
                        item.validate(Type, Item.Type::Inventory);
                1:
                    if Item.Type <> item.Type::"Service" then
                        item.validate(Type, Item.Type::Service);
                2:
                    if Item.Type <> item.Type::"Non-Inventory" then
                        item.validate(Type, item.Type::"Non-Inventory");
                else
                    error('Invalid Inventory Type Item No.:%1 . Accepted Values: 0 -> Inventory, 1 -> Service ,2 -> Non Inventory', ItemNo);
            end;
            item.INT_SimpleItem_SNY := true;
            item."Reordering Policy" := item."Reordering Policy"::"Fixed Reorder Qty.";
            item.INT_RefreshGWTData_SNY := true;
            item.INT_RefreshSFYGWTData_SNY := true;
            if Item."Gen. Prod. Posting Group" = '' then item.Validate("Gen. Prod. Posting Group", InterfaceSetup."Gen. Prod. Posting Group");
            if item."VAT Prod. Posting Group" = '' then item.validate("VAT Prod. Posting Group", InterfaceSetup."VAT. Prod. Posting Group");
            if (item.Type = item.Type::Inventory) and (item."Inventory Posting Group" = '') then item.validate("Inventory Posting Group", InterfaceSetup."Inventory Posting Group");
            item."Last Date Modified" := Today;
            item."Last Modified by User" := copystr(UserId, 1, 50);
            item."Last DateTime Modified" := CurrentDateTime();
            item."Last Time Modified" := Time();
            item.Modify(true);
        end;
    end;

    Procedure LSUpload6DCode()
    Var
        RetailPrductGroup: Record "Retail Product Group";
        CurrJsonObj: JsonObject;
        ItemCategoryCode: Code[10];
        ProductGroupCode: code[10];
        Description: Text[100];
        i: Integer;
        DataArrLen: Integer;
    begin
        DataArrLen := DataJsonArr.Count();
        for i := 0 to DataArrLen - 1 do begin
            CurrJsonObj := JsonMgmt.GetJsonObject(StrSubstNo('[%1]', i), DataJsonArr, false);
            ItemCategoryCode := CopyStr(JsonMgmt.GetText(ItemCategoryCodeJKeyLbl, CurrJsonObj, false), 1, 10);
            ProductGroupCode := CopyStr(JsonMgmt.GetCode(ProductGroupCodeJKeyLbl, CurrJsonObj, false), 1, 10);
            Description := CopyStr(JsonMgmt.GetText(ProductGroupDescJKeyLbl, CurrJsonObj, false), 1, 100);
            JsonMgmt.ShowErrorIfBlank(ItemCategoryCodeJKeyLbl, ItemCategoryCode);
            JsonMgmt.ShowErrorIfBlank(ProductGroupCodeJKeyLbl, ProductGroupCode);
            JsonMgmt.ShowErrorIfBlank(ProductGroupCodeJKeyLbl, Description);
            if not RetailPrductGroup.get(ItemCategoryCode, ProductGroupCode) then begin
                RetailPrductGroup.init();
                RetailPrductGroup.Validate("Item Category Code", ItemCategoryCode);
                RetailPrductGroup.validate(Code, ProductGroupCode);
                RetailPrductGroup.validate(Description, Description);
                RetailPrductGroup.Insert(true);
            end
            else begin
                RetailPrductGroup.validate(Description, Description);
                RetailPrductGroup.Modify(true);
            end;
        end;
    end;

    procedure GetGWTForRefresh()
    var
        ItemQuery: Query WS_ItemGWTRefersh_SNY;
        ItemJsonObj: JsonObject;
        ItemJsonArr: JsonArray;
    begin
        ItemQuery.Open();
        while ItemQuery.Read() do begin
            clear(ItemJsonObj);
            ItemJsonObj.add(ItemNoJKeyLbl, ItemQuery.No_);
            ItemJsonObj.add(SellerSKULbl, ItemQuery.INT_SellerSKU_SNY);
            ItemJsonObj.add(GWTSellerSKULbl, ItemQuery.INT_GWTSellerSKU_SNY);
            ItemJsonArr.Add(ItemJsonObj);
        end;
        ResponsseJsonObj.Add(DataJKeyLbl, ItemJsonArr);
    end;

    procedure HandleGWTUpdate()
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        CurrJsonObj: JsonObject;
        ItemNo: code[20];
        DataArrLen: Integer;
        i: Integer;
        AttributeId: Integer;
        OutStr: OutStream;
        IsItemMdified: Boolean;
    begin
        ItemAttribute.Reset();
        ItemAttribute.SetRange(Name, 'color_family');
        if not ItemAttribute.FindFirst() then Error('Define Attribute Name as "color_family"');
        AttributeId := ItemAttribute.ID;
        DataArrLen := DataJsonArr.Count();
        for i := 0 to DataArrLen - 1 do begin
            CurrJsonObj := JsonMgmt.GetJsonObject(StrSubstNo('[%1]', i), DataJsonArr, false);
            ItemNo := CopyStr(JsonMgmt.GetCode(ItemNoJKeyLbl, CurrJsonObj, false), 1, 20);
            item.get(ItemNo);
            if JsonMgmt.HaveJsonToken(ColorfamilyJKeyLbl, CurrJsonObj) then begin
                ItemAttributeValue.Reset();
                ItemAttributeValue.Setrange("Attribute ID", AttributeId);
                ItemAttributeValue.SetRange(value, CopyStr(JsonMgmt.GetText(ColorfamilyJKeyLbl, CurrJsonObj, true), 1, 250));
                if not ItemAttributeValue.FindFirst() then Error('Define attribute value %1 in Color Attribute Values!', CopyStr(JsonMgmt.GetText(ColorfamilyJKeyLbl, CurrJsonObj, true), 1, 250));
                ItemAttributeValueMapping.Reset();
                ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
                ItemAttributeValueMapping.SetRange("No.", ItemNo);
                ItemAttributeValueMapping.SetRange("Item Attribute ID", AttributeId);
                if ItemAttributeValueMapping.IsEmpty() then begin
                    ItemAttributeValueMapping.Init();
                    ItemAttributeValueMapping."Table ID" := Database::Item;
                    ItemAttributeValueMapping."No." := ItemNo;
                    ItemAttributeValueMapping."Item Attribute ID" := AttributeId;
                    ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                    ItemAttributeValueMapping.Insert(true);
                end
                else begin
                    ItemAttributeValueMapping.FindFirst();
                    if ItemAttributeValueMapping."Item Attribute Value ID" <> ItemAttributeValue.ID then begin
                        ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                        ItemAttributeValueMapping.Modify(true);
                    end;
                end;
            end;
            if JsonMgmt.HaveJsonToken(ItemNameJKeyLbl, CurrJsonObj) then begin
                Item.INT_Name_SNY := CopyStr(JsonMgmt.GetText(ItemNameJKeyLbl, CurrJsonObj, true), 1, 250);
                IsItemMdified := true;
            end;
            //if JsonMgmt.HaveJsonToken(PackagCcontentJKeyLbl, CurrJsonObj) then begin
            //Item.INT_PackageContent_SNY := CopyStr(JsonMgmt.GetText(PackagCcontentJKeyLbl, CurrJsonObj, true), 1, 1000);
            if JsonMgmt.HaveJsonToken(ShortDescJKeyLbl, CurrJsonObj) then begin
                Item.INT_ShortDesc_SNY := CopyStr(JsonMgmt.GetText(ShortDescJKeyLbl, CurrJsonObj, true), 1, 2048);
                IsItemMdified := true;
            end;
            if JsonMgmt.HaveJsonToken(LongDescJKeyLbl, CurrJsonObj) then begin
                Item.INT_LongDesc_SNY.CreateOutStream(OutStr, TextEncoding::UTF8);
                OutStr.WriteText(JsonMgmt.GetText(LongDescJKeyLbl, CurrJsonObj, true));
                IsItemMdified := true;
            end;
            //end;
            if IsItemMdified then begin
                item.INT_RefreshGWTData_SNY := false;
                item.INT_RefreshGWTDtTime_SNY := CurrentDateTime;
                Item.Modify();
            end;
            IsItemMdified := false;
            /*
                  ItemImages.Reset();
                  ItemImages.SetRange("Item No.", ItemNo);
                  if ItemImages.FindLast() then
                      Seqid := ItemImages.Sequence + 1
                  else
                      Seqid := 1;

                  //HandleImage Array
                  if JsonMgmt.HaveJsonToken(ImageArrayJKeyLbl, CurrJsonObj) then begin
                      ImageDataArr := JsonMgmt.GetJsonArray(ImageArrayJKeyLbl, CurrJsonObj, true);
                      ImageDataArrLen := ImageDataArr.Count();
                      for j := 0 to ImageDataArrLen - 1 do begin

                          ImageDataArr.get(j, JsonToken);
                          ImageURL := CopyStr(JsonToken.AsValue().AsText(), 1, 250);
                          ItemImages.Reset();
                          ItemImages.SetRange("Item No.", ItemNo);
                          ItemImages.setrange("SONY URL", ImageURL);
                          if ItemImages.IsEmpty() then begin
                              ItemImages.Init();
                              ItemImages."Item No." := ItemNo;
                              ItemImages.Sequence := Seqid;
                              ItemImages."SONY URL" := ImageURL;
                              ItemImages.Insert();
                              Seqid += 1;
                          end;
                      end;
                  end;
                  */
            clear(OutStr);
        end;
    end;

    procedure GetSFYGWTForRefresh()
    var
        Item2: Record Item;
        ItemQuery: Query WS_ItemSFYGWTRefersh_SNY;
        ItemJsonObj: JsonObject;
        ItemJsonArr: JsonArray;
    begin
        ItemQuery.Open();
        while ItemQuery.Read() do begin
            clear(ItemJsonObj);
            ItemJsonObj.add(ItemNoJKeyLbl, ItemQuery.No_);
            ItemJsonObj.add(SellerSKULbl, ItemQuery.INT_SellerSKU_SNY);
            if (ItemQuery.INT_MainModel_SNY <> '') then begin
                Item2.SetRange(Item2."No.", ItemQuery.INT_MainModel_SNY);
                if Item2.FindFirst() then begin
                    ItemJsonObj.add(MainSellerSKULbl, Item2.INT_SellerSKU_SNY);
                    ItemJsonObj.add(MainGWTSellerSKULbl, Item2.INT_GWTSellerSKU_SNY);
                end;
            end;
            ItemJsonObj.add(GWTSellerSKULbl, ItemQuery.INT_GWTSellerSKU_SNY);
            ItemJsonArr.Add(ItemJsonObj);
        end;
        ResponsseJsonObj.Add(DataJKeyLbl, ItemJsonArr);
    end;

    procedure HandleSFYGWTUpdate()
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        ItemAttrValueSelection: Record "Item Attribute Value Selection" temporary;
        CurrJsonObj: JsonObject;
        ItemNo: code[20];
        DataArrLen: Integer;
        i: Integer;
        AttributeId: Integer;
        OutStr: OutStream;
        IsItemMdified: Boolean;
        VariantDataArr: JsonArray;
        VariantDataArrLen: Integer;
        j: Integer;
        VariantData: Text;
        VariantJsonToken: JsonToken;
        VariantOptionIndex: Integer;
        VariantName: Text;
        ShortVariantName: Text;
        VariantValue: Text;
        VariantText: Text;
    begin
        ItemAttribute.Reset();
        ItemAttribute.SetRange(Name, 'color_family');
        if not ItemAttribute.FindFirst() then Error('Define Attribute Name as "color_family"');
        AttributeId := ItemAttribute.ID;
        DataArrLen := DataJsonArr.Count();
        for i := 0 to DataArrLen - 1 do begin
            CurrJsonObj := JsonMgmt.GetJsonObject(StrSubstNo('[%1]', i), DataJsonArr, false);
            ItemNo := CopyStr(JsonMgmt.GetCode(ItemNoJKeyLbl, CurrJsonObj, false), 1, 20);
            item.get(ItemNo);
            //GWTModelSlugJKeyLbl
            //GWTSuperModelSlugJKeyLbl
            //GWTRelatedModelJKeyLbl
            if JsonMgmt.HaveJsonToken(GWTModelSlugJKeyLbl, CurrJsonObj) then begin
                Item.INT_GWT_Slug := CopyStr(JsonMgmt.GetText(GWTModelSlugJKeyLbl, CurrJsonObj, true), 1, 200);
                IsItemMdified := true;
            end;
            if JsonMgmt.HaveJsonToken(GWTSuperModelSlugJKeyLbl, CurrJsonObj) then begin
                Item.INT_GWT_SuperMaster_Slug := CopyStr(JsonMgmt.GetText(GWTSuperModelSlugJKeyLbl, CurrJsonObj, true), 1, 200);
                IsItemMdified := true;
            end;
            if JsonMgmt.HaveJsonToken(GWTRelatedModelJKeyLbl, CurrJsonObj) then begin
                Item.INT_GWT_Related_Products := CopyStr(JsonMgmt.GetText(GWTRelatedModelJKeyLbl, CurrJsonObj, true), 1, 200);
                IsItemMdified := true;
            end;
            if JsonMgmt.HaveJsonToken(GWTModelNameJKeyLbl, CurrJsonObj) then begin
                Item.INT_GWT_ModelName := CopyStr(JsonMgmt.GetText(GWTModelNameJKeyLbl, CurrJsonObj, true), 1, 30);
                IsItemMdified := true;
            end;
            if JsonMgmt.HaveJsonToken(GWTModelBazaarVoiceIdJKeyLbl, CurrJsonObj) then begin
                Item.INT_GWT_ModelBazaarVoiceId := CopyStr(JsonMgmt.GetText(GWTModelBazaarVoiceIdJKeyLbl, CurrJsonObj, true), 1, 30);
                IsItemMdified := true;
            end;
            if JsonMgmt.HaveJsonToken(GWTVariantBazaarVoiceIdJKeyLbl, CurrJsonObj) then begin
                Item.INT_GWT_VariantBazaarVoiceId := CopyStr(JsonMgmt.GetText(GWTVariantBazaarVoiceIdJKeyLbl, CurrJsonObj, true), 1, 30);
                IsItemMdified := true;
            end;
            if JsonMgmt.HaveJsonToken(ItemNameJKeyLbl, CurrJsonObj) then begin
                Item.INT_Name_SNY := CopyStr(JsonMgmt.GetText(ItemNameJKeyLbl, CurrJsonObj, true), 1, 250);
                if (Item.INT_SFYSEOName_SNY = '') then Item.INT_SFYSEOName_SNY := item.INT_Name_SNY;
                IsItemMdified := true;
            end;
            if JsonMgmt.HaveJsonToken(ShortDescJKeyLbl, CurrJsonObj) then begin
                Item.INT_SFYShortDesc_SNY := CopyStr(JsonMgmt.GetText(ShortDescJKeyLbl, CurrJsonObj, true), 1, 2048);
                IsItemMdified := true;
            end;
            if JsonMgmt.HaveJsonToken(LongDescJKeyLbl, CurrJsonObj) then begin
                Item.INT_SFYLongDesc_SNY.CreateOutStream(OutStr, TextEncoding::UTF8);
                OutStr.WriteText(JsonMgmt.GetText(LongDescJKeyLbl, CurrJsonObj, true));
                if (Item.INT_SFYSEODesc_SNY = '') then item.INT_SFYSEODesc_SNY := CopyStr(JsonMgmt.GetText(LongDescJKeyLbl, CurrJsonObj, true), 1, 320);
                IsItemMdified := true;
            end;
            if JsonMgmt.HaveJsonToken(ColorfamilyJKeyLbl, CurrJsonObj) then begin
                ItemAttributeValue.Reset();
                ItemAttributeValue.Setrange("Attribute ID", AttributeId);
                ItemAttributeValue.SetRange(value, CopyStr(JsonMgmt.GetText(ColorfamilyJKeyLbl, CurrJsonObj, true), 1, 250));
                if not ItemAttributeValue.FindFirst() then Error('Define attribute value %1 in Color Attribute Values!', CopyStr(JsonMgmt.GetText(ColorfamilyJKeyLbl, CurrJsonObj, true), 1, 250));
                ItemAttributeValueMapping.Reset();
                ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
                ItemAttributeValueMapping.SetRange("No.", ItemNo);
                ItemAttributeValueMapping.SetRange("Item Attribute ID", AttributeId);
                if ItemAttributeValueMapping.IsEmpty() then begin
                    ItemAttributeValueMapping.Init();
                    ItemAttributeValueMapping."Table ID" := Database::Item;
                    ItemAttributeValueMapping."No." := ItemNo;
                    ItemAttributeValueMapping."Item Attribute ID" := AttributeId;
                    ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                    ItemAttributeValueMapping.Insert(true);
                end
                else begin
                    ItemAttributeValueMapping.FindFirst();
                    if ItemAttributeValueMapping."Item Attribute Value ID" <> ItemAttributeValue.ID then begin
                        ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                        ItemAttributeValueMapping.Modify(true);
                    end;
                end;
            end;
            if JsonMgmt.HaveJsonToken(VariantArrayJKeyLbl, CurrJsonObj) then begin
                VariantDataArr := JsonMgmt.GetJsonArray(VariantArrayJKeyLbl, CurrJsonObj, true);
                VariantDataArrLen := VariantDataArr.Count();
                for j := 0 to VariantDataArrLen - 1 do begin
                    VariantDataArr.get(j, VariantJsonToken);
                    VariantData := CopyStr(VariantJsonToken.AsValue().AsText(), 1, 250);
                    VariantOptionIndex := VariantData.IndexOf(';');
                    VariantName := VariantData.Substring(1, VariantOptionIndex - 1);
                    VariantValue := VariantData.Substring(VariantOptionIndex + 1);
                    if (VariantText <> '') then VariantText := VariantText + ',';
                    VariantText := VariantText + VariantName + ';' + VariantValue;
                    if (VariantName = 'rootColorEquivalent') then
                        ShortVariantName := 'Colour'
                    else
                        if (VariantName = 'storageCapacity') then
                            ShortVariantName := 'Size'
                        else
                            if (VariantName = 'tvScreenSize') then
                                ShortVariantName := 'TV Screen Size'
                            else
                                if (VariantName = 'alphaKitVariations') then
                                    ShortVariantName := 'Body/ Bundle'
                                else
                                    ShortVariantName := VariantName;
                    ItemAttribute.Reset();
                    ItemAttribute.SetRange(Name, VariantName);
                    if ItemAttribute.FindFirst() then
                        if not ItemAttributeValueMapping.get(Database::Item, ItemNo, ItemAttribute.ID) then begin
                            ItemAttributeValueMapping.Init();
                            ItemAttributeValueMapping."Table ID" := Database::Item;
                            ItemAttributeValueMapping."No." := ItemNo;
                            ItemAttributeValueMapping."Item Attribute ID" := ItemAttribute.ID;
                            ItemAttributeValue.Init();
                            ItemAttributeValue."Attribute ID" := ItemAttributeValueMapping."Item Attribute ID";
                            ItemAttributeValue.Value := copystr(VariantValue, 1, 250);
                            ItemAttribute.Get(ItemAttribute."ID");
                            ItemAttrValueSelection.Init();
                            ItemAttrValueSelection."Attribute ID" := ItemAttributeValueMapping."Item Attribute ID";
                            ItemAttrValueSelection."Attribute Type" := ItemAttribute.Type;
                            ItemAttrValueSelection.Value := ItemAttributeValue.Value;
                            if not ItemAttrValueSelection.FindAttributeValue(ItemAttributeValue) then ItemAttrValueSelection.InsertItemAttributeValue(ItemAttributeValue, ItemAttrValueSelection);
                            ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                            ItemAttributeValueMapping.Insert(true);
                        end
                        else begin
                            ItemAttributeValue.Reset();
                            ItemAttributeValue.Setrange("Attribute ID", ItemAttribute.ID);
                            ItemAttributeValue.SetRange(value, CopyStr(VariantValue, 1, 250));
                            if not ItemAttributeValue.FindFirst() then begin
                                ItemAttributeValue.Init();
                                ItemAttributeValue."Attribute ID" := ItemAttributeValueMapping."Item Attribute ID";
                                ItemAttributeValue.Value := copystr(VariantValue, 1, 250);
                                ItemAttribute.Get(ItemAttribute."ID");
                                ItemAttrValueSelection.Init();
                                ItemAttrValueSelection."Attribute ID" := ItemAttributeValueMapping."Item Attribute ID";
                                ItemAttrValueSelection."Attribute Type" := ItemAttribute.Type;
                                ItemAttrValueSelection.Value := ItemAttributeValue.Value;
                                if not ItemAttrValueSelection.FindAttributeValue(ItemAttributeValue) then ItemAttrValueSelection.InsertItemAttributeValue(ItemAttributeValue, ItemAttrValueSelection);
                                ItemAttributeValueMapping.FindFirst();
                                if ItemAttributeValueMapping."Item Attribute Value ID" <> ItemAttributeValue.ID then begin
                                    ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                                    ItemAttributeValueMapping.Modify(true);
                                end;
                            end
                            else
                                if not ItemAttributeValueMapping.get(Database::Item, ItemNo, ItemAttributeValue."Attribute ID") then begin
                                    ItemAttributeValueMapping.Init();
                                    ItemAttributeValueMapping."Table ID" := Database::Item;
                                    ItemAttributeValueMapping."No." := ItemNo;
                                    ItemAttributeValueMapping."Item Attribute ID" := ItemAttribute.ID;
                                    ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                                    ItemAttributeValueMapping.Insert(true);
                                end
                                else
                                    if ItemAttributeValueMapping."Item Attribute Value ID" <> ItemAttributeValue.ID then begin
                                        ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                                        ItemAttributeValueMapping.Modify(true);
                                    end;
                        end;
                    if j <= 2 then begin
                        ItemAttribute.Reset();
                        ItemAttribute.SetRange(Name, StrSubstNo('Option %1 Name', j + 1));
                        if ItemAttribute.FindFirst() then
                            if not ItemAttributeValueMapping.get(Database::Item, ItemNo, ItemAttribute.ID) then begin
                                ItemAttributeValueMapping.Init();
                                ItemAttributeValueMapping."Table ID" := Database::Item;
                                ItemAttributeValueMapping."No." := ItemNo;
                                ItemAttributeValueMapping."Item Attribute ID" := ItemAttribute.ID;
                                ItemAttributeValue.Init();
                                ItemAttributeValue."Attribute ID" := ItemAttributeValueMapping."Item Attribute ID";
                                ItemAttributeValue.Value := copystr(ShortVariantName, 1, 250);
                                ItemAttribute.Get(ItemAttribute."ID");
                                ItemAttrValueSelection.Init();
                                ItemAttrValueSelection."Attribute ID" := ItemAttributeValueMapping."Item Attribute ID";
                                ItemAttrValueSelection."Attribute Type" := ItemAttribute.Type;
                                ItemAttrValueSelection.Value := ItemAttributeValue.Value;
                                if not ItemAttrValueSelection.FindAttributeValue(ItemAttributeValue) then ItemAttrValueSelection.InsertItemAttributeValue(ItemAttributeValue, ItemAttrValueSelection);
                                ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                                ItemAttributeValueMapping.Insert(true);
                            end
                            else begin
                                ItemAttributeValue.Reset();
                                ItemAttributeValue.Setrange("Attribute ID", ItemAttribute.ID);
                                ItemAttributeValue.SetRange(value, CopyStr(ShortVariantName, 1, 250));
                                if not ItemAttributeValue.FindFirst() then begin
                                    ItemAttributeValue.Init();
                                    ItemAttributeValue."Attribute ID" := ItemAttributeValueMapping."Item Attribute ID";
                                    ItemAttributeValue.Value := copystr(ShortVariantName, 1, 250);
                                    ItemAttrValueSelection.Init();
                                    ItemAttrValueSelection."Attribute ID" := ItemAttributeValueMapping."Item Attribute ID";
                                    ItemAttrValueSelection."Attribute Type" := ItemAttribute.Type;
                                    ItemAttrValueSelection.Value := ItemAttributeValue.Value;
                                    if not ItemAttrValueSelection.FindAttributeValue(ItemAttributeValue) then ItemAttrValueSelection.InsertItemAttributeValue(ItemAttributeValue, ItemAttrValueSelection);
                                    ItemAttributeValueMapping.FindFirst();
                                    if ItemAttributeValueMapping."Item Attribute Value ID" <> ItemAttributeValue.ID then begin
                                        ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                                        ItemAttributeValueMapping.Modify(true);
                                    end;
                                end
                                else
                                    if not ItemAttributeValueMapping.get(Database::Item, ItemNo, ItemAttributeValue."Attribute ID") then begin
                                        ItemAttributeValueMapping.Init();
                                        ItemAttributeValueMapping."Table ID" := Database::Item;
                                        ItemAttributeValueMapping."No." := ItemNo;
                                        ItemAttributeValueMapping."Item Attribute ID" := ItemAttribute.ID;
                                        ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                                        ItemAttributeValueMapping.Insert(true);
                                    end
                                    else
                                        if ItemAttributeValueMapping."Item Attribute Value ID" <> ItemAttributeValue.ID then begin
                                            ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                                            ItemAttributeValueMapping.Modify(true);
                                        end;
                            end;
                        ItemAttribute.Reset();
                        ItemAttribute.SetRange(Name, StrSubstNo('Option %1 Value', j + 1));
                        if ItemAttribute.FindFirst() then
                            if not ItemAttributeValueMapping.get(Database::Item, ItemNo, ItemAttribute.ID) then begin
                                ItemAttributeValueMapping.Init();
                                ItemAttributeValueMapping."Table ID" := Database::Item;
                                ItemAttributeValueMapping."No." := ItemNo;
                                ItemAttributeValueMapping."Item Attribute ID" := ItemAttribute.ID;
                                ItemAttributeValue.Init();
                                ItemAttributeValue."Attribute ID" := ItemAttributeValueMapping."Item Attribute ID";
                                ItemAttributeValue.Value := copystr(VariantName, 1, 250);
                                ItemAttrValueSelection.Init();
                                ItemAttrValueSelection."Attribute ID" := ItemAttributeValueMapping."Item Attribute ID";
                                ItemAttrValueSelection."Attribute Type" := ItemAttribute.Type;
                                ItemAttrValueSelection.Value := ItemAttributeValue.Value;
                                if not ItemAttrValueSelection.FindAttributeValue(ItemAttributeValue) then ItemAttrValueSelection.InsertItemAttributeValue(ItemAttributeValue, ItemAttrValueSelection);
                                ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                                ItemAttributeValueMapping.Insert(true);
                            end
                            else begin
                                ItemAttributeValue.Reset();
                                ItemAttributeValue.Setrange("Attribute ID", ItemAttribute.ID);
                                ItemAttributeValue.SetRange(value, CopyStr(VariantName, 1, 250));
                                if not ItemAttributeValue.FindFirst() then begin
                                    ItemAttributeValue.Init();
                                    ItemAttributeValue."Attribute ID" := ItemAttributeValueMapping."Item Attribute ID";
                                    ItemAttributeValue.Value := copystr(VariantName, 1, 250);
                                    ItemAttrValueSelection.Init();
                                    ItemAttrValueSelection."Attribute ID" := ItemAttributeValueMapping."Item Attribute ID";
                                    ItemAttrValueSelection."Attribute Type" := ItemAttribute.Type;
                                    ItemAttrValueSelection.Value := ItemAttributeValue.Value;
                                    if not ItemAttrValueSelection.FindAttributeValue(ItemAttributeValue) then ItemAttrValueSelection.InsertItemAttributeValue(ItemAttributeValue, ItemAttrValueSelection);
                                    ItemAttributeValueMapping.FindFirst();
                                    if ItemAttributeValueMapping."Item Attribute Value ID" <> ItemAttributeValue.ID then begin
                                        ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                                        ItemAttributeValueMapping.Modify(true);
                                    end;
                                end
                                else
                                    if not ItemAttributeValueMapping.get(Database::Item, ItemNo, ItemAttributeValue."Attribute ID") then begin
                                        ItemAttributeValueMapping.Init();
                                        ItemAttributeValueMapping."Table ID" := Database::Item;
                                        ItemAttributeValueMapping."No." := ItemNo;
                                        ItemAttributeValueMapping."Item Attribute ID" := ItemAttribute.ID;
                                        ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                                        ItemAttributeValueMapping.Insert(true);
                                    end
                                    else
                                        if ItemAttributeValueMapping."Item Attribute Value ID" <> ItemAttributeValue.ID then begin
                                            ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                                            ItemAttributeValueMapping.Modify(true);
                                        end;
                            end;
                    end;
                end;
            end;
            Item.INT_SFYVariant_SNY := CopyStr(VariantText, 1, 250);
            IsItemMdified := true;
        end;
        if IsItemMdified then begin
            item.INT_RefreshSFYGWTData_SNY := false;
            item.INT_RefreshSFYGWTDtTime_SNY := CurrentDateTime;
            Item.Modify();
        end;
        IsItemMdified := false;
        clear(OutStr);
    end;
    /*
      * ==========================================================================
      * COMMON FUNCTIONS
      * ==========================================================================
      */
    local procedure GetItem(ItemNo: Code[20])
    begin
        if ItemNo <> Item."No." then Item.Get(ItemNo);
    end;

    local procedure GetItemJnlBatchNameFromIntSetup(): Code[10]
    begin
        GetInterfaceSetup();
        exit(InterfaceSetup."Item Journal Batch");
    end;

    local procedure GetInterfaceSetup()
    begin
        if GotInterfaceSetup then exit;
        InterfaceSetup.Get();
        GotInterfaceSetup := true;
    end;

    local procedure GetLastItemJnlLineNo(): Integer
    begin
        if ItemJnlLine.FindLast() then
            exit(ItemJnlLine."Line No.")
        else
            exit(10000);
    end;
    /*
      * ==========================================================================
      * BASE FUNCTIONS
      * ==========================================================================
      */
    local procedure Init()
    begin
        FunctionName := CopyStr(JsonMgmt.GetCode(FunctionNameJKeyLbl, RootJsonObj, false), 1, 50);
        DataJsonArr := JsonMgmt.GetJsonArray(DataJKeyLbl, RootJsonObj, false);
        Status := 'OK';
    end;

    procedure Set(RequestJson: Text)
    begin
        RootJsonObj.ReadFrom(RequestJson);
    end;

    procedure WriteJSON(Success: Boolean) ResponseJson: Text;
    begin
        if not Success then begin
            Status := 'ERROR';
            ResponseMsg := GetLastErrorText();
        end;
        ResponsseJsonObj.Add(FunctionNameJKeyLbl, FunctionName);
        ResponsseJsonObj.Add(StatusJKeyLbl, Status);
        ResponsseJsonObj.Add(ResponseMsgJKeyLbl, ResponseMsg);
        ResponsseJsonObj.WriteTo(ResponseJson);
    end;
}
