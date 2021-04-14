report 60004 "INT_VAT_REPORT"
{
    RDLCLayout = './ReportDesign/VAT_REPORT.rdl';
    Caption = 'Vat Report';
    UsageCategory = Administration;
    ApplicationArea = All;

    dataset
    {
        dataitem("Sales Invoice Line"; "Sales Invoice Line")
        {
            column(INV_No_; "No.") { }
            column(INV_Document_No_; "Document No.") { }
            column(INV_Posting_Date; "Posting Date") { }
            column(VatDescription; VatDescription) { }
            column(INV_VAT_Amount; abs("Amount Including VAT" - Amount)) { }
            column(INV_Amount_Including_VAT; "Amount Including VAT") { }
            column(INV_Amount; Amount) { }
            column(LineNo; LineNo) { }
            column(companyinforName; companyinfor.Name) { }
            column(companyinforName2; companyinfor."Name 2") { }
            column(companyinforAddress; companyinfor.Address) { }
            column(companyinforAddress2; companyinfor."Address 2") { }
            column(companyinforCity; companyinfor.City) { }
            column(companyinforCounty; companyinfor.County) { }
            column(companyinforPostCode; companyinfor."Post Code") { }
            column(companyinforVatNo; companyinfor."VAT Registration No.") { }
            column(Enddate; Enddate) { }
            column(totalamountEx; totalamountEx) { }
            column(totalAmtVat; totalAmtVat) { }
            column(TotalAmtIncVat; TotalAmtIncVat) { }
            column(CustomerNO; CustomerNO) { }
            column(VatID1; VatID[1]) { }
            column(VatID2; VatID[2]) { }
            column(VatID3; VatID[3]) { }
            column(VatID4; VatID[4]) { }
            column(VatID5; VatID[5]) { }
            column(VatID6; VatID[6]) { }
            column(VatID7; VatID[7]) { }
            column(VatID8; VatID[8]) { }
            column(VatID9; VatID[9]) { }
            column(VatID10; VatID[10]) { }
            column(VatID11; VatID[11]) { }
            column(VatID12; VatID[12]) { }
            column(VatID13; VatID[13]) { }

            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin
                //"Sales Invoice Line".SetFilter(INT_ma);
                SetFilter("Bill-to Customer No.", CustomerNO);
                SetFilter("Posting Date", '%1..%2', startDate, Enddate);

            end;

            trigger OnAfterGetRecord()

            begin
                //if "Sell-to Customer No." <> CustomerNO then
                //    CurrReport.Skip();
                if SalesINV.get("Document No.") then begin
                    if paymentmethod.get(SalesINV."Payment Method Code") then begin
                        VatDescription := paymentmethod.Description + ' ' + Description;
                    end;
                end;

                if "Document No." <> '' then begin
                    LineNo += 1;
                    totalamountEx += "Sales Invoice Line".Amount;
                    totalAmtVat += ("Sales Invoice Line"."Amount Including VAT" - "Sales Invoice Line".Amount);
                    TotalAmtIncVat += "Sales Invoice Line"."Amount Including VAT";
                end;

                customer.reset;
                customer.SetRange("No.", CustomerNO);
                if customer.Find('-') then begin
                    VatID[1] := CopyStr(Format(customer."VAT Registration No."), 1, 1);
                    VatID[2] := CopyStr(Format(customer."VAT Registration No."), 2, 1);
                    VatID[3] := CopyStr(Format(customer."VAT Registration No."), 3, 1);
                    VatID[4] := CopyStr(Format(customer."VAT Registration No."), 4, 1);
                    VatID[5] := CopyStr(Format(customer."VAT Registration No."), 5, 1);
                    VatID[6] := CopyStr(Format(customer."VAT Registration No."), 6, 1);
                    VatID[7] := CopyStr(Format(customer."VAT Registration No."), 7, 1);
                    VatID[8] := CopyStr(Format(customer."VAT Registration No."), 8, 1);
                    VatID[9] := CopyStr(Format(customer."VAT Registration No."), 9, 1);
                    VatID[10] := CopyStr(Format(customer."VAT Registration No."), 10, 1);
                    VatID[11] := CopyStr(Format(customer."VAT Registration No."), 11, 1);
                    VatID[12] := CopyStr(Format(customer."VAT Registration No."), 12, 1);
                    VatID[13] := CopyStr(Format(customer."VAT Registration No."), 13, 1);

                end;


            end;
        }
        dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
        {
            column(CR_No_; "No.") { }
            column(VatDescription2; VatDescription2) { }
            column(CR_Document_No_; "Document No.") { }
            column(CR_Posting_Date; "Posting Date") { }
            column(CR_VAT_Amount; ABS("Amount Including VAT" - Amount) * -1) { }
            column(CR_Amount_Including_VAT; "Amount Including VAT" * -1) { }
            column(CR_Amount; Amount * -1) { }

            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin
                SetFilter("Bill-to Customer No.", CustomerNO);
                SetFilter("Posting Date", '%1..%2', startDate, Enddate);
            end;

            trigger OnAfterGetRecord()

            begin
                //if "Sell-to Customer No." <> CustomerNO then
                //    CurrReport.Skip();

                if SalesCr.get("Document No.") then begin
                    if paymentmethod.get(SalesCr."Payment Method Code") then begin
                        VatDescription2 := paymentmethod.Description + ' ' + Description;
                    end;

                end;
                if "Document No." <> '' then begin
                    LineNo += 1;
                    totalamountEx -= "Sales Cr.Memo Line".Amount;
                    totalAmtVat -= ("Sales Cr.Memo Line"."Amount Including VAT" - "Sales Cr.Memo Line".Amount);
                    TotalAmtIncVat -= "Sales Cr.Memo Line"."Amount Including VAT";
                end;

            end;
        }

    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'Filter Vat Date';
                    field(startDate; startDate)
                    {
                        Caption = 'Start Date';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field(Enddate; Enddate)
                    {
                        ApplicationArea = all;
                        Caption = 'End Date';
                        ShowMandatory = true;
                    }
                    field(CustomerNO; CustomerNO)
                    {
                        ApplicationArea = all;
                        Caption = 'Market Place';
                        TableRelation = Customer."No.";
                        ShowMandatory = true;
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }

    }

    trigger OnPreReport()
    var
        myInt: Integer;
    begin
        companyinfor.get;
        LineNo := 0;
        companyinfor.get;
        if CustomerNO = '' then
            Error('Please Select Marketplace !');

        if (startDate = 0D) or (Enddate = 0D) then
            Error('Plase Filter Date !');

        totalamountEx := 0;
        totalAmtVat := 0;
        TotalAmtIncVat := 0;

    end;

    var
        SalesINV: Record "Sales Invoice Header";
        SalesCr: Record "Sales Cr.Memo Header";
        paymentmethod: Record "Payment Method";
        VatDescription: Text[100];
        VatDescription2: Text[100];
        LineNo: Integer;
        startDate: date;
        Enddate: date;
        companyinfor: Record "Company Information";
        totalamountEx: Decimal;
        totalAmtVat: Decimal;
        TotalAmtIncVat: Decimal;
        CustomerNO: Code[20];
        VatID: array[13] of text[20];
        customer: Record Customer;
}