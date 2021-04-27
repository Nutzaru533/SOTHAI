codeunit 60010 "INT_ItemCopy2_SNY"
{
    TableNo = Item;
    trigger OnRun()
    var
        Item: Record item;
    begin
        Item.copy(Rec);
        //CopyMainModeDetails(Item);
        Rec := item;
    end;

    procedure CopyMainModeDetails(var CopyTo: Record Item)
    var

        CopyFrom: Record Item;
        CopyFromItemAttributes: Record "Item Attribute Value Mapping";
        CopyToItemAttributes: Record "Item Attribute Value Mapping";
        CopyFromItemMktCategoryMapping: Record INT_CategoryRelation_SNY;
        CopyToItemMktCategoryMapping: Record INT_CategoryRelation_SNY;
        ItemUnitOfMeasures: Record "Item Unit of Measure";
        Item: Record Item;
        CopyFromItemMedia: Record INT_ItemMediaURL_SNY;
        CopyToItemMedia: Record INT_ItemMediaURL_SNY;
    begin
        CopyFrom.get(CopyTo.INT_MainModel_SNY);
        if CopyFrom.INT_LongDesc_SNY.HasValue() then
            CopyFrom.CalcFields(INT_LongDesc_SNY);
        CopyTo.validate(Description, CopyFrom.Description);
        CopyTo.validate("Description 2", CopyFrom."Description 2");
        CopyTo."Base Unit of Measure" := CopyFrom."Base Unit of Measure";
        if CopyTo."Base Unit of Measure" <> '' then
            if not ItemUnitOfMeasures.get(CopyTo."No.", CopyTo."Base Unit of Measure") then begin
                ItemUnitOfMeasures.init();
                ItemUnitOfMeasures."Item No." := CopyTo."No.";
                ItemUnitOfMeasures.Code := CopyTo."Base Unit of Measure";
                ItemUnitOfMeasures."Qty. per Unit of Measure" := 1;
                ItemUnitOfMeasures.Insert();
            end;

        CopyTo.validatE("Item Category Code", CopyFrom."Item Category Code");
        CopyTo.Validate("Retail Product Code", CopyFrom."Retail Product Code");
        CopyTo.Validate(Type, CopyFrom.Type);
        CopyTo.INT_ItemType_SNY := CopyFrom.INT_ItemType_SNY;
        CopyTo.INT_KATABAN_SNY := CopyFrom.INT_KATABAN_SNY;
        CopyTo.INT_ProductCode_SNY := CopyFrom.INT_ProductCode_SNY;

        //CopyTo.INT_SellerSKU_SNY := CopyFrom.INT_SellerSKU_SNY;
        CopyTo.INT_SellerSKU_SNY := CopyTo."No.";
        CopyTo.INT_Name_SNY := CopyFrom.INT_Name_SNY;
        CopyTo.INT_ShortDesc_SNY := CopyFrom.INT_ShortDesc_SNY;
        CopyTo.INT_LongDesc_SNY := CopyFrom.INT_LongDesc_SNY;
        CopyTo.INT_PackageContent_SNY := CopyFrom.INT_PackageContent_SNY;
        CopyTo.INT_Brand_SNY := CopyFrom.INT_Brand_SNY;

        CopyTo.INT_SFYProductType := CopyFrom.INT_SFYProductType;
        CopyTo.INT_SFYSEOName_SNY := CopyFrom.INT_SFYSEOName_SNY;
        CopyTo.INT_SFYSEODesc_SNY := CopyFrom.INT_SFYSEODesc_SNY;
        CopyTo.INT_SFYLongDesc_SNY := CopyFrom.INT_SFYLongDesc_SNY;
        CopyTo.INT_SFYManualLongDesc_SNY := CopyFrom.INT_SFYManualLongDesc_SNY;

        CopyTo.INT_SFYVariant_SNY := CopyFrom.INT_SFYVariant_SNY;
        CopyTo.INT_GWT_Slug := CopyFrom.INT_GWT_Slug;
        CopyTo.INT_GWT_SuperMaster_Slug := CopyFrom.INT_GWT_SuperMaster_Slug;
        CopyTo.INT_GWT_Related_Products := CopyFrom.INT_GWT_Related_Products;

        CopyTo.INT_MaterialType_SNY := CopyFrom.INT_MaterialType_SNY;
        CopyTo.INT_ModelDesc1_SNY := CopyFrom.INT_ModelDesc1_SNY;
        CopyTo.INT_Biz4D_SNY := CopyFrom.INT_Biz4D_SNY;
        CopyTo.INT_Biz4DDesc_SNY := CopyFrom.INT_Biz4DDesc_SNY;
        CopyTo.INT_Code6D_SNY := CopyFrom.INT_Code6D_SNY;
        CopyTo.INT_Code6DDesc_SNY := CopyFrom.INT_Code6DDesc_SNY;
        CopyTo.INT_LocalHierarchy4Desc_SNY := CopyFrom.INT_LocalHierarchy4Desc_SNY;
        CopyTo.INT_LocalHierarchy5_SNY := CopyFrom.INT_LocalHierarchy5_SNY;
        CopyTo.INT_LocalHierarchy5Desc_SNY := CopyFrom.INT_LocalHierarchy5Desc_SNY;
        CopyTo.INT_EANPOSCode_SNY := CopyFrom.INT_EANPOSCode_SNY;
        CopyTo.INT_SrlNoInd_SNY := CopyFrom.INT_SrlNoInd_SNY;
        CopyTo.INT_CompanyCode_SNY := CopyFrom.INT_CompanyCode_SNY;

        CopyTo.validate("Gen. Prod. Posting Group", CopyFrom."Gen. Prod. Posting Group");
        CopyTo.validate("VAT Prod. Posting Group", CopyFrom."VAT Prod. Posting Group");
        CopyTo.validate("Inventory Posting Group", CopyFrom."Inventory Posting Group");

        CopyFromItemAttributes.Reset();
        CopyFromItemAttributes.SetRange("Table ID", Database::Item);
        CopyFromItemAttributes.SetRange("No.", CopyFrom."No.");
        if CopyFromItemAttributes.FindSet() then
            repeat
                if not CopyToItemAttributes.get(CopyFromItemAttributes."Table ID", CopyTo."No.", CopyFromItemAttributes."Item Attribute ID") then begin
                    CopyToItemAttributes := CopyFromItemAttributes;
                    CopyToItemAttributes."No." := CopyTo."No.";
                    CopyToItemAttributes.Insert(true);
                end;
            until CopyFromItemAttributes.Next() = 0;
        CopyFromItemMktCategoryMapping.Reset();
        CopyFromItemMktCategoryMapping.SetRange("Item No.", CopyFrom."No.");
        if CopyFromItemMktCategoryMapping.FindFirst() then
            repeat
                CopyToItemMktCategoryMapping := CopyFromItemMktCategoryMapping;
                if CopyToItemMktCategoryMapping.Insert(true) then;
            until CopyFromItemMktCategoryMapping.Next() = 0;

        CopyFromItemMedia.Reset();
        CopyFromItemMedia.SetRange("Item No.", CopyFrom."No.");
        if CopyFromItemMedia.FindFirst() then
            repeat
                CopyToItemMedia := CopyFromItemMedia;
                CopyToItemMedia."Item No." := CopyTo."No.";
                if CopyToItemMedia.Insert() then;
            until CopyFromItemMedia.Next() = 0
    end;
}