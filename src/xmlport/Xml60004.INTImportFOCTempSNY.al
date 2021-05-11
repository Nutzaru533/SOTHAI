xmlport 60004 "INT_ImportFOCTemp_SNY"
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
                        INT_Temptableforimport.init;
                        INT_Temptableforimport.Foc := true;
                        INT_Temptableforimport.entryno := EntryNo;
                        INT_Temptableforimport.gNo := gNo;
                        INT_Temptableforimport.gDes := gDes;
                        INT_Temptableforimport.gStartingDate := gStartingDate;
                        INT_Temptableforimport.gEndingDate := gEndingDate;

                        INT_Temptableforimport.gQty := gQty;
                        INT_Temptableforimport.gSRPPriece := gSRPPriece;
                        INT_Temptableforimport.gPromotionalPrice := gPromotionalPrice;
                        INT_Temptableforimport.gRelated_Item_Type := gRelated_Item_Type;
                        INT_Temptableforimport.gStorageLocation := gStorageLocation;
                        //check item
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
                        end;
                        INT_Temptableforimport.gLineItemNo := gLineItemNo;
                        //check item
                        addzaro := '';
                        if StrLen(gItemNo) < 8 then begin
                            for i := 1 to (8 - StrLen(gItemNo)) do begin
                                addzaro := addzaro + '0';
                            end;
                            gItemNo := addzaro + gItemNo;
                        end;

                        INT_Temptableforimport.gItemNo := gItemNo;
                        if not item.get(INT_Temptableforimport.gItemNo) then begin
                            INT_Temptableforimport.error := true;
                            INT_Temptableforimport.ErrorDes := 'Item main does not exist';
                        end;
                        //check market
                        marketplace.reset;
                        marketplace.SetRange(marketplace, gMarketplace);
                        if not marketplace.find('-') then begin
                            INT_Temptableforimport.error := true;
                            INT_Temptableforimport.ErrorDes := 'Marketplace does not exist';
                        end else
                            INT_Temptableforimport.gMarketplace := gMarketplace;
                        //check market

                        StartDate := ConvertTextToDate(gStartingDate);
                        EndDate := ConvertTextToDate(gEndingDate);
                        if EndDate < Today then begin
                            INT_Temptableforimport.error := true;
                            INT_Temptableforimport.ErrorDes := 'Please check range Date !!';
                        end;
                        if (gqty = '') or (gqty = '0') then begin
                            INT_Temptableforimport.error := true;
                            INT_Temptableforimport.ErrorDes := 'Quantity must have value.';
                        end;

                        if StrPos(gQty, '.') > 0 then begin
                            INT_Temptableforimport.error := true;
                            INT_Temptableforimport.ErrorDes := 'Quantity must be integer not Decimal.';
                        end;

                        Evaluate(qty, gQty);
                        if qty < 0 then begin
                            INT_Temptableforimport.error := true;
                            INT_Temptableforimport.ErrorDes := 'Quantity must not be Negative.';
                        end;

                        INT_Temptableforimport.Insert();
                        Commit();
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
        //check error 
        gsortno := 1;
        INT_Temptableforimport2.reset;
        INT_Temptableforimport2.SetCurrentKey(gNo);
        INT_Temptableforimport2.SetRange(foc, true);
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
                                INT_Temptableforimport5.SetRange(Foc, true);
                                //INT_Temptableforimport5.SetRange(gNo, INT_Temptableforimport4.gNo);
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
        //check error 

        //insert data.
        OldNo := '';
        INT_Temptableforimport2.reset;
        INT_Temptableforimport2.SetCurrentKey(gNo);
        INT_Temptableforimport2.SetRange(error, false);
        INT_Temptableforimport2.SetRange(foc, true);
        INT_Temptableforimport2.SetFilter(gNo, '<>%1', '');
        if INT_Temptableforimport2.Find('-') then begin
            repeat
                if OldNo <> INT_Temptableforimport2.gNo then begin
                    INT_Temptableforimport3.reset;
                    INT_Temptableforimport3.SetRange(gNo, INT_Temptableforimport2.gNo);
                    if INT_Temptableforimport3.Find('-') then
                        repeat

                            gImpFOCHeader2.reset; //check document
                            gImpFOCHeader2.SetRange(INT_External_SYN, INT_Temptableforimport3.gNo);
                            gImpFOCHeader2.SetRange(Type, gImpFOCHeader2.type::FOC);
                            if not gImpFOCHeader2.find('-') then begin
                                gImpFOCHeader.init;
                                gImpFOCHeader.Type := gImpFOCHeader.Type::FOC;
                                gImpFOCHeader."No." := noserialMgn.GetNextNo(InterfaceSetup."FOC No. Series", workdate, true);
                                gImpFOCHeader.INT_External_SYN := INT_Temptableforimport3.gNo;
                                gImpFOCHeader."Free Gift ID" := INT_Temptableforimport3.gNo;
                                gImpFOCHeader.Validate(Marketplace, INT_Temptableforimport3.gMarketplace);
                                marketplace.reset;
                                marketplace.SetRange(marketplace, gImpFOCHeader.Marketplace);
                                if marketplace.Find('-') then begin
                                    gImpFOCHeader.Channel := marketplace.Channel;
                                end;
                                gImpFOCHeader.Description := INT_Temptableforimport3.gDes;
                                gImpFOCHeader.Validate("Item No.", INT_Temptableforimport3.gItemNo);
                                if not item.get(INT_Temptableforimport3.gItemNo) then
                                    item.init;
                                gImpFOCHeader."Item Description" := item.Description;
                                gImpFOCHeader."Starting Date" := ConvertTextToDate(INT_Temptableforimport3.gStartingDate);
                                gImpFOCHeader."Ending Date" := ConvertTextToDate(INT_Temptableforimport3.gEndingDate);
                                if gImpFOCHeader.Insert() then begin
                                    INT_Temptableforimport3.Type := format(gImpFOCHeader.Type);
                                    INT_Temptableforimport3.DocNo := gImpFOCHeader."No.";
                                    INT_Temptableforimport3.Modify();
                                    Commit();
                                    //check item
                                    addzaro := '';
                                    if StrLen(INT_Temptableforimport3.gLineItemNo) < 8 then begin
                                        for i := 1 to (8 - StrLen(INT_Temptableforimport3.gLineItemNo)) do begin
                                            addzaro := addzaro + '0';
                                        end;
                                        INT_Temptableforimport3.gLineItemNo := addzaro + INT_Temptableforimport3.gLineItemNo;
                                    end;
                                    INT_Temptableforimport3.gLineItemNo := INT_Temptableforimport3.gLineItemNo;
                                    //check item
                                    lineNo += 10000;
                                    gImpFOCLine.init;
                                    gImpFOCLine.type := gImpFOCLine.type::FOC;
                                    gImpFOCLine."No." := gImpFOCHeader."No.";
                                    gImpFOCLine.INT_External_SYN := gImpFOCHeader.INT_External_SYN;
                                    gImpFOCLine."Line No." := lineNo;
                                    Evaluate(LineItemNo, INT_Temptableforimport3.gLineItemNo);
                                    if not item.get(LineItemNo) then
                                        item.init;
                                    gImpFOCLine.Validate("Item No.", LineItemNo);
                                    gImpFOCLine."Item Description" := item.Description;
                                    gImpFOCLine.Validate(UOM, item."Base Unit of Measure");
                                    if INT_Temptableforimport3.gQty <> '' then begin
                                        Evaluate(qty, INT_Temptableforimport3.gQty);
                                        gImpFOCLine.Validate(Quantity, qty);
                                    end;
                                    if INT_Temptableforimport3.gSRPPriece <> '' then begin
                                        Evaluate(SrpPrice, INT_Temptableforimport3.gSRPPriece);
                                        gImpFOCLine."SRP Price" := SrpPrice;
                                    end;
                                    if gPromotionalPrice <> '' then
                                        Evaluate(promotionprice, INT_Temptableforimport3.gPromotionalPrice);
                                    gImpFOCLine."Promotional Price" := promotionprice;
                                    gImpFOCLine."Storage Location" := INT_Temptableforimport3.gStorageLocation;
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
                                gImpFOCLine2.SetRange(INT_External_SYN, INT_Temptableforimport3.gNo);
                                gImpFOCLine2.SetRange(Type, gImpFOCLine2.Type::FOC);
                                if gImpFOCLine2.Find('+') then begin
                                    lineNo := gImpFOCLine2."Line No." + 10000;
                                end;
                                //start
                                gImpFOCLine.init;
                                gImpFOCLine.type := gImpFOCLine.type::FOC;
                                gImpFOCLine."No." := gImpFOCLine2."No.";
                                gImpFOCLine.INT_External_SYN := INT_Temptableforimport3.gNo;
                                //check item
                                addzaro := '';
                                if StrLen(INT_Temptableforimport3.gLineItemNo) < 8 then begin
                                    for i := 1 to (8 - StrLen(INT_Temptableforimport3.gLineItemNo)) do begin
                                        addzaro := addzaro + '0';
                                    end;
                                    INT_Temptableforimport3.gLineItemNo := addzaro + INT_Temptableforimport3.gLineItemNo;
                                end;
                                INT_Temptableforimport3.gLineItemNo := INT_Temptableforimport3.gLineItemNo;
                                //check item

                                gImpFOCLine."Line No." := lineNo;
                                gImpFOCLine.Validate("Item No.", INT_Temptableforimport3.gLineItemNo);
                                if not item.get(INT_Temptableforimport3.gLineItemNo) then
                                    item.init;
                                gImpFOCLine."Item Description" := item.Description;
                                //gImpFOCLine.Validate(UOM, item."Base Unit of Measure");
                                if INT_Temptableforimport3.gQty <> '' then
                                    Evaluate(qty, INT_Temptableforimport3.gQty);
                                gImpFOCLine.Validate(Quantity, qty);
                                if INT_Temptableforimport3.gSRPPriece <> '' then begin
                                    Evaluate(SrpPrice, INT_Temptableforimport3.gSRPPriece);
                                    gImpFOCLine."SRP Price" := SrpPrice;
                                end;
                                if INT_Temptableforimport3.gPromotionalPrice <> '' then begin
                                    Evaluate(promotionprice, INT_Temptableforimport3.gPromotionalPrice);
                                    gImpFOCLine."Promotional Price" := promotionprice;
                                end;
                                gImpFOCLine."Storage Location" := INT_Temptableforimport3.gStorageLocation;
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
                                INT_Temptableforimport3.Type := format(gImpFOCHeader2.Type);
                                INT_Temptableforimport3.DocNo := gImpFOCHeader2."No.";
                                INT_Temptableforimport3.Modify();
                                commit;
                                gImpFOCLine.Insert();
                                Commit();
                                //start
                            end;

                        until INT_Temptableforimport3.Next() = 0;
                end;
                OldNo := INT_Temptableforimport2.gNo;
            until INT_Temptableforimport2.Next() = 0;
        end;
        //insert data
        clearextno;
        Certify;
        checkpageero;
        //Message('FOC Import Completed');
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

    local procedure checkpageero()
    var
        myInt: Integer;
    begin
        INT_Temptableforimport7.reset;
        INT_Temptableforimport7.SetRange(error, true);
        INT_Temptableforimport7.SetRange(foc, true);
        if INT_Temptableforimport7.Find('-') then
            Message('Have some error please check in error page.')
        else
            Message('Import Completed');
    end;

    local procedure Certify()
    var
        myInt: Integer;
    begin
        INT_Temptableforimport6.reset;
        INT_Temptableforimport6.SetCurrentKey(DocNo);
        INT_Temptableforimport6.SetFilter(DocNo, '<>%1', '');
        INT_Temptableforimport6.SetRange(foc, true);
        if INT_Temptableforimport6.Find('-') then begin
            repeat
                if OldNo2 <> INT_Temptableforimport6.DocNo then begin
                    FOCExt.reset;
                    FOCExt.SetRange("No.", INT_Temptableforimport6.DocNo);
                    if FOCExt.Find('-') then begin

                        if FOCExt."Item No." = '' then begin
                            INT_Temptableforimport6.error := true;
                            INT_Temptableforimport6.ErrorDes := 'Item must have value in Header.';
                            INT_Temptableforimport6.Modify();
                            Commit();
                        end;

                        INT_BundleLine_SNY.reset;
                        INT_BundleLine_SNY.SetRange("No.", FOCExt."No.");
                        if INT_BundleLine_SNY.Find('-') then begin
                            repeat
                                INT_BundleLine_SNY.CalcSums("SRP Price");
                                INT_BundleLine_SNY.CalcSums("Promotional Price");
                                checksrpprice += INT_BundleLine_SNY."SRP Price";
                                checkPromotionPrice += INT_BundleLine_SNY."Promotional Price";
                            until INT_BundleLine_SNY.Next = 0;
                            if (checksrpprice <> 0) or (checkPromotionPrice <> 0) then begin
                                INT_Temptableforimport6.error := true;
                                INT_Temptableforimport6.ErrorDes := 'SRP or Promotional Sum Amount Should equal to zero.';
                                INT_Temptableforimport6.Modify();
                                Commit();
                            end else begin
                                FOCExt."Is Active" := true;
                                FOCExt."Activated By" := UserId;
                                FOCExt."Activated Date" := today;
                                FOCExt.Modify();
                                Commit();
                            end;
                        end;

                    end;
                end;
                OldNo2 := INT_Temptableforimport6.DocNo;
            until INT_Temptableforimport6.Next() = 0;
        end;
        INT_Temptableforimport10.reset;
        INT_Temptableforimport10.SetRange(error, true);
        INT_Temptableforimport10.SetRange(Foc, true);
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
        OldNo2: code[40];
        i: Integer;
        addzaro: Text[100];
        checksrpprice: Decimal;
        checkPromotionPrice: Decimal;
        checkerror: Boolean;
        checkstr: Text;
        INT_Temptableforimport: Record INT_Temptableforimport;
        INT_Temptableforimport2: Record INT_Temptableforimport;
        INT_Temptableforimport3: Record INT_Temptableforimport;
        INT_Temptableforimport4: Record INT_Temptableforimport;
        INT_Temptableforimport5: Record INT_Temptableforimport;
        INT_Temptableforimport6: Record INT_Temptableforimport;
        INT_Temptableforimport7: Record INT_Temptableforimport;
        INT_Temptableforimport8: Record INT_Temptableforimport;
        INT_Temptableforimport10: Record INT_Temptableforimport;
        StartDate: date;
        EndDate: date;
        oldMarketplace: text[50];
        olditem: Text[50];
        marketplace: Record INT_MarketPlaces_SNY;
        gsortno: Integer;
        texterror: Text[100];
}
