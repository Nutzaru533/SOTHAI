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
                    if EntryNo > 1 then begin
                        Promotioncode := gPromotionType;

                        if (Promotioncode = 'ITEM DISCOUNT') or (Promotioncode = 'GROUP DISCOUNT') or (Promotioncode = 'NONE') then
                            DocType := DocType::Package
                        else
                            if (Promotioncode = 'FOC') or (Promotioncode = 'FOC WHIT DISCOUNT') then
                                DocType := DocType::FOC;
                        //Promotioncode := gPromotionType;

                        if Promotioncode = 'NONE' then
                            PromotionType := PromotionType::None
                        else
                            if Promotioncode = 'FOC' then
                                PromotionType := PromotionType::FOC
                            else
                                if Promotioncode = 'FOC WHIT DISCOUNT' then
                                    PromotionType := PromotionType::"FOC With Discount"
                                else
                                    if Promotioncode = 'GROUP DISCOUNT' then
                                        PromotionType := PromotionType::"Group Discount"
                                    else
                                        if Promotioncode = 'ITEM DISCOUNT' then
                                            PromotionType := PromotionType::"Item Discount"
                                        else
                                            error('Promotion type not have in system %1', gPromotionType);

                        if (Promotioncode = 'ITEM DISCOUNT') then begin
                            marketplace.reset;
                            marketplace.SetRange(marketplace, gMarketplace);
                            if marketplace.Find('-') then begin
                                if marketplace."Have Item Discount" = false then
                                    error('Item Discount not have in this marketplace');
                            end;
                        end;



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
                                //if OldNo <> '' then
                                //    CertifyBundleHeader(FOCExt);
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

                            if gImpFOCHeader."Ending Date" < today then begin
                                error('Please check range Date !!');
                            end;

                            if gQty = '' then
                                error('Quantity Must have Value');

                            gImpFOCHeader.Status := gImpFOCHeader.Status::"Config WIP";
                            if gImpFOCHeader.Insert() then begin
                                //insert temp
                                tempFOC := gImpFOCHeader;
                                tempFOC.Insert();
                                //insert temp
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
                                    Evaluate(qty, gQty)
                                else
                                    error('Quantity Must have Value');
                                gImpFOCLine.Validate(Quantity, qty);

                                if gPromotionalPrice <> '' then begin
                                    Evaluate(promotionprice, gPromotionalPrice);
                                    gImpFOCLine."Promotional Price" := promotionprice;
                                    //gImpFOCLine."Storage Location" := gStorageLocation;
                                end;
                                if gImpFOCLine."SRP Price" < gImpFOCLine."Promotional Price" then begin
                                    FOCExt.Reset();
                                    FOCExt.SetRange("No.", gImpFOCHeader."No.");
                                    if FOCExt.Find('-') then
                                        FOCExt.Delete();
                                    Commit();
                                    error('SRP Price should be greater then Promotion Price !!');
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

                                if DocType = DocType::Package then
                                    gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::Package
                                else
                                    gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::FOC;

                                gImpFOCLine.Insert();
                                Commit();
                            end;
                        end
                        else begin
                            pstart := ConvertTextToDateTime(gPeriodStart);
                            pend := ConvertTextToDateTime(gPeriodEnd);

                            if gImpFOCHeader2."Item No." <> gItemNo then begin
                                FOCExtLine.reset;
                                FOCExtLine.SetRange(Type, FOCExt.Type);
                                FOCExtLine.SetRange("No.", FOCExt."No.");
                                if FOCExtLine.Find('-') then
                                    repeat
                                        FOCExtLine.Delete();
                                    until FOCExtLine.Next() = 0;
                                FOCExt.Reset();
                                FOCExt.SetRange("No.", gImpFOCHeader2."No.");
                                if FOCExt.Find('-') then
                                    FOCExt.Delete();
                                clearextno;
                                error('item no. should be same');
                            end;
                            if gImpFOCHeader2.Marketplace <> gMarketplace then begin
                                FOCExtLine.reset;
                                FOCExtLine.SetRange(Type, FOCExt.Type);
                                FOCExtLine.SetRange("No.", FOCExt."No.");
                                if FOCExtLine.Find('-') then
                                    repeat
                                        FOCExtLine.Delete();
                                    until FOCExtLine.Next() = 0;
                                FOCExt.Reset();
                                FOCExt.SetRange("No.", gImpFOCHeader2."No.");
                                if FOCExt.Find('-') then
                                    FOCExt.Delete();
                                clearextno;
                                error('Marketplace should be same');
                            end;

                            if gImpFOCHeader2."Period Start" <> pstart then begin
                                FOCExtLine.reset;
                                FOCExtLine.SetRange(Type, FOCExt.Type);
                                FOCExtLine.SetRange("No.", FOCExt."No.");
                                if FOCExtLine.Find('-') then
                                    repeat
                                        FOCExtLine.Delete();
                                    until FOCExtLine.Next() = 0;
                                FOCExt.Reset();
                                FOCExt.SetRange("No.", gImpFOCHeader2."No.");
                                if FOCExt.Find('-') then
                                    FOCExt.Delete();
                                clearextno;
                                error('Period Start should be same all extenal no.');
                            end;

                            if gImpFOCHeader2."Period End" <> pend then begin
                                FOCExtLine.reset;
                                FOCExtLine.SetRange(Type, FOCExt.Type);
                                FOCExtLine.SetRange("No.", FOCExt."No.");
                                if FOCExtLine.Find('-') then
                                    repeat
                                        FOCExtLine.Delete();
                                    until FOCExtLine.Next() = 0;
                                FOCExt.Reset();
                                FOCExt.SetRange("No.", gImpFOCHeader2."No.");
                                if FOCExt.Find('-') then
                                    FOCExt.Delete();
                                clearextno;
                                error('Period End should be same all extenal no.');
                            end;


                            gImpFOCLine2.reset;
                            gImpFOCLine2.SetRange(INT_External_SYN, gNo);
                            gImpFOCLine2.SetRange(Type, DocType);
                            if gImpFOCLine2.Find('+') then begin
                                lineNo := gImpFOCLine2."Line No." + 10000;
                            end;
                            //start
                            gImpFOCLine.init;
                            gImpFOCLine.type := DocType;
                            gImpFOCLine."No." := gImpFOCHeader2."No.";
                            gImpFOCLine.INT_External_SYN := gNo;
                            if gLineItemNo <> '' then
                                Evaluate(LineItemNo, gLineItemNo);
                            gImpFOCLine."Line No." := lineNo;
                            gImpFOCLine.Validate("Item No.", LineItemNo);
                            if not item.get(LineItemNo) then
                                item.init;
                            gImpFOCLine."Item Description" := item.Description;
                            gImpFOCLine.Validate(UOM, item."Base Unit of Measure");
                            if gQty <> '' then
                                Evaluate(qty, gQty)
                            else
                                error('Quantity Must have Value');
                            gImpFOCLine.Validate(Quantity, qty);

                            if gPromotionalPrice <> '' then begin
                                Evaluate(promotionprice, gPromotionalPrice);
                                gImpFOCLine."Promotional Price" := promotionprice;
                            end;
                            //gImpFOCLine."Storage Location" := gStorageLocation;
                            gImpFOCLine."Free Gift ID" := gImpFOCHeader."Free Gift ID";

                            if gImpFOCLine."SRP Price" < gImpFOCLine."Promotional Price" then
                                error('SRP Price should be greater then Promotion Price !!');

                            if (gInclude_FOC = 'Yes') or (gInclude_FOC = 'YES') then
                                gImpFOCLine."Explode FOC Item" := true
                            else
                                gImpFOCLine."Explode FOC Item" := false;

                            if (gMain_Item_For_Delivery = 'Yes') or (gMain_Item_For_Delivery = 'YES') then
                                gImpFOCLine."Main Item for Delivery" := true
                            else
                                gImpFOCLine."Main Item for Delivery" := false;

                            if DocType = DocType::Package then
                                gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::Package
                            else
                                gImpFOCLine."Related Item Type" := gImpFOCLine."Related Item Type"::FOC;

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
        //FOCExt.SetRange("No.", OldNo);
        FOCExt.SetFilter(INT_External_SYN, '<>%1', '');
        if FOCExt.Find('-') then
            repeat
                FOCExt.INT_External_SYN := '';
                FOCExt.Modify();
            until FOCExt.Next() = 0;
        //Delete Ext Doc


        tempFOC.reset;
        tempFOC.SetFilter("No.", '<>%1', '');
        if tempFOC.Find('-') then
            repeat
                FOCExt.reset;
                FOCExt.SetRange("No.", tempFOC."No.");
                FOCExt.SetRange(Type, tempFOC.Type);
                if FOCExt.Find('-') then begin
                    ActivateBundle(FOCExt);
                end;
            until tempFOC.Next() = 0;

        Message('Import Completed');
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

    local procedure ValidatePackage(var BundleHeader: Record INT_BundleHeader_SNY);
    begin
        ValidateHeaderFields(BundleHeader);
        BundleHeader.CalcFields("SRP Price", BundleHeader."Promotion Price");
        BundleHeader.TestField("SRP Price");
        BundleHeader.TestField("Promotion Price");
        CheckDuplicate(BundleHeader);
    end;

    local procedure CheckDuplicate(BundleHeader: Record INT_BundleHeader_SNY);
    var
        BundleHeader2: Record INT_BundleHeader_SNY;
        BundleLine: Record INT_BundleLine_SNY;
        BundleLine2: Record INT_BundleLine_SNY;
        DuplicateHeaderErr: Label 'Duplicate Package find for overlapping period. \Package No. %1 \ Starting Date: %2 \Ending Date: %3', Comment = '%1 = Package No. %2-Starting Date, %3 - Ending Date';
        DuplicateLineErr: Label 'Duplicate Item Found in Lines. \Item No.: %1', Comment = '%1 = Item No.';
        BackupateDummyMsg: Label 'Package default dummy delivery fee is not configured!\Do you want to continue?';
        NoPackageLineErr: Label 'There is no package line with "Realted Item Type" as "Package"';
        MultipleDummyDeliveryErr: Label 'More than two default dummy delivery fee is configured! Please make only one line item as default';
    begin

        BundleLine.Reset();
        BundleLine.SetRange(Type, BundleHeader.Type);
        BundleLine.SetRange("No.", BundleHeader."No.");
        BundleLine.SetRange("Related Item Type", BundleLine."Related Item Type"::"Package");
        if BundleLine.IsEmpty() then
            Error(NoPackageLineErr);

        BundleLine.SetRange("Main Item for Delivery", true);
        if BundleLine.Count() > 1 then
            Error(MultipleDummyDeliveryErr);

        if BundleLine.IsEmpty() then
            if not confirm(BackupateDummyMsg, false) then
                Error('');

        //if BundleLine.FindFirst() then
        //repeat
        // BundleLine.TestField("Related Item No.");
        //until BundleLine.Next() = 0;


        //Check header duplicates
        BundleHeader2.Reset();
        BundleHeader2.SetRange(Type, BundleHeader2.Type::Package);
        BundleHeader2.SetRange("Item No.", BundleHeader."Item No.");
        //Added by Sri Filter only within Marketplace
        BundleHeader2.SetRange(BundleHeader2.Marketplace, BundleHeader.Marketplace);
        BundleHeader2.SetRange(Status, BundleHeader2.Status::Certified);
        if BundleHeader2.FindSet() then
            repeat
                if (BundleHeader."Starting Date" in [BundleHeader2."Starting Date", BundleHeader2."Ending Date"])
                 or (BundleHeader."Ending Date" in [BundleHeader2."Starting Date", BundleHeader2."Ending Date"]) then
                    Error(DuplicateHeaderErr, BundleHeader2."No.", BundleHeader2."Starting Date", BundleHeader2."Ending Date");
            until BundleHeader2.Next() = 0;

        //Line Duplicates
        BundleLine.Reset();
        BundleLine.SetRange(Type, BundleHeader.Type);
        BundleLine.SetRange("No.", BundleHeader."No.");
        if BundleLine.FindSet() then
            repeat
                BundleLine.TestField("Item No.");
                BundleLine.TestField(Quantity);
                BundleLine.TestField("SRP Price");
                BundleLine2.Reset();
                BundleLine2.SetRange(Type, BundleHeader.Type);
                BundleLine2.SetRange("No.", BundleHeader."No.");
                BundleLine2.SetFilter("line No.", '<>%1', BundleLine."Line No.");
                BundleLine2.SetRange("Item No.", BundleLine."Item No.");
                if not BundleLine2.IsEmpty() then
                    Error(DuplicateLineErr, BundleLine2."Item No.");
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

    procedure CertifyBundleHeader(var BundleHeader: Record INT_BundleHeader_SNY);
    var
        ActivateLbl: Label 'Do you want to certify %1 Bundle No.: %2?', Comment = '%1 = Bundle Type; %2 = Bundle No.';
    begin
        BundleHeader.TestField(BundleHeader.Type, BundleHeader.Type::Package);
        BundleHeader.CheckStatus();
        ValidatePackage(BundleHeader);
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
        BundleHeader.Modify();
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
}
