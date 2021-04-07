xmlport 60001 "INT_ImportFOCHeader_SNY"
{
    caption = 'Import FOC Head';
    Format = VariableText;
    Direction = Import;
    FieldSeparator = ',';
    TextEncoding = UTF8;

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


                textelement(gType)
                {
                    MinOccurs = Zero;

                }
                textelement(gFreeGiftID)
                {
                    MinOccurs = Zero;

                }
                textelement(gNo)
                {
                    MinOccurs = Zero;
                }
                textelement(gMarketplace)
                {
                    MinOccurs = Zero;
                }
                textelement(gChannel)
                {
                }
                textelement(gDes)
                {
                }
                textelement(gItemNo)
                {
                }
                textelement(gitemDes)
                { }
                textelement(gStartingDate)
                {
                }
                textelement(gEndingDate)
                {
                }
                textelement(gIsActive)
                {
                }
                //textelement(gSRPPrice)
                // {
                // }
                //textelement(gPromotionPrice)
                //{
                // }
                textelement(gActivedDate)
                {
                }
                textelement(gActiviatedBy)
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
                    if EntryNo > 1 then begin
                        gImpFOCHeader.init;
                        gImpFOCHeader.Type := gImpFOCHeader.Type::FOC;
                        gImpFOCHeader."No." := gNo;
                        if gFreeGiftID = '' then
                            error('Please Input Free Gift ID');
                        gImpFOCHeader."Free Gift ID" := gFreeGiftID;
                        gImpFOCHeader.Validate(Marketplace, gMarketplace);
                        marketplace.reset;
                        marketplace.SetRange(marketplace, gImpFOCHeader.Marketplace);
                        if marketplace.Find('-') then begin
                            gImpFOCHeader.Channel := marketplace.Channel;
                        end;
                        gImpFOCHeader.Description := gDes;
                        gImpFOCHeader.Validate("Item No.", gItemNo);
                        gImpFOCHeader."Item Description" := gitemDes;
                        gImpFOCHeader."Starting Date" := ConvertTextToDate(gStartingDate);
                        gImpFOCHeader."Ending Date" := ConvertTextToDate(gEndingDate);
                        if gIsActive = 'Yes' then
                            gImpFOCHeader."Is Active" := true
                        else
                            gImpFOCHeader."Is Active" := false;

                        //Evaluate(SrpPrice, gSRPPrice);
                        //gImpFOCHeader.Validate("SRP Price", SrpPrice);
                        //Evaluate(PromotionPirce, gPromotionPrice);
                        //gImpFOCHeader.Validate("Promotion Price", PromotionPirce);
                        gImpFOCHeader."Activated Date" := ConvertTextToDate(gActivedDate);
                        gImpFOCHeader."Activated By" := gActiviatedBy;
                        gImpFOCHeader.Insert();
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
            EVALUATE(lday, COPYSTR(Txt, 1, 2));
            EVALUATE(lmonth, COPYSTR(Txt, 4, 2));
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

}
