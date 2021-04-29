codeunit 60000 "INT_Even_Sub_SNY"
{
    /*
     [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterUpdateAmounts', '', true, true)]
     local procedure "Sales Line_OnAfterUpdateAmounts"
     (
         var SalesLine: Record "Sales Line";
         var xSalesLine: Record "Sales Line";
         CurrentFieldNo: Integer
     )
     var
         SalesHeader: Record "Sales Header";
         Currency: Record Currency;
         item: Record Item;
     begin

         //SOTHAI
         if SalesHeader.get(SalesLine."Document Type", SalesLine."Document No.") then begin
             IF SalesHeader."Currency Code" = '' THEN
                 Currency.InitRoundingPrecision
             ELSE BEGIN
                 SalesHeader.TESTFIELD("Currency Factor");
                 Currency.GET(SalesHeader."Currency Code");
                 Currency.TESTFIELD("Amount Rounding Precision");
             END;
         end;
         //SOTHAI
         if item.get(SalesLine."No.") then begin
             if item."TH Exclude Discount" then begin
                 IF SalesLine."Line Amount" <> ROUND(SalesLine.Quantity * SalesLine."Unit Price", Currency."Amount Rounding Precision") THEN BEGIN
                     SalesLine."Line Amount" := ROUND(SalesLine.Quantity * SalesLine."Unit Price", Currency."Amount Rounding Precision");
                     SalesLine."VAT Difference" := 0;
                 END;
             end
         end

     end;
 */
    procedure FormatNoThaiText(Amount: Decimal): Text[200]
    var
        AmountText: text[30];
        X: Integer;
        l: Integer;
        P: Integer;
        adigit: Text[1];
        dflag: Boolean;
        WHTAmtThaiText: Text[300];
    begin
        IF Amount = 0 THEN
            EXIT('ศูนย์บาท');

        AmountText := FORMAT(Amount, 0);
        x := STRPOS(AmountText, '.');
        CASE TRUE OF
            x = 0:
                AmountText := AmountText + '.00';
            x = STRLEN(AmountText) - 1:
                AmountText := AmountText + '0';
            x > STRLEN(AmountText) - 2:
                AmountText := COPYSTR(AmountText, 1, x + 2);
        END;
        l := STRLEN(AmountText);
        REPEAT
            dflag := FALSE;
            p := STRLEN(AmountText) - l + 1;
            adigit := COPYSTR(AmountText, p, 1);
            IF (l IN [4, 12, 20]) AND (l < STRLEN(AmountText)) AND (adigit = '1') THEN
                dflag := TRUE;
            WHTAmtThaiText := WHTAmtThaiText + FormatDigitThai(adigit, l - 3, dflag);
            l := l - 1;
        UNTIL l = 3;

        IF COPYSTR(AmountText, STRLEN(AmountText) - 2, 3) = '.00' THEN
            WHTAmtThaiText := WHTAmtThaiText + 'บาทถ้วน'
        ELSE BEGIN
            IF WHTAmtThaiText <> '' THEN
                WHTAmtThaiText := WHTAmtThaiText + 'บาท';
            l := 2;
            REPEAT
                dflag := FALSE;
                p := STRLEN(AmountText) - l + 1;
                adigit := COPYSTR(AmountText, p, 1);
                IF (l = 1) AND (adigit = '1') AND (COPYSTR(AmountText, p - 1, 1) <> '0') THEN
                    dflag := TRUE;
                WHTAmtThaiText := WHTAmtThaiText + FormatDigitThai(adigit, l, dflag);
                l := l - 1;
            UNTIL l = 0;
            WHTAmtThaiText := WHTAmtThaiText + 'สตางค์';
        END;
        exit(WHTAmtThaiText);
    end;

    procedure FormatDigitThai(adigit: Text[1]; pos: Integer; dflag: Boolean): Text[100]
    var
        myInt: Integer;
        fdigit: Text[30];
        fcount: text[30];
    begin
        CASE adigit OF
            '1':
                BEGIN
                    IF (pos IN [1, 9, 17]) AND dflag THEN
                        fdigit := 'เอ็ด'
                    ELSE
                        IF pos IN [2, 10, 18] THEN
                            fdigit := ''
                        ELSE
                            fdigit := 'หนึ่ง';
                END;
            '2':
                BEGIN
                    IF pos IN [2, 10, 18] THEN
                        fdigit := 'ยี่'
                    ELSE
                        fdigit := 'สอง';
                END;
            '3':
                fdigit := 'สาม';
            '4':
                fdigit := 'สี่';
            '5':
                fdigit := 'ห้า';
            '6':
                fdigit := 'หก';
            '7':
                fdigit := 'เจ็ด';
            '8':
                fdigit := 'แปด';
            '9':
                fdigit := 'เก้า';
            '0':
                BEGIN
                    IF pos IN [9, 17, 25] THEN
                        fdigit := 'ล้าน';
                END;
            '-':
                fdigit := 'ลบ';
        END;
        IF (adigit <> '0') AND (adigit <> '-') THEN BEGIN
            CASE pos OF
                2, 10, 18:
                    fcount := 'สิบ';
                3, 11, 19:
                    fcount := 'ร้อย';
                5, 13, 21:
                    fcount := 'พัน';
                6, 14, 22:
                    fcount := 'หมื่น';
                7, 15, 23:
                    fcount := 'แสน';
                9, 17, 25:
                    fcount := 'ล้าน';
            END;
        END;
        EXIT(fdigit + fcount);
    end;

    procedure PrintDocument(Var SalesHeader: Record "Sales Header"; Var SalesLine: Record "Sales Line")
    var
        MenuStringLbl: Label 'Shipping Label';
        SelectedOption: Integer;
        Handled: Boolean;
        INT_EcomInterface_SNY: Codeunit INT_EcomInterface_SNY;
        SalesHeaderReport: Record "Sales Header";
    begin
        case SalesHeader.INT_MarketPlace_SNY of
            'LAZADA':
                begin
                    //SelectedOption := StrMenu(MenuStringLbl, 0);
                    //if SelectedOption > 0 then
                    //case SelectedOption of
                    //1:
                    //begin
                    if SalesHeader.INT_DeliveryType_SNY = SalesHeader.INT_DeliveryType_SNY::"DBS Home" then begin
                        SalesHeaderReport.reset;
                        SalesHeaderReport.SetRange("Document Type", SalesHeader."Document Type");
                        SalesHeaderReport.SetRange("No.", SalesHeader."No.");
                        if SalesHeaderReport.findfirst() then
                            Report.RunModal(60003, true, false, SalesHeaderReport);
                    end else
                        INT_EcomInterface_SNY.OnPrintDocument(SalesHeader, SalesLine, 'shippingLabel', Handled);
                    //end;
                    //2:
                    //    INT_EcomInterface_SNY.OnPrintDocument(SalesHeader, SalesLine, 'invoice', Handled);
                    //3:
                    //    INT_EcomInterface_SNY.OnPrintDocument(SalesHeader, SalesLine, 'carrierManifest', Handled);
                    //End;
                    //OnPrintDocument(SalesHeader, SalesLine, 'shippingLabel', Handled);
                end;
        /* 'SONY STORE ONLINE':
            begin
                Report.RunModal(70003, true, false, SalesHeader);
            end; */
        end;
    end;

    procedure PrintDocument(Var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.reset();
        SalesLine.setrange("Document Type", SalesHeader."Document Type");
        SalesLine.setrange("Document No.", SalesHeader."No.");
        SalesLine.FindSet();
        PrintDocument(SalesHeader, SalesLine);
    end;

    procedure PrintDocument(var SalesLine: Record "Sales Line"; DocumentCode: text[30])
    Var
        SalesHeader: Record "Sales Header";
        Handled: Boolean;
    begin
        SalesHeader.get(SalesLine."Document Type", SalesLine."Document No.");
        OnPrintDocument(SalesHeader, SalesLine, DocumentCode, Handled);
    end;

    [IntegrationEvent(true, false)]
    procedure OnPrintDocument(Var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; DocumentCode: text[30]; var Handled: Boolean)
    begin

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reporting Triggers", 'OnDocumentPrintReady', '', true, true)]
    local procedure "Reporting Triggers_OnDocumentPrintReady"
    (
        ObjectType: Option;
        ObjectId: Integer;
        ObjectPayload: JsonObject;
        DocumentStream: InStream;
        var Success: Boolean
    )
    begin


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ReportManagement", 'OnAfterDocumentPrintReady', '', true, true)]
    local procedure "ReportManagement_OnAfterDocumentPrintReady"
    (
        ObjectType: Option;
        ObjectID: Integer;
        ObjectPayload: JsonObject;
        DocumentStream: InStream;
        var Success: Boolean
    )
    var
        SalesHeaderReport: Record "Sales Header";
    begin

    end;

    var
        myInt: Integer;
}