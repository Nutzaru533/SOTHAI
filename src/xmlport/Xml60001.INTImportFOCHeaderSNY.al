xmlport 60001 "INT_ImportFOCHeader_SNY"
{
    caption = 'Import FOC';
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

                textelement(gDes)
                {
                }

                textelement(gStartingDate)
                {
                }
                textelement(gEndingDate)
                {
                }
                textelement(gLineItemNo)
                {
                }
                textelement(gQty)
                {
                }
                textelement(gSRPPriece)
                {
                }
                textelement(gPromotionalPrice)
                {
                }

                textelement(gRelated_Item_Type)
                {
                }
                textelement(gStorageLocation)
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
                    if EntryNo > 1 then begin
                        gImpFOCHeader2.reset; //check document
                        gImpFOCHeader2.SetRange(INT_External_SYN, gNo);
                        if not gImpFOCHeader2.find('-') then begin
                            gImpFOCHeader.init;
                            gImpFOCHeader.Type := gImpFOCHeader.Type::FOC;
                            gImpFOCHeader."No." := noserialMgn.GetNextNo(InterfaceSetup."FOC No. Series", workdate, true);
                            gImpFOCHeader.INT_External_SYN := gNo;
                            gImpFOCHeader."Free Gift ID" := gNo;
                            gImpFOCHeader.Validate(Marketplace, gMarketplace);
                            marketplace.reset;
                            marketplace.SetRange(marketplace, gImpFOCHeader.Marketplace);
                            if marketplace.Find('-') then begin
                                gImpFOCHeader.Channel := marketplace.Channel;
                            end;
                            gImpFOCHeader.Description := gDes;
                            gImpFOCHeader.Validate("Item No.", gItemNo);
                            if not item.get(gItemNo) then
                                item.init;
                            gImpFOCHeader."Item Description" := item.Description;
                            gImpFOCHeader."Starting Date" := ConvertTextToDate(gStartingDate);
                            gImpFOCHeader."Ending Date" := ConvertTextToDate(gEndingDate);
                            if gImpFOCHeader.Insert() then begin
                                lineNo += 10000;
                                gImpFOCLine.init;
                                gImpFOCLine.type := gImpFOCLine.type::FOC;
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
                                if gSRPPriece <> '' then
                                    Evaluate(SrpPrice, gSRPPriece);
                                gImpFOCLine."SRP Price" := SrpPrice;
                                if gPromotionalPrice <> '' then
                                    Evaluate(promotionprice, gPromotionalPrice);
                                gImpFOCLine."Promotional Price" := promotionprice;
                                gImpFOCLine."Storage Location" := gStorageLocation;
                                gImpFOCLine."Free Gift ID" := gImpFOCHeader."Free Gift ID";
                                if gRelated_Item_Type = 'FOC' then
                                    gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::FOC
                                else
                                    if gRelated_Item_Type = 'FOC Dummy' then
                                        gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::"FOC Dummy"
                                    else
                                        if gRelated_Item_Type = 'Main' then
                                            gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::Main
                                        else
                                            if gRelated_Item_Type = 'Main Delivery' then
                                                gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::"Main Delivery"
                                            else
                                                if gRelated_Item_Type = 'Package' then
                                                    gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::Package
                                                else
                                                    if gRelated_Item_Type = 'Package Dummy' then
                                                        gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::"Package Dummy";

                                gImpFOCLine.Insert();
                                Commit();
                            end;
                        end
                        else begin
                            gImpFOCLine2.reset;
                            gImpFOCLine2.SetRange(INT_External_SYN, gNo);
                            gImpFOCLine2.SetRange(Type, gImpFOCLine2.Type::FOC);
                            if gImpFOCLine2.Find('+') then begin
                                lineNo := gImpFOCLine2."Line No." + 10000;
                            end;
                            //start
                            gImpFOCLine.init;
                            gImpFOCLine.type := gImpFOCLine.type::FOC;
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
                            if gSRPPriece <> '' then
                                Evaluate(SrpPrice, gSRPPriece);
                            gImpFOCLine."SRP Price" := SrpPrice;
                            if gPromotionalPrice <> '' then
                                Evaluate(promotionprice, gPromotionalPrice);
                            gImpFOCLine."Promotional Price" := promotionprice;
                            gImpFOCLine."Storage Location" := gStorageLocation;
                            gImpFOCLine."Free Gift ID" := gImpFOCHeader."Free Gift ID";
                            if gRelated_Item_Type = 'FOC' then
                                gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::FOC
                            else
                                if gRelated_Item_Type = 'FOC Dummy' then
                                    gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::"FOC Dummy"
                                else
                                    if gRelated_Item_Type = 'Main' then
                                        gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::Main
                                    else
                                        if gRelated_Item_Type = 'Main Delivery' then
                                            gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::"Main Delivery"
                                        else
                                            if gRelated_Item_Type = 'Package' then
                                                gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::Package
                                            else
                                                if gRelated_Item_Type = 'Package Dummy' then
                                                    gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::"Package Dummy";

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
        Message('FOC Import Header Completed');
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

    var
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
        lineNo: Integer;
        qty: Decimal;
        promotionprice: Decimal;
        LineItemNo: code[20];
        noserialMgn: Codeunit NoSeriesManagement;
        InterfaceSetup: Record INT_InterfaceSetup_SNY;
}
