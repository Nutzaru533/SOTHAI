codeunit 60000 "TH Even Sub"
{

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



    var
        myInt: Integer;
}