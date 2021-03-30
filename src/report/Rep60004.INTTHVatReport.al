report 60004 "INT_TH_VatReport"
{

    RDLCLayout = './ReportDesign/Var_report.rdl';
    Caption = 'Var Report';
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("VAT Entry"; "VAT Entry")
        {
            DataItemTableView = SORTING("Entry No.") where(Type = const(Sale), Base = filter(<> 0));
            column(companyinfoName; companyinfo.Name) { }
            column(companyinfoAdd1; companyinfo.Address) { }
            column(companyinfo; companyinfo."Address 2") { }
            column(Posting_Date; "Posting Date") { }
            column(Document_No_; "Document No.") { }
            column(CustName; Cust.Name) { }
            //column(Branch)
            column(Amount; Amount) { }
            column(Base; Base) { }
            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin
                if SalesHeader.get("Document Type", "Document No.") then begin
                    if not Cust.get(SalesHeader."Bill-to Customer No.") then
                        cust.init;
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
                    field("Vat Date"; Datefilter)
                    {
                        ApplicationArea = All;

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


    var
        Cust: Record Customer;
        companyinfo: Record "Company Information";
        Datefilter: Date;
        SalesHeader: Record "Sales Header";
}