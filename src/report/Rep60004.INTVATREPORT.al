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
            column(LineNo; LineNo) { }
            column(companyinforName; companyinfor.Name) { }
            column(companyinforName2; companyinfor."Name 2") { }
            column(companyinforAddress; companyinfor.Address) { }
            column(companyinforAddress2; companyinfor."Address 2") { }
            column(companyinforCity; companyinfor.City) { }
            column(companyinforCounty; companyinfor.County) { }
            column(companyinforPostCode; companyinfor."Post Code") { }
            column(companyinforVatNo; companyinfor."VAT Registration No.") { }


            trigger OnPostDataItem()
            var
                myInt: Integer;
            begin
                LineNo := 0;
                companyinfor.get;
            end;

            trigger OnAfterGetRecord()

            begin
                if SalesINV.get("Document No.") then begin
                    if paymentmethod.get(SalesINV."Payment Method Code") then begin
                        VatDescription := paymentmethod.Description + ' ' + Description;
                    end;
                end;
                if "No." <> '' then
                    LineNo += 1;
            end;
        }
        dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
        {
            column(CR_No_; "No.") { }
            column(VatDescription2; VatDescription2) { }
            column(CR_Document_No_; "Document No.") { }
            column(CR_Posting_Date; "Posting Date") { }
            column(CR_VAT_Amount; ABS("Amount Including VAT" - Amount)) { }
            column(CR_Amount_Including_VAT; "Amount Including VAT") { }

            trigger OnAfterGetRecord()

            begin
                if SalesCr.get("Document No.") then begin
                    if paymentmethod.get(SalesCr."Payment Method Code") then begin
                        VatDescription2 := paymentmethod.Description + ' ' + Description;
                    end;

                end;
                if "No." <> '' then
                    LineNo += 1;
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

                    }
                    field(Enddate; Enddate)
                    {
                        ApplicationArea = all;
                        Caption = 'End Date';
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
}