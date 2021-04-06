xmlport 60000 "INT_ImportFOCLines_SNY"
{
    caption = 'Import FOC Lines';
    Format = VariableText;
    FieldSeparator = ',';
    TextEncoding = UTF8;

    schema
    {
        textelement(RootNodeName)
        {
            tableelement(ImpFOCLine; "Sales Header")
            {
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
                textelement(gBCustomerNo)
                {
                    MinOccurs = Zero;
                }
                textelement(gRelatedItemNo)
                {
                }
                textelement(gEplodFOCItem)
                {
                }

                trigger OnBeforeInsertRecord()
                begin
                    if gIsFirstRow then begin
                        gIsFirstRow := false;
                        currXMLport.Skip(); //To skip header line
                    end;
                    /*
                    ImpFOCLine."Entry No." := gEntNo;
                    ImpFOCLine.Marketplace := gMarkPlaceID;
                    ImpSalLine."Marketplace Order ID" := gMarkPlaceordID;
                    ImpSalLine."Marketplace Order Line ID" := gMarkPlaceLineID;
                    ImpSalLine."Sell-to Customer No." := gBCustomerNo;
                    ImpSalLine."Sell-to Customer Name" := gBCustomerName;
                    ImpSalLine."Sell-to Contact" := gBContact;
                    ImpSalLine."Sell-to Address" := gBCustomerAddr;
                    ImpSalLine."Sell-to Address 2" := gBCustomerAddr2;
                    ImpSalLine."Sell-to City" := gBillToCity;
                    ImpSalLine."Sell-to Post Code" := gBillToPostCode;
                    ImpSalLine."Sell-to Country/Region Code" := gBCountry;
                    ImpSalLine."Your Reference" := gYourRef;
                    ImpSalLine."order Date" := ConvertTextToDate(gOrdDate);
                    ImpSalLine."location code" := gLocCode;
                    ImpSalLine."Requested Delivery Date" := ConvertTextToDate(gReqDelDate);
                    ImpSalLine.MarketOrdStatus := gMktOrdStatus;
                    ImpSalLine."SAP Order ID" := gSAPOrderId;
                    ImpSalLine."Remark 1" := gRemark1;
                    impsalLine."Remark 2" := gRemark2;
                    impsalLine."Remark 3" := gRemark3;
                    ImpSalLine."Seller ID" := gSellId;
                    ImpSalLine."Item No." := gItemNo;
                    ImpSalLine."Seller SKU" := gSellSku;
                    if gqty <> '' then
                        evaluate(ImpSalLine."Qty.", gQty);
                    if gUnitPrice <> '' then
                        evaluate(ImpSalLine."Unit Price", gUnitPrice);
                    if gDelFee <> '' then
                        evaluate(ImpSalLine."Delivery Fee", gDelFee);
                    ImpSalLine."MarketPlace Sync Status" := true;
                    ImpSalLine."Imported By" := UserId;
                    ImpSalLine."Imported On" := CurrentDateTime;
                    ImpSalLine."Imported File Name" := Filename;
                    gEntNo += 1;
                    */
                end;
            }
        }
    }
    trigger OnPreXmlPort()
    begin
        gIsFirstRow := true;
        gImpSalLine.Reset();
        if gImpSalLine.FindLast() then
            gEntNo := gImpSalLine."Entry No." + 1
        else
            gEntNo := 1;
        gImpSalLine.SetRange("Imported By", UserId);
        gImpSalLine.DeleteAll(true);
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
        gIsFirstRow: Boolean;
        gImpSalLine: Record INT_ImportSalesLine_SNY;
}
