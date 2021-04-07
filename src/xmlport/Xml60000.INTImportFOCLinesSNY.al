xmlport 60000 "INT_ImportFOCLines_SNY"
{
    caption = 'Import FOC Lines';
    Format = VariableText;
    Direction = Import;
    FieldSeparator = ',';
    TextEncoding = UTF8;

    schema
    {
        textelement(Root)
        {
            tableelement(FOCLine; Integer)
            {
                SourceTableView = sorting(number);
                UseTemporary = false;
                AutoSave = false;
                AutoReplace = false;

                textelement(gType)
                {
                    MinOccurs = Zero;
                }
                textelement(gNo)
                {
                    MinOccurs = Zero;
                }
                textelement(gLinrNo)
                {
                    MinOccurs = Zero;
                }
                textelement(gItemNo)
                {
                }
                textelement(gItemDes)
                {
                }
                textelement(gUOM)
                {
                }
                textelement(gQty)
                { }
                textelement(gSRP_Price)
                {
                }
                textelement(gPromotion_Price)
                {
                }
                textelement(gCurrency)
                {
                }
                textelement(gPlant)
                {
                }
                textelement(gStoreLocation)
                {
                }
                textelement(gFreeGiftID)
                {
                }
                textelement(gRelatedItemNo)
                {
                }
                textelement(gEplodFOCItem)
                {
                }

                trigger OnBeforeInsertRecord()
                var
                    myInt: Integer;
                begin
                    EntryNo += 1;

                end;

                trigger OnAfterInsertRecord()
                var
                    myInt: Integer;
                begin
                    if Entryno > 1 then begin
                        //lineNo += 10000;
                        gImpFOCLine.init;
                        gImpFOCLine.type := gImpFOCLine.type::FOC;
                        gImpFOCLine."No." := gNo;
                        Evaluate(lineNo, gLinrNo);
                        gImpFOCLine."Line No." := lineNo;
                        gImpFOCLine.Validate("Item No.", gItemNo);
                        gImpFOCLine."Item Description" := gItemDes;
                        gImpFOCLine.Validate(UOM, gUOM);
                        Evaluate(qty, gQty);
                        gImpFOCLine.Validate(Quantity, qty);
                        Evaluate(SrpPrice, gSRP_Price);
                        gImpFOCLine.Validate("SRP Price", SrpPrice);
                        Evaluate(promotionprice, gPromotion_Price);
                        gImpFOCLine.validate("Promotional Price", promotionprice);
                        gImpFOCLine.Validate(Currency, gCurrency);
                        gImpFOCLine.Plant := gPlant;
                        gImpFOCLine."Storage Location" := gStoreLocation;
                        gImpFOCLine."Free Gift ID" := gFreeGiftID;
                        if gRelatedItemNo <> '' then
                            gImpFOCLine.Validate("Related Item No.", gRelatedItemNo);
                        if gEplodFOCItem = 'Yes' then
                            gImpFOCLine."Explode FOC Item" := true
                        else
                            gImpFOCLine."Explode FOC Item" := false;
                        gImpFOCLine.Insert();
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
        Entryno := 0;
    end;

    trigger OnPostXmlPort()
    var
        myInt: Integer;
    begin
        Message('FOC Import Line Completed');
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
        Entryno: Integer;
        gIsFirstRow: Boolean;
        gImpFOCLine: Record INT_BundleLine_SNY;
        lineNo: Integer;
        qty: Decimal;
        SrpPrice: Decimal;
        promotionprice: Decimal;

}
