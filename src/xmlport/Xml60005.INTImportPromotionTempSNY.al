xmlport 60005 "INT_ImportPromotionTemp_SNY"
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
                    if EntryNo > 1 then begin

                        INT_Temptableforimport.Init();
                        INT_Temptableforimport.entryno := EntryNo;
                        INT_Temptableforimport.gNo := gNo;
                        INT_Temptableforimport.Foc := false;
                        INT_Temptableforimport.gMarketplace := gMarketplace;

                        Promotioncode := gPromotionType;
                        INT_Temptableforimport.gPromotionType := Promotioncode;

                        addzaro := '';
                        if StrLen(gItemNo) < 8 then begin
                            for i := 1 to (8 - StrLen(gItemNo)) do begin
                                addzaro := addzaro + '0';
                            end;
                            gItemNo := addzaro + gItemNo;
                        end;
                        INT_Temptableforimport.gItemNo := gItemNo;
                        if (INT_Temptableforimport.gPromotionType = 'FOC') then begin
                            if not item.Get(INT_Temptableforimport.gItemNo) then begin
                                INT_Temptableforimport.error := true;
                                INT_Temptableforimport.ErrorDes := 'Item main does not exist';
                            end else
                                INT_Temptableforimport.gItemNo := gItemNo;
                        end;
                        //check item
                        INT_Temptableforimport.gItemNo := gItemNo;
                        INT_Temptableforimport.gPromotionType := gPromotionType;
                        INT_Temptableforimport.gPromotionalPrice := gPromotionalPrice;
                        INT_Temptableforimport.gPeriodStart := gPeriodStart;
                        INT_Temptableforimport.gPeriodEnd := gPeriodEnd;
                        INT_Temptableforimport.gDes := gDes;
                        addzaro := '';
                        if StrLen(gLineItemNo) < 8 then begin
                            for i := 1 to (8 - StrLen(gLineItemNo)) do begin
                                addzaro := addzaro + '0';
                            end;
                            gLineItemNo := addzaro + gLineItemNo;
                        end;
                        INT_Temptableforimport.gLineItemNo := gLineItemNo;
                        if not item.Get(INT_Temptableforimport.gLineItemNo) then begin
                            INT_Temptableforimport.error := true;
                            INT_Temptableforimport.ErrorDes := 'Item does not exist';
                        end else
                            INT_Temptableforimport.gLineItemNo := gLineItemNo;
                        //check item
                        INT_Temptableforimport.gLineItemNo := gLineItemNo;
                        INT_Temptableforimport.gQty := gQty;


                        if (gQty = '') or (gQty = '0') then begin
                            INT_Temptableforimport.error := true;
                            INT_Temptableforimport.ErrorDes := 'Quantity must have value.';
                        end;

                        if StrPos(gQty, '.') > 0 then begin
                            INT_Temptableforimport.error := true;
                            INT_Temptableforimport.ErrorDes := 'Quantity must be integer not Decimal.';
                        end;
                        if gQty <> '' then begin
                            Evaluate(qty, gQty);
                            if qty < 0 then begin
                                INT_Temptableforimport.error := true;
                                INT_Temptableforimport.ErrorDes := 'Quantity must not be Negative.';
                            end;
                        end;
                        if gPeriodStart <> '' then begin
                            pstart := ConvertTextToDateTime(gPeriodStart);
                            startdate := ConvertTextToDate(gPeriodStart);
                        end;

                        if gPeriodEnd <> '' then begin
                            pend := ConvertTextToDateTime(gPeriodEnd);
                            enddate := ConvertTextToDate(gPeriodEnd);
                        end;

                        if enddate < today then begin
                            INT_Temptableforimport.error := true;
                            INT_Temptableforimport.ErrorDes := 'Please check range Date !!';
                        end;

                        if startdate > enddate then begin
                            INT_Temptableforimport.error := true;
                            INT_Temptableforimport.ErrorDes := 'Period start date should be less than Period End date';
                        end;

                        Promotioncode := gPromotionType;
                        INT_Temptableforimport.gPromotionType := Promotioncode;
                        INT_Temptableforimport.gInclude_FOC := gInclude_FOC;
                        INT_Temptableforimport.gMain_Item_For_Delivery := gMain_Item_For_Delivery;
                        if (INT_Temptableforimport.gPromotionType = 'ITEM DISCOUNT') or (INT_Temptableforimport.gPromotionType = 'GROUP DISCOUNT') or (INT_Temptableforimport.gPromotionType = 'NONE') then begin
                            INT_Temptableforimport.Type := format(DocType::Package);
                            if (INT_Temptableforimport.gPromotionalPrice = '0') or (INT_Temptableforimport.gPromotionalPrice = '') then begin
                                INT_Temptableforimport.error := true;
                                INT_Temptableforimport.ErrorDes := 'Promotion price must be have value';
                            end;
                        end;
                        if (INT_Temptableforimport.gPromotionType = 'FOC') or (INT_Temptableforimport.gPromotionType = 'FOC WHIT DISCOUNT') then
                            INT_Temptableforimport.Type := format(DocType::FOC);

                        if INT_Temptableforimport.gPromotionType = 'NONE' then
                            INT_Temptableforimport.gPromotionType2 := INT_Temptableforimport.gPromotionType2::NONE
                        else
                            if INT_Temptableforimport.gPromotionType = 'FOC' then
                                INT_Temptableforimport.gPromotionType2 := INT_Temptableforimport.gPromotionType2::FOC
                            else
                                if INT_Temptableforimport.gPromotionType = 'FOC WHIT DISCOUNT' then
                                    INT_Temptableforimport.gPromotionType2 := INT_Temptableforimport.gPromotionType2::"FOC WITH DISCOUNT"
                                else
                                    if INT_Temptableforimport.gPromotionType = 'GROUP DISCOUNT' then
                                        INT_Temptableforimport.gPromotionType2 := INT_Temptableforimport.gPromotionType2::"GROUP DISCOUNT"
                                    else
                                        if INT_Temptableforimport.gPromotionType = 'ITEM DISCOUNT' then
                                            INT_Temptableforimport.gPromotionType2 := INT_Temptableforimport.gPromotionType2::"ITEM DISCOUNT"
                                        else begin
                                            INT_Temptableforimport.error := true;
                                            INT_Temptableforimport.ErrorDes := 'Promotion type not have in system ';
                                        end;

                        if (INT_Temptableforimport.gPromotionType = 'ITEM DISCOUNT') then begin
                            marketplace.reset;
                            marketplace.SetRange(marketplace, INT_Temptableforimport.gMarketplace);
                            if marketplace.Find('-') then begin
                                if marketplace."Have Item Discount" = false then begin
                                    INT_Temptableforimport.error := true;
                                    INT_Temptableforimport.ErrorDes := 'Item Discount not have in this marketplace';
                                end;
                            end;
                        end;
                        INT_Temptableforimport.insert;
                    end;
                end;
            }
        }
    }
    trigger OnPreXmlPort()
    begin
        INT_Temptableforimport.DeleteAll();
        EntryNo := 0;
    end;

    trigger OnPostXmlPort()
    var
        myInt: Integer;
    begin
        gsortno := 1;
        INT_Temptableforimport2.reset;
        INT_Temptableforimport2.SetCurrentKey(gNo);
        INT_Temptableforimport2.SetRange(foc, false);
        INT_Temptableforimport2.SetFilter(gNo, '<>%1', '');
        if INT_Temptableforimport2.Find('-') then begin
            repeat
                if OldNo <> INT_Temptableforimport2.gNo then begin
                    olditem := '';
                    oldMarketplace := '';
                    INT_Temptableforimport3.reset;
                    INT_Temptableforimport3.SetRange(gNo, INT_Temptableforimport2.gNo);
                    if INT_Temptableforimport3.Find('-') then
                        repeat
                            INT_Temptableforimport4.reset;
                            INT_Temptableforimport4.SetRange(gNo, INT_Temptableforimport3.gNo);
                            INT_Temptableforimport4.SetRange(error, true);
                            if INT_Temptableforimport4.Find('-') then begin
                                //texterror := INT_Temptableforimport4.ErrorDes;
                                INT_Temptableforimport5.reset;
                                //INT_Temptableforimport5.SetRange(gNo, INT_Temptableforimport4.gNo);
                                INT_Temptableforimport2.SetRange(foc, false);
                                if INT_Temptableforimport5.Find('-') then begin
                                    //INT_Temptableforimport5.ModifyAll(ErrorDes, texterror);
                                    INT_Temptableforimport5.ModifyAll(error, true);
                                    Commit();
                                end;

                            end;
                            if oldMarketplace <> '' then
                                if oldMarketplace <> INT_Temptableforimport3.gMarketplace then begin
                                    INT_Temptableforimport4.reset;
                                    INT_Temptableforimport4.SetRange(gNo, INT_Temptableforimport3.gNo);
                                    if INT_Temptableforimport4.Find('-') then begin
                                        INT_Temptableforimport4.ModifyAll(error, true);
                                        INT_Temptableforimport4.ModifyAll(ErrorDes, 'Marketplace should be Same');
                                        Commit();
                                    end;
                                end;
                            if olditem <> '' then
                                if olditem <> INT_Temptableforimport3.gItemNo then begin
                                    INT_Temptableforimport4.reset;
                                    INT_Temptableforimport4.SetRange(gNo, INT_Temptableforimport3.gNo);
                                    if INT_Temptableforimport4.Find('-') then begin
                                        INT_Temptableforimport4.ModifyAll(error, true);
                                        INT_Temptableforimport4.ModifyAll(ErrorDes, 'Item No On header should be Same');
                                        Commit();
                                    end;
                                end;
                            olditem := INT_Temptableforimport3.gItemNo;
                            oldMarketplace := INT_Temptableforimport3.gMarketplace;
                            INT_Temptableforimport8.reset;
                            INT_Temptableforimport8.SetRange(entryno, INT_Temptableforimport3.entryno);
                            if INT_Temptableforimport8.Find('-') then begin
                                gsortno += 1;
                                INT_Temptableforimport8.SortNo := gsortno;
                                INT_Temptableforimport8.Modify();
                                Commit();
                            end;
                        until INT_Temptableforimport3.Next() = 0;
                end;
                OldNo := INT_Temptableforimport2.gNo;
            until INT_Temptableforimport2.Next() = 0;
        end;


        //insert data.
        OldNo := '';
        INT_Temptableforimport2.reset;
        INT_Temptableforimport2.SetCurrentKey(gNo);
        INT_Temptableforimport2.SetRange(error, false);
        INT_Temptableforimport2.SetRange(foc, false);
        INT_Temptableforimport2.SetFilter(gNo, '<>%1', '');
        if INT_Temptableforimport2.Find('-') then begin
            repeat
                if OldNo <> INT_Temptableforimport2.gNo then begin
                    INT_Temptableforimport3.reset;
                    INT_Temptableforimport3.SetRange(gNo, INT_Temptableforimport2.gNo);
                    if INT_Temptableforimport3.Find('-') then
                        repeat

                            if (INT_Temptableforimport3.gPromotionType = 'ITEM DISCOUNT') or (INT_Temptableforimport3.gPromotionType = 'GROUP DISCOUNT') or (INT_Temptableforimport3.gPromotionType = 'NONE') then
                                DocType := DocType::Package
                            else
                                if (INT_Temptableforimport3.gPromotionType = 'FOC') or (INT_Temptableforimport3.gPromotionType = 'FOC WHIT DISCOUNT') then
                                    DocType := DocType::FOC;

                            gImpFOCHeader2.reset; //check document
                            gImpFOCHeader2.SetRange(Type, DocType);
                            gImpFOCHeader2.SetRange(INT_External_SYN, INT_Temptableforimport3.gNo);
                            if not gImpFOCHeader2.find('-') then begin
                                InterfaceSetup.get;
                                gImpFOCHeader.init;
                                gImpFOCHeader.Type := DocType;
                                if DocType = DocType::FOC then
                                    gImpFOCHeader."No." := noserialMgn.GetNextNo(InterfaceSetup."Bundle No. Series", workdate, true);
                                if DocType = DocType::Package then
                                    gImpFOCHeader."No." := noserialMgn.GetNextNo(InterfaceSetup."Bundle No. Series", workdate, true);
                                gImpFOCHeader.INT_External_SYN := INT_Temptableforimport3.gNo;
                                gImpFOCHeader.Validate(Marketplace, INT_Temptableforimport3.gMarketplace);
                                marketplace.reset;
                                marketplace.SetRange(marketplace, gImpFOCHeader.Marketplace);
                                if marketplace.Find('-') then begin
                                    gImpFOCHeader.Channel := marketplace.Channel;
                                end;
                                if INT_Temptableforimport3.gPromotionType = 'FOC' then
                                    if INT_Temptableforimport3.gItemNo <> '' then
                                        gImpFOCHeader.Validate("Item No.", INT_Temptableforimport3.gItemNo);
                                if INT_Temptableforimport3.gDes <> '' then
                                    gImpFOCHeader.Description := gDes;

                                if not item.get(INT_Temptableforimport3.gItemNo) then
                                    item.init;
                                gImpFOCHeader."Item Description" := item.Description;
                                gImpFOCHeader."Promotion Type" := INT_Temptableforimport3.gPromotionType2;

                                if INT_Temptableforimport3.gPeriodStart <> '' then begin
                                    gImpFOCHeader."Period Start" := ConvertTextToDateTime(INT_Temptableforimport3.gPeriodStart);
                                    gImpFOCHeader."Starting Date" := ConvertTextToDate(INT_Temptableforimport3.gPeriodStart);
                                end;

                                if INT_Temptableforimport3.gPeriodEnd <> '' then begin
                                    gImpFOCHeader."Period End" := ConvertTextToDateTime(INT_Temptableforimport3.gPeriodEnd);
                                    gImpFOCHeader."Ending Date" := ConvertTextToDate(INT_Temptableforimport3.gPeriodEnd);
                                end;

                                gImpFOCHeader.Status := gImpFOCHeader.Status::"Config WIP";
                                if gImpFOCHeader.Insert() then begin
                                    lineNo += 10000;
                                    gImpFOCLine.init;
                                    gImpFOCLine.type := DocType;
                                    gImpFOCLine."No." := gImpFOCHeader."No.";
                                    gImpFOCLine.INT_External_SYN := gImpFOCHeader.INT_External_SYN;
                                    Evaluate(LineItemNo, INT_Temptableforimport3.gLineItemNo);
                                    gImpFOCLine."Line No." := lineNo;
                                    gImpFOCLine.Validate("Item No.", LineItemNo);
                                    if not item.get(INT_Temptableforimport3.gItemNo) then
                                        item.init;
                                    gImpFOCLine."Item Description" := item.Description;
                                    //gImpFOCLine.Validate(UOM, item."Base Unit of Measure");
                                    Evaluate(qty, INT_Temptableforimport3.gQty);
                                    gImpFOCLine.Validate(Quantity, qty);

                                    if INT_Temptableforimport3.gPromotionalPrice <> '' then begin
                                        Evaluate(promotionprice, INT_Temptableforimport3.gPromotionalPrice);
                                        gImpFOCLine."Promotional Price" := promotionprice;
                                        //gImpFOCLine."Storage Location" := gStorageLocation;
                                    end;
                                    if gImpFOCLine."SRP Price" < gImpFOCLine."Promotional Price" then begin
                                        INT_Temptableforimport3.gSRPPriece := format(gImpFOCLine."SRP Price");
                                        INT_Temptableforimport3.error := true;
                                        INT_Temptableforimport3.ErrorDes := 'Promo price should be less than SRP price';
                                    end;

                                    gImpFOCLine."Free Gift ID" := gImpFOCHeader."Free Gift ID";

                                    if (INT_Temptableforimport3.gInclude_FOC = 'Yes') or (INT_Temptableforimport3.gInclude_FOC = 'YES') then
                                        gImpFOCLine."Explode FOC Item" := true
                                    else
                                        gImpFOCLine."Explode FOC Item" := false;

                                    if (INT_Temptableforimport3.gMain_Item_For_Delivery = 'Yes') or (INT_Temptableforimport3.gMain_Item_For_Delivery = 'YES') then
                                        gImpFOCLine."Main Item for Delivery" := true
                                    else
                                        gImpFOCLine."Main Item for Delivery" := false;

                                    if DocType = DocType::Package then
                                        gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::Package
                                    else
                                        gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::FOC;

                                    gImpFOCLine.Insert();
                                    INT_Temptableforimport3.Type := format(gImpFOCHeader.Type);
                                    INT_Temptableforimport3.DocNo := gImpFOCHeader."No.";
                                    INT_Temptableforimport3.Modify();
                                    Commit();
                                end;
                            end
                            else begin
                                if (INT_Temptableforimport3.gPromotionType = 'ITEM DISCOUNT') or (INT_Temptableforimport3.gPromotionType = 'GROUP DISCOUNT') or (INT_Temptableforimport3.gPromotionType = 'NONE') then begin
                                    DocType := DocType::Package;

                                end
                                else
                                    if (INT_Temptableforimport3.gPromotionType = 'FOC') or (INT_Temptableforimport3.gPromotionType = 'FOC WHIT DISCOUNT') then
                                        DocType := DocType::FOC;

                                pstart := ConvertTextToDateTime(INT_Temptableforimport3.gPeriodStart);
                                pend := ConvertTextToDateTime(INT_Temptableforimport3.gPeriodEnd);
                                //INT_Temptableforimport3.DocNo := gImpFOCHeader2."No.";
                                //INT_Temptableforimport3.Type := INT_Temptableforimport3.gPromotionType;
                                //INT_Temptableforimport3.Modify();
                                commit;
                                gImpFOCLine2.reset;
                                gImpFOCLine2.SetRange("No.", gImpFOCHeader2."No.");
                                gImpFOCLine2.SetRange(Type, gImpFOCHeader2.Type);
                                if gImpFOCLine2.Find('+') then begin
                                    lineNo := gImpFOCLine2."Line No." + 10000;
                                end;
                                //start
                                gImpFOCLine.init;
                                gImpFOCLine.type := DocType;
                                gImpFOCLine."No." := gImpFOCHeader2."No.";
                                gImpFOCLine.INT_External_SYN := gNo;
                                if gLineItemNo <> '' then
                                    Evaluate(LineItemNo, INT_Temptableforimport3.gLineItemNo);
                                gImpFOCLine."Line No." := lineNo;
                                gImpFOCLine.validate("Item No.", LineItemNo);
                                if not item.get(LineItemNo) then
                                    item.init;
                                Evaluate(qty, INT_Temptableforimport3.gQty);
                                gImpFOCLine.Validate(Quantity, qty);

                                gImpFOCLine."Item Description" := item.Description;
                                gImpFOCLine.Validate(UOM, item."Base Unit of Measure");


                                if INT_Temptableforimport3.gPromotionalPrice <> '' then begin
                                    Evaluate(promotionprice, INT_Temptableforimport3.gPromotionalPrice);
                                    gImpFOCLine."Promotional Price" := promotionprice;
                                end;
                                //gImpFOCLine."Storage Location" := gStorageLocation;
                                gImpFOCLine."Free Gift ID" := gImpFOCHeader."Free Gift ID";
                                if gImpFOCLine."SRP Price" < gImpFOCLine."Promotional Price" then begin
                                    INT_Temptableforimport3.gSRPPriece := format(gImpFOCLine."SRP Price");
                                    INT_Temptableforimport3.error := true;
                                    INT_Temptableforimport3.ErrorDes := 'Promo price should be less than SRP price';
                                end;

                                if (INT_Temptableforimport3.gInclude_FOC = 'Yes') or (INT_Temptableforimport3.gInclude_FOC = 'YES') then
                                    gImpFOCLine."Explode FOC Item" := true
                                else
                                    gImpFOCLine."Explode FOC Item" := false;

                                if (INT_Temptableforimport3.gMain_Item_For_Delivery = 'Yes') or (INT_Temptableforimport3.gMain_Item_For_Delivery = 'YES') then
                                    gImpFOCLine."Main Item for Delivery" := true
                                else
                                    gImpFOCLine."Main Item for Delivery" := false;

                                if DocType = DocType::Package then
                                    gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::Package
                                else
                                    gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::FOC;

                                gImpFOCLine.Insert();
                                INT_Temptableforimport3.Type := format(gImpFOCHeader2.Type);
                                INT_Temptableforimport3.DocNo := gImpFOCHeader2."No.";
                                INT_Temptableforimport3.Modify();
                                commit;
                                //start
                            end;

                        until INT_Temptableforimport3.Next() = 0;
                end;
                OldNo := INT_Temptableforimport2.gNo;
            until INT_Temptableforimport2.Next() = 0;
        end;
        //insert data
        clearextno;
        Changeatatus;
        checkpageero;

    end;

    procedure ConvertTextToDate(Txt: text): Date
    var
        lday: Integer;
        lmonth: Integer;
        lyear: Integer;
    begin
        if Txt <> '' then begin
            EVALUATE(lday, COPYSTR(Txt, 1, 2));
            EVALUATE(lmonth, COPYSTR(Txt, 4, 2));
            //EVALUATE(lmonth, COPYSTR(Txt, 1, 2));
            //EVALUATE(lday, COPYSTR(Txt, 4, 2));
            EVALUATE(lyear, COPYSTR(Txt, 7, 4));
            exit(DMY2Date(lday, lmonth, lyear));
        end else
            exit(0D);

    end;

    local procedure checkpageero()
    var
        myInt: Integer;
        INT_Temptableforimport: Record INT_Temptableforimport;
        Checkerrorimport: Page Checkerrorimport_Promotion;
    begin
        INT_Temptableforimport7.reset;
        INT_Temptableforimport7.SetRange(error, true);
        INT_Temptableforimport7.SetRange(foc, false);
        if INT_Temptableforimport7.Find('-') then begin
            Message('Have some error please check in error page.');
            Clear(Checkerrorimport);
            INT_Temptableforimport.reset;
            INT_Temptableforimport.SetRange(foc, false);
            INT_Temptableforimport.SetFilter(errordes, '<>%1', '');
            Checkerrorimport.SetTableView(INT_Temptableforimport);
            Checkerrorimport.run;
        end else
            Message('Import Completed');
    end;

    procedure ConvertTextToDateTime(Txt: text): Datetime
    var
        lday: Integer;
        lmonth: Integer;
        lyear: Integer;
        Thetime: Time;
    begin
        if Txt <> '' then begin
            EVALUATE(lday, COPYSTR(Txt, 1, 2));
            EVALUATE(lmonth, COPYSTR(Txt, 4, 2));
            //EVALUATE(lmonth, COPYSTR(Txt, 1, 2));
            //EVALUATE(lday, COPYSTR(Txt, 4, 2));
            EVALUATE(lyear, COPYSTR(Txt, 7, 4));
            evaluate(TheTime, copystr(Txt, 11, 8));
            exit(createdatetime(DMY2DATE(lday, lmonth, lyear), TheTime));
        end else
            exit(0DT);

    end;

    local procedure Changeatatus()
    var
        myInt: Integer;
    begin

        INT_Temptableforimport6.reset;
        INT_Temptableforimport6.SetCurrentKey(DocNo);
        INT_Temptableforimport6.SetRange(foc, false);
        INT_Temptableforimport6.SetFilter(DocNo, '<>%1', '');
        if INT_Temptableforimport6.Find('-') then begin
            repeat
                if OldNo2 <> INT_Temptableforimport6.DocNo then begin
                    FOCExt.reset;
                    FOCExt.SetRange("No.", INT_Temptableforimport6.DocNo);
                    if FOCExt.Find('-') then begin
                        CertifyBundleHeader(FOCExt, checkcclosestatus, checkerrortex);
                        if checkcclosestatus then begin
                            INT_Temptableforimport9.reset;
                            INT_Temptableforimport9.SetRange(DocNo, INT_Temptableforimport6.DocNo);
                            if INT_Temptableforimport9.find('-') then begin
                                INT_Temptableforimport9.ModifyAll(errordes, checkerrortex);
                                INT_Temptableforimport9.ModifyAll(error, true);
                            end;
                        end;
                        //Message('%1 %2', checkcclosestatus, checkerrortex);
                    end;
                end;
                OldNo2 := INT_Temptableforimport6.DocNo;
            until INT_Temptableforimport6.Next() = 0;
        end;
        INT_Temptableforimport10.reset;
        INT_Temptableforimport10.SetRange(error, true);
        INT_Temptableforimport10.SetRange(Foc, false);
        INT_Temptableforimport10.SetFilter(DocNo, '<>%1', '');
        if INT_Temptableforimport10.Find('-') then begin
            repeat
                FOCExtLine.reset;
                FOCExtLine.SetRange("No.", INT_Temptableforimport10.DocNo);
                if FOCExtLine.Find('-') then begin
                    FOCExtLine.DeleteAll();
                    FOCExt.reset;
                    FOCExt.SetRange("No.", INT_Temptableforimport10.DocNo);
                    if FOCExt.Find('-') then begin
                        FOCExt.Delete();
                    end;
                end;
            until INT_Temptableforimport10.Next() = 0;
        end;
    end;

    local procedure ValidatePackage(var BundleHeader: Record INT_BundleHeader_SNY; var cloststatus: Boolean; var checkerrortex: Text[100]);
    begin
        ValidateHeaderFields(BundleHeader);
        BundleHeader.CalcFields("SRP Price", BundleHeader."Promotion Price");
        if BundleHeader."SRP Price" = 0 then begin
            cloststatus := true;
            checkerrortex := 'SRP Price must not be 0';
        end;
        if BundleHeader."Promotion Price" = 0 then begin
            cloststatus := true;
            checkerrortex := 'Promotion Price must not be 0';
        end;
        //BundleHeader.TestField("SRP Price");
        //BundleHeader.TestField("Promotion Price");
        CheckDuplicate(BundleHeader, cloststatus, checkerrortex);
        //cloststatus
        //checkerrortex
    end;

    local procedure CheckDuplicate(BundleHeader: Record INT_BundleHeader_SNY; var cloststatus: Boolean; var checkerrortex: text[100]);
    var
        BundleHeader2: Record INT_BundleHeader_SNY;
        BundleLine: Record INT_BundleLine_SNY;
        BundleLine2: Record INT_BundleLine_SNY;
        DuplicateHeaderErr: Label 'Duplicate Package find for overlapping period. \Package No. %1 \ Starting Date: %2 \Ending Date: %3', Comment = '%1 = Package No. %2-Starting Date, %3 - Ending Date';
        DuplicateLineErr: Label 'Duplicate Item Found in Lines. \Item No.: %1', Comment = '%1 = Item No.';
        BackupateDummyMsg: Label 'Package default dummy delivery fee is not configured!\Do you want to continue?';
        NoPackageLineErr: Label 'There is no package line with "Related Item Type" as "Package"';
        MultipleDummyDeliveryErr: Label 'More than two default dummy delivery fee is configured! Please make only one line item as default';
    begin
        cloststatus := false;
        BundleLine.Reset();
        BundleLine.SetRange(Type, BundleHeader.Type);
        BundleLine.SetRange("No.", BundleHeader."No.");
        BundleLine.SetRange("Related Item Type", BundleLine."Related Item Type"::"Package");
        if BundleLine.IsEmpty() then begin
            //cloststatus := true;
            //checkerrortex := NoPackageLineErr;
        end;
        //Error(NoPackageLineErr);

        BundleLine.SetRange("Main Item for Delivery", true);
        if BundleLine.Count() > 1 then begin
            cloststatus := true;
            checkerrortex := MultipleDummyDeliveryErr;
        end;
        //Error(MultipleDummyDeliveryErr);

        //if BundleLine.IsEmpty() then begin
        //   cloststatus := true;
        //    checkerrortex := BackupateDummyMsg;
        //end;
        //if not confirm(BackupateDummyMsg, false) then
        //    Error('');

        //if BundleLine.FindFirst() then
        //repeat
        // BundleLine.TestField("Related Item No.");
        //until BundleLine.Next() = 0;


        //Check header duplicates
        BundleHeader2.Reset();
        BundleHeader2.SetRange(Type, BundleHeader2.Type::Package);
        BundleHeader2.SetRange("Item No.", BundleHeader."Item No.");
        //BundleHeader2.SetRange("Promotion Type", BundleHeader2."Promotion Type"::NONE);
        //Added by Sri Filter only within Marketplace
        BundleHeader2.SetRange(BundleHeader2.Marketplace, BundleHeader.Marketplace);
        BundleHeader2.SetRange(Status, BundleHeader2.Status::Certified);
        if BundleHeader2.FindSet() then
            repeat
                //if checkerrortex = '' then
                //    checkerrortex := '';
                if (BundleHeader."Starting Date" in [BundleHeader2."Starting Date", BundleHeader2."Ending Date"])
                 or (BundleHeader."Ending Date" in [BundleHeader2."Starting Date", BundleHeader2."Ending Date"]) then begin
                    cloststatus := true;
                    checkerrortex := 'Duplicate Package find for overlapping period.' + BundleHeader2."No." + ' ' + format(BundleHeader2."Starting Date");
                end;
            //Error(DuplicateHeaderErr, BundleHeader2."No.", BundleHeader2."Starting Date", BundleHeader2."Ending Date");
            until BundleHeader2.Next() = 0;

        //Line Duplicates
        BundleLine.Reset();
        BundleLine.SetRange(Type, BundleHeader.Type);
        BundleLine.SetRange("No.", BundleHeader."No.");
        if BundleLine.FindSet() then
            repeat
                //BundleLine.TestField("Item No.");
                //BundleLine.TestField(Quantity);
                //BundleLine.TestField("SRP Price");
                if BundleLine."SRP Price" = 0 then begin
                    cloststatus := true;
                    checkerrortex := 'SRP Price must not be 0';
                end;
                BundleLine2.Reset();
                BundleLine2.SetRange(Type, BundleHeader.Type);
                BundleLine2.SetRange("No.", BundleHeader."No.");
                BundleLine2.SetFilter("line No.", '<>%1', BundleLine."Line No.");
                BundleLine2.SetRange("Item No.", BundleLine."Item No.");
                if not BundleLine2.IsEmpty() then begin
                    cloststatus := true;
                    checkerrortex := 'Duplicate Item Found in Lines. \Item No.:' + format(BundleLine2."Item No.") + ' ' + BundleLine2."No.";
                end;
            //Er

            //Error(DuplicateLineErr, BundleLine2."Item No.");
            until BundleLine.Next() = 0;


    end;

    local procedure ValidateHeaderFields(var BundleHeader: Record INT_BundleHeader_SNY);
    begin
        BundleHeader.TestField(Marketplace);
        if BundleHeader."Promotion Type" = BundleHeader."Promotion Type"::None then
            BundleHeader.TestField("Item No.");

        if BundleHeader."Promotion Type" = BundleHeader."Promotion Type"::"Item Discount" then begin
            BundleHeader.TestField("Period Start");
            BundleHeader.TestField("Period End");
        end else begin
            BundleHeader.TestField("Starting Date");
            BundleHeader.TestField("Ending Date");
        end;
    end;

    procedure CertifyBundleHeader(var BundleHeader: Record INT_BundleHeader_SNY; var cloststatus: Boolean; var checkerrortex: Text[100]);
    var
        ActivateLbl: Label 'Do you want to certify %1 Bundle No.: %2?', Comment = '%1 = Bundle Type; %2 = Bundle No.';
    begin
        BundleHeader.TestField(BundleHeader.Type, BundleHeader.Type::Package);
        BundleHeader.CheckStatus();
        ValidatePackage(BundleHeader, cloststatus, checkerrortex);
        //if not Confirm(StrSubstNo(ActivateLbl, BundleHeader.Type, BundleHeader."No."), false) then
        //   Error('');
        ActivateBundle(BundleHeader);
        //Message('Certified Successfully!');
    end;

    Local procedure ActivateBundle(var BundleHeader: Record INT_BundleHeader_SNY);
    begin

        BundleHeader."Certified By" := copystr(userid(), 1, 50);
        BundleHeader."Certified Date" := Today();
        BundleHeader.Status := BundleHeader.Status::Certified;
        BundleHeader.UpdateStatus();
        BundleHeader."Is Active" := true;
        BundleHeader.Modify();
        commit;
    end;

    local procedure clearextno()
    var
        myInt: Integer;
    begin
        FOCExt.reset;
        //FOCExt.SetRange(Type, FOCExt.Type::FOC);
        FOCExt.SetFilter(INT_External_SYN, '<>%1', '');
        if FOCExt.Find('-') then
            repeat
                FOCExt.INT_External_SYN := '';
                FOCExt.Modify();
            until FOCExt.Next() = 0;
        //Delete Ext Doc
    end;

    var
        texterror: Text[100];
        DocType: Option FOC,Package;
        PromotionType: Option "NONE",FOC,"FOC WITH DISCOUNT","GROUP DISCOUNT","ITEM DISCOUNT";
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
        INT_BundleLine_SNY: Record INT_BundleLine_SNY;
        gImpFOCHeader2: Record INT_BundleHeader_SNY;
        FOCExt: Record INT_BundleHeader_SNY;
        lineNo: Integer;
        qty: Decimal;
        promotionprice: Decimal;
        LineItemNo: code[20];
        noserialMgn: Codeunit NoSeriesManagement;
        InterfaceSetup: Record INT_InterfaceSetup_SNY;
        OldNo: Code[40];
        pstart: DateTime;
        pend: DateTime;
        Promotioncode: Code[100];
        FOCExtLine: Record INT_BundleLine_SNY;

        tempFOC: Record INT_BundleHeader_SNY temporary;

        INT_Temptableforimport: Record INT_Temptableforimport;
        INT_Temptableforimport2: Record INT_Temptableforimport;
        INT_Temptableforimport3: Record INT_Temptableforimport;
        INT_Temptableforimport4: Record INT_Temptableforimport;
        INT_Temptableforimport5: Record INT_Temptableforimport;
        INT_Temptableforimport6: Record INT_Temptableforimport;
        INT_Temptableforimport7: Record INT_Temptableforimport;
        INT_Temptableforimport8: Record INT_Temptableforimport;
        INT_Temptableforimport9: Record INT_Temptableforimport;
        INT_Temptableforimport10: Record INT_Temptableforimport;
        gsortno: Integer;

        oldMarketplace: text[50];
        olditem: Text[50];
        startdate: date;
        enddate: date;
        marketplace: Record INT_MarketPlaces_SNY;
        addzaro: text[100];
        i: Integer;

        oldno2: Text[50];

        checkcclosestatus: Boolean;
        checkerrortex: text[150];
}
