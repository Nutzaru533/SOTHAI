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
                        //checkstr 
                        checkerror := false;
                        gImpFOCHeader2.reset; //check document
                        gImpFOCHeader2.SetRange(INT_External_SYN, gNo);
                        gImpFOCHeader2.SetRange(Type, gImpFOCHeader2.type::FOC);
                        if not gImpFOCHeader2.find('-') then begin
                            gImpFOCHeader.init;
                            gImpFOCHeader.Type := gImpFOCHeader.Type::FOC;
                            gImpFOCHeader."No." := noserialMgn.GetNextNo(InterfaceSetup."FOC No. Series", workdate, true);
                            if OldNo <> gImpFOCHeader."No." then begin
                                //Delete Ext Doc
                                if (gqty = '') or (gqty = '0') then
                                    error('Quantity must have value.');
                                if StrPos(gqty, '.') > 0 then
                                    error('Quantity must be integer not Decimal.');
                                Evaluate(qty, gQty);
                                if qty < 0 then
                                    error('Quantity must not be Negative.');
                                FOCExt.reset;
                                FOCExt.SetRange("No.", OldNo);
                                FOCExt.SetRange(Type, FOCExt.type::FOC);
                                if FOCExt.Find('-') then begin
                                    FOCExt.INT_External_SYN := '';
                                    FOCExt.Validate("Is Active", true);
                                    INT_BundleLine_SNY.reset;
                                    INT_BundleLine_SNY.SetRange("No.", FOCExt."No.");
                                    if INT_BundleLine_SNY.Find('-') then begin
                                        repeat
                                            INT_BundleLine_SNY.CalcSums("SRP Price");
                                            INT_BundleLine_SNY.CalcSums("Promotional Price");
                                            checksrpprice += INT_BundleLine_SNY."SRP Price";
                                            checkPromotionPrice += INT_BundleLine_SNY."Promotional Price";
                                        until INT_BundleLine_SNY.Next = 0;
                                        if checksrpprice <> 0 then begin
                                            checkerror := true;
                                            FOCExtLine.reset;
                                            FOCExtLine.SetRange(Type, FOCExt.Type);
                                            FOCExtLine.SetRange("No.", FOCExt."No.");
                                            if FOCExtLine.Find('-') then
                                                repeat
                                                    FOCExtLine.Delete();
                                                until FOCExtLine.Next() = 0;
                                            FOCExt.Delete();
                                            Error('SRP Sum Amount Should equal to zero');
                                        end;
                                        if checkPromotionPrice <> 0 then begin
                                            checkerror := true;
                                            FOCExtLine.reset;
                                            FOCExtLine.SetRange(Type, FOCExt.Type);
                                            FOCExtLine.SetRange("No.", FOCExt."No.");
                                            if FOCExtLine.Find('-') then
                                                repeat
                                                    FOCExtLine.Delete();
                                                until FOCExtLine.Next() = 0;
                                            FOCExt.Delete();
                                            error('Promotional Amount Should equal to zero');
                                        end;
                                    end;
                                    if checkerror = false then begin
                                        FOCExt."Is Active" := true;
                                        FOCExt."Activated By" := UserId;
                                        FOCExt."Activated Date" := today;
                                        FOCExt.Modify();
                                    end;
                                end;
                                //Delete Ext Doc
                            end;
                            gImpFOCHeader.INT_External_SYN := gNo;
                            //
                            OldNo := gImpFOCHeader."No.";
                            //
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
                            //Message('%1 - %2', gImpFOCHeader."Ending Date", Today);
                            if gImpFOCHeader."Ending Date" < Today then begin
                                error('Please check range Date !!');
                            end;
                            if gImpFOCHeader.Insert() then begin
                                //check item
                                addzaro := '';
                                if StrLen(gLineItemNo) < 8 then begin
                                    for i := 1 to (8 - StrLen(gLineItemNo)) do begin
                                        addzaro := addzaro + '0';
                                    end;
                                    gLineItemNo := addzaro + gLineItemNo;
                                end;
                                gLineItemNo := gLineItemNo;
                                //check item
                                lineNo += 10000;
                                gImpFOCLine.init;
                                gImpFOCLine.type := gImpFOCLine.type::FOC;
                                gImpFOCLine."No." := gImpFOCHeader."No.";
                                gImpFOCLine.INT_External_SYN := gImpFOCHeader.INT_External_SYN;
                                Evaluate(LineItemNo, gLineItemNo);
                                gImpFOCLine."Line No." := lineNo;
                                gImpFOCLine.Validate("Item No.", LineItemNo);
                                if not item.get(gLineItemNo) then
                                    item.init;
                                gImpFOCLine."Item Description" := item.Description;
                                gImpFOCLine.Validate(UOM, item."Base Unit of Measure");
                                if gQty <> '' then begin
                                    Evaluate(qty, gQty);
                                    gImpFOCLine.Validate(Quantity, qty);
                                end;
                                if gSRPPriece <> '' then begin
                                    Evaluate(SrpPrice, gSRPPriece);
                                    gImpFOCLine."SRP Price" := SrpPrice;
                                end;
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
                            if (gqty = '') or (gqty = '0') then begin
                                FOCExtLine.reset;
                                FOCExtLine.SetRange(Type, gImpFOCHeader2.Type);
                                FOCExtLine.SetRange("No.", gImpFOCHeader2."No.");
                                if FOCExtLine.Find('-') then begin
                                    repeat
                                        FOCExtLine.Delete();
                                    until FOCExtLine.Next() = 0;
                                    FOCExt.reset;
                                    FOCExt.SetRange("No.", gImpFOCHeader2."No.");
                                    FOCExt.SetRange(type, gImpFOCHeader2.Type);
                                    if FOCExt.Find('-') then
                                        FOCExt.Delete();
                                end;
                                clearextno;
                                error('Quantity must have value.');
                            end;
                            if StrPos(gqty, '.') > 0 then begin
                                FOCExtLine.reset;
                                FOCExtLine.SetRange(Type, gImpFOCHeader2.Type);
                                FOCExtLine.SetRange("No.", gImpFOCHeader2."No.");
                                if FOCExtLine.Find('-') then
                                    repeat
                                        FOCExtLine.Delete();
                                    until FOCExtLine.Next() = 0;
                                FOCExt.reset;
                                FOCExt.SetRange("No.", gImpFOCHeader2."No.");
                                FOCExt.SetRange(type, gImpFOCHeader2.Type);
                                if FOCExt.Find('-') then
                                    FOCExt.Delete();
                                clearextno;
                                error('Quantity must be integer not Decimal.');
                            end;
                            if qty < 0 then begin
                                FOCExtLine.reset;
                                FOCExtLine.SetRange(Type, gImpFOCHeader2.Type);
                                FOCExtLine.SetRange("No.", gImpFOCHeader2."No.");
                                if FOCExtLine.Find('-') then
                                    repeat
                                        FOCExtLine.Delete();
                                    until FOCExtLine.Next() = 0;
                                FOCExt.reset;
                                FOCExt.SetRange("No.", gImpFOCHeader2."No.");
                                FOCExt.SetRange(type, gImpFOCHeader2.Type);
                                if FOCExt.Find('-') then
                                    FOCExt.Delete();
                                clearextno;
                                error('Quantity must not be Negative.');
                            end;
                            if gImpFOCHeader2.Marketplace <> gMarketplace then begin
                                FOCExtLine.reset;
                                FOCExtLine.SetRange(Type, gImpFOCHeader2.Type);
                                FOCExtLine.SetRange("No.", gImpFOCHeader2."No.");
                                if FOCExtLine.Find('-') then
                                    repeat
                                        FOCExtLine.Delete();
                                    until FOCExtLine.Next() = 0;
                                FOCExt.reset;
                                FOCExt.SetRange("No.", gImpFOCHeader2."No.");
                                FOCExt.SetRange(type, gImpFOCHeader2.Type);
                                if FOCExt.Find('-') then
                                    FOCExt.Delete();
                                clearextno;
                                error('Marketplace should be Same');
                            end;
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
                            //check item
                            addzaro := '';
                            if StrLen(gLineItemNo) < 8 then begin
                                for i := 1 to (8 - StrLen(gLineItemNo)) do begin
                                    addzaro := addzaro + '0';
                                end;
                                gLineItemNo := addzaro + gLineItemNo;
                            end;
                            gLineItemNo := gLineItemNo;
                            //check item
                            if gLineItemNo <> '' then
                                Evaluate(LineItemNo, gLineItemNo);
                            gImpFOCLine."Line No." := lineNo;
                            gImpFOCLine.Validate("Item No.", LineItemNo);
                            if not item.get(gLineItemNo) then
                                item.init;
                            gImpFOCLine."Item Description" := item.Description;
                            gImpFOCLine.Validate(UOM, item."Base Unit of Measure");
                            if gQty <> '' then
                                Evaluate(qty, gQty);
                            gImpFOCLine.Validate(Quantity, qty);
                            if gSRPPriece <> '' then begin
                                Evaluate(SrpPrice, gSRPPriece);
                                gImpFOCLine."SRP Price" := SrpPrice;
                            end;
                            if gPromotionalPrice <> '' then begin
                                Evaluate(promotionprice, gPromotionalPrice);
                                gImpFOCLine."Promotional Price" := promotionprice;
                            end;
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
        //Delete Ext Doc

        checkerror := false;
        FOCExt.reset;
        FOCExt.SetRange("No.", OldNo);
        if FOCExt.Find('-') then begin
            FOCExt.INT_External_SYN := '';
            INT_BundleLine_SNY.reset;
            INT_BundleLine_SNY.SetRange("No.", FOCExt."No.");
            if INT_BundleLine_SNY.Find('-') then begin
                repeat
                    INT_BundleLine_SNY.CalcSums("SRP Price");
                    INT_BundleLine_SNY.CalcSums("Promotional Price");
                    checksrpprice += INT_BundleLine_SNY."SRP Price";
                    checkPromotionPrice += INT_BundleLine_SNY."Promotional Price";
                until INT_BundleLine_SNY.Next = 0;
                if checksrpprice <> 0 then begin
                    checkerror := true;
                    FOCExtLine.reset;
                    FOCExtLine.SetRange(Type, FOCExt.Type);
                    FOCExtLine.SetRange("No.", FOCExt."No.");
                    if FOCExtLine.Find('-') then
                        repeat
                            FOCExtLine.Delete();
                        until FOCExtLine.Next() = 0;
                    FOCExt.Delete();
                    Error('SRP Sum Amount Should equal to zero');
                end;

                if checkPromotionPrice <> 0 then begin
                    FOCExtLine.reset;
                    FOCExtLine.SetRange(Type, FOCExt.Type);
                    FOCExtLine.SetRange("No.", FOCExt."No.");
                    if FOCExtLine.Find('-') then
                        repeat
                            FOCExtLine.Delete();
                        until FOCExtLine.Next() = 0;
                    FOCExt.Delete();
                    error('Promotional Amount Should equal to zero');
                end;

            end;
            if checkerror = false then begin
                FOCExt."Is Active" := true;
                FOCExt."Activated By" := UserId;
                FOCExt."Activated Date" := today;
                FOCExt.Modify();
                commit;
            end;
        end;
        //Delete Ext Doc
        FOCExt.reset;
        FOCExt.SetFilter(INT_External_SYN, '<>%1', '');
        if FOCExt.Find('-') then
            repeat
                FOCExt.INT_External_SYN := '';
                FOCExt.Modify();
            until FOCExt.Next() = 0;
        //Delete Ext Doc

        FOCExtLine.reset;
        FOCExtLine.SetFilter(INT_External_SYN, '<>%1', '');
        if FOCExtLine.Find('-') then
            repeat
                FOCExtLine.INT_External_SYN := '';
                FOCExtLine.Modify();
            until FOCExtLine.Next() = 0;
        Message('FOC Import Completed');

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

    local procedure clearextno()
    var
        myInt: Integer;
    begin
        FOCExt.reset;
        FOCExt.SetRange(Type, FOCExt.Type::FOC);
        FOCExt.SetFilter(INT_External_SYN, '<>%1', '');
        if FOCExt.Find('-') then
            repeat
                FOCExt.INT_External_SYN := '';
                FOCExt.Modify();
            until FOCExt.Next() = 0;
        //Delete Ext Doc
    end;

    var
        gEntNo: Integer;
        EntryNo: Integer;
        gIsFirstRow: Boolean;
        gImpSalLine: Record INT_ImportSalesLine_SNY;
        gImpFOCHeader: Record INT_BundleHeader_SNY;
        updateImpFOCHeader3: Record INT_BundleHeader_SNY;
        SrpPrice: Decimal;
        PromotionPirce: Decimal;
        item: Record item;
        gImpFOCLine: Record INT_BundleLine_SNY;
        gImpFOCLine2: Record INT_BundleLine_SNY;
        INT_BundleLine_SNY: Record INT_BundleLine_SNY;
        gImpFOCHeader2: Record INT_BundleHeader_SNY;
        FOCExt: Record INT_BundleHeader_SNY;
        FOCExtLine: Record INT_BundleLine_SNY;
        lineNo: Integer;
        qty: Decimal;
        promotionprice: Decimal;
        LineItemNo: code[20];
        noserialMgn: Codeunit NoSeriesManagement;
        InterfaceSetup: Record INT_InterfaceSetup_SNY;
        OldNo: Code[40];
        i: Integer;
        addzaro: Text[100];
        checksrpprice: Decimal;
        checkPromotionPrice: Decimal;

        checkerror: Boolean;
        checkstr: Text;

}
