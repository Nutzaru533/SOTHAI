xmlport 60003 "INT_ImportPromotion_SNY"
{
    caption = 'Import Package Bundel';
    Format = VariableText;
    Direction = Import;
    FieldSeparator = ',';
    TextEncoding = UTF8;
    UseRequestPage = false;
    schema
    {
        textelement(Root)
        {
            tableelement(FOCHEAD; Integer)
            {
                SourceTableView = sorting(number);
                UseTemporary = false;
                AutoSave = false;
                AutoReplace = false;

                textelement(gNo)
                {
                    MinOccurs = Zero;
                }
                textelement(gMarketplace)
                {
                    MinOccurs = Zero;
                }
                textelement(gItemNo)
                {
                }

                textelement(gPromotionType)
                {

                }
                textelement(gPeriodStart)
                { }
                textelement(gPeriodEnd)
                { }
                textelement(gDes)
                {
                }
                textelement(gLineItemNo)
                {
                }
                textelement(gQty)
                {
                }
                textelement(gPromotionalPrice)
                {
                }

                textelement(gInclude_FOC)
                {

                }
                textelement(gMain_Item_For_Delivery)
                {

                }
                trigger OnBeforeInsertRecord()
                var
                begin
                    EntryNo += 1;
                end;

                trigger OnAfterInsertRecord()
                var
                    marketplace: Record INT_MarketPlaces_SNY;
                begin
                    InterfaceSetup.get;

                    //"None",FOC,"FOC With Discount","Group Discount","Item Discount";
                    if (gPromotionType = 'Item Discount') or (gPromotionType = 'Group Discount') then
                        DocType := DocType::Package
                    else
                        if (gPromotionType = 'FOC') or (gPromotionType = 'FOC With Discount') then
                            DocType := DocType::FOC;


                    if gPromotionType = 'None' then
                        PromotionType := PromotionType::FOC
                    else
                        if gPromotionType = 'FOC' then
                            PromotionType := PromotionType::None
                        else
                            if gPromotionType = 'FOC With Discount' then
                                PromotionType := PromotionType::"FOC With Discount"
                            else
                                if gPromotionType = 'Group Discount' then
                                    PromotionType := PromotionType::"Group Discount"
                                else
                                    if gPromotionType = 'Item Discount' then
                                        PromotionType := PromotionType::"Item Discount";


                    if (gPromotionType = 'Item Discount') and (gMarketplace = 'Lazada') then
                        error('Item Discount apply only for Shopee and JD Please check your file.');

                    if (gPromotionType = 'Item Discount') then begin
                        marketplace.reset;
                        marketplace.SetRange(marketplace, gMarketplace);
                        if marketplace.Find('-') then begin
                            if marketplace."Have Item Discount" = false then
                                error('Item Discount not have in this marketplace');
                        end;
                    end;


                    if EntryNo > 1 then begin
                        gImpFOCHeader2.reset; //check document
                        gImpFOCHeader2.SetRange(Type, DocType);
                        gImpFOCHeader2.SetRange(INT_External_SYN, gNo);
                        if not gImpFOCHeader2.find('-') then begin
                            gImpFOCHeader.init;
                            gImpFOCHeader.Type := DocType;
                            if DocType = DocType::FOC then
                                gImpFOCHeader."No." := noserialMgn.GetNextNo(InterfaceSetup."Bundle No. Series", workdate, true);
                            if DocType = DocType::Package then
                                gImpFOCHeader."No." := noserialMgn.GetNextNo(InterfaceSetup."Bundle No. Series", workdate, true);
                            if OldNo <> gImpFOCHeader."No." then begin
                                //Delete Ext Doc
                                FOCExt.reset;
                                FOCExt.SetRange("No.", OldNo);
                                FOCExt.SetRange(Type, DocType);
                                if FOCExt.Find('-') then begin
                                    FOCExt.INT_External_SYN := '';
                                    FOCExt.Modify();
                                end;
                                //Delete Ext Doc
                            end;
                            gImpFOCHeader.INT_External_SYN := gNo;
                            //
                            OldNo := gImpFOCHeader."No.";
                            //
                            //gImpFOCHeader."Free Gift ID" := gNo;
                            gImpFOCHeader.Validate(Marketplace, gMarketplace);
                            marketplace.reset;
                            marketplace.SetRange(marketplace, gImpFOCHeader.Marketplace);
                            if marketplace.Find('-') then begin
                                gImpFOCHeader.Channel := marketplace.Channel;
                            end;
                            if gItemNo <> '' then
                                gImpFOCHeader.Validate("Item No.", gItemNo);
                            if gDes <> '' then
                                gImpFOCHeader.Description := gDes;

                            if not item.get(gItemNo) then
                                item.init;
                            gImpFOCHeader."Item Description" := item.Description;
                            if gPromotionType <> '' then
                                gImpFOCHeader."Promotion Type" := PromotionType;

                            if gPeriodStart <> '' then begin
                                gImpFOCHeader."Period Start" := ConvertTextToDateTime(gPeriodStart);
                                gImpFOCHeader."Starting Date" := ConvertTextToDate(gPeriodStart);
                            end;

                            if gPeriodEnd <> '' then begin
                                gImpFOCHeader."Period End" := ConvertTextToDateTime(gPeriodEnd);
                                gImpFOCHeader."Ending Date" := ConvertTextToDate(gPeriodEnd);
                            end;


                            if gImpFOCHeader.Insert() then begin
                                lineNo += 10000;
                                gImpFOCLine.init;
                                gImpFOCLine.type := DocType;
                                gImpFOCLine."No." := gImpFOCHeader."No.";
                                gImpFOCLine.INT_External_SYN := gImpFOCHeader.INT_External_SYN;
                                Evaluate(LineItemNo, gLineItemNo);
                                gImpFOCLine."Line No." := lineNo;
                                gImpFOCLine.Validate("Item No.", LineItemNo);
                                if not item.get(gItemNo) then
                                    item.init;
                                gImpFOCLine."Item Description" := item.Description;
                                gImpFOCLine.Validate(UOM, item."Base Unit of Measure");

                                if gQty <> '' then
                                    Evaluate(qty, gQty);
                                gImpFOCLine.Validate(Quantity, qty);

                                if gPromotionalPrice <> '' then begin
                                    Evaluate(promotionprice, gPromotionalPrice);
                                    gImpFOCLine."Promotional Price" := promotionprice;
                                    //gImpFOCLine."Storage Location" := gStorageLocation;
                                end;
                                gImpFOCLine."Free Gift ID" := gImpFOCHeader."Free Gift ID";

                                if (gInclude_FOC = 'Yes') or (gInclude_FOC = 'YES') then
                                    gImpFOCLine."Explode FOC Item" := true
                                else
                                    gImpFOCLine."Explode FOC Item" := false;

                                if (gMain_Item_For_Delivery = 'Yes') or (gMain_Item_For_Delivery = 'YES') then
                                    gImpFOCLine."Main Item for Delivery" := true
                                else
                                    gImpFOCLine."Main Item for Delivery" := false;

                                gImpFOCLine.Insert();
                                Commit();
                            end;
                        end
                        else begin
                            gImpFOCLine2.reset;
                            gImpFOCLine2.SetRange(INT_External_SYN, gNo);
                            gImpFOCLine2.SetRange(Type, DocType);
                            if gImpFOCLine2.Find('+') then begin
                                lineNo := gImpFOCLine2."Line No." + 10000;
                            end;
                            //start
                            gImpFOCLine.init;
                            gImpFOCLine.type := DocType;
                            gImpFOCLine."No." := gImpFOCLine2."No.";
                            gImpFOCLine.INT_External_SYN := gNo;
                            if gLineItemNo <> '' then
                                Evaluate(LineItemNo, gLineItemNo);
                            gImpFOCLine."Line No." := lineNo;
                            gImpFOCLine.Validate("Item No.", LineItemNo);
                            if not item.get(gItemNo) then
                                item.init;
                            gImpFOCLine."Item Description" := item.Description;
                            gImpFOCLine.Validate(UOM, item."Base Unit of Measure");
                            if gQty <> '' then
                                Evaluate(qty, gQty);
                            gImpFOCLine.Validate(Quantity, qty);

                            if gPromotionalPrice <> '' then begin
                                Evaluate(promotionprice, gPromotionalPrice);
                                gImpFOCLine."Promotional Price" := promotionprice;
                            end;
                            //gImpFOCLine."Storage Location" := gStorageLocation;
                            gImpFOCLine."Free Gift ID" := gImpFOCHeader."Free Gift ID";

                            if (gInclude_FOC = 'Yes') or (gInclude_FOC = 'YES') then
                                gImpFOCLine."Explode FOC Item" := true
                            else
                                gImpFOCLine."Explode FOC Item" := false;

                            if (gMain_Item_For_Delivery = 'Yes') or (gMain_Item_For_Delivery = 'YES') then
                                gImpFOCLine."Main Item for Delivery" := true
                            else
                                gImpFOCLine."Main Item for Delivery" := false;

                            gImpFOCLine.Insert();
                            //start
                        end;
                    end;
                end;
            }
        }
    }
    trigger OnPreXmlPort()
    begin
        /*
        gIsFirstRow := true;
        gImpSalLine.Reset();
        if gImpSalLine.FindLast() then
            gEntNo := gImpSalLine."Entry No." + 1
        else
            gEntNo := 1;
        gImpSalLine.SetRange("Imported By", UserId);
        gImpSalLine.DeleteAll(true);
        */
        EntryNo := 0;
    end;

    trigger OnPostXmlPort()
    var
        myInt: Integer;
    begin
        //Delete Ext Doc
        FOCExt.reset;
        FOCExt.SetRange("No.", OldNo);
        FOCExt.SetFilter(INT_External_SYN, '<>%1', '');
        if FOCExt.Find('-') then begin
            FOCExt.INT_External_SYN := '';
            FOCExt.Modify();
        end;
        //Delete Ext Doc
        Message('Import Completed');
    end;

    procedure ConvertTextToDate(Txt: text): Date
    var
        lday: Integer;
        lmonth: Integer;
        lyear: Integer;
    begin
        if Txt <> '' then begin
            //EVALUATE(lday, COPYSTR(Txt, 1, 2));
            //EVALUATE(lmonth, COPYSTR(Txt, 4, 2));
            EVALUATE(lmonth, COPYSTR(Txt, 1, 2));
            EVALUATE(lday, COPYSTR(Txt, 4, 2));
            EVALUATE(lyear, COPYSTR(Txt, 7, 4));
            exit(DMY2Date(lday, lmonth, lyear));
        end else
            exit(0D);

    end;

    procedure ConvertTextToDateTime(Txt: text): Datetime
    var
        lday: Integer;
        lmonth: Integer;
        lyear: Integer;
        Thetime: Time;
    begin
        if Txt <> '' then begin
            //EVALUATE(lday, COPYSTR(Txt, 1, 2));
            //EVALUATE(lmonth, COPYSTR(Txt, 4, 2));
            EVALUATE(lmonth, COPYSTR(Txt, 1, 2));
            EVALUATE(lday, COPYSTR(Txt, 4, 2));
            EVALUATE(lyear, COPYSTR(Txt, 7, 4));
            evaluate(TheTime, copystr(Txt, 11, 8));
            exit(createdatetime(DMY2DATE(lday, lmonth, lyear), TheTime));
        end else
            exit(0DT);

    end;

    var

        DocType: Option FOC,Package;
        PromotionType: Option "None",FOC,"FOC With Discount","Group Discount","Item Discount";
        gEntNo: Integer;
        EntryNo: Integer;
        gIsFirstRow: Boolean;
        gImpSalLine: Record INT_ImportSalesLine_SNY;
        gImpFOCHeader: Record INT_BundleHeader_SNY;
        SrpPrice: Decimal;
        PromotionPirce: Decimal;
        item: Record item;
        gImpFOCLine: Record INT_BundleLine_SNY;
        gImpFOCLine2: Record INT_BundleLine_SNY;
        gImpFOCHeader2: Record INT_BundleHeader_SNY;
        FOCExt: Record INT_BundleHeader_SNY;
        lineNo: Integer;
        qty: Decimal;
        promotionprice: Decimal;
        LineItemNo: code[20];
        noserialMgn: Codeunit NoSeriesManagement;
        InterfaceSetup: Record INT_InterfaceSetup_SNY;
        OldNo: Code[40];
}
