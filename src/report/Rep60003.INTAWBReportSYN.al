report 60003 "INT_AWB_Report_SYN"
{
    RDLCLayout = './ReportDesign/AWB_Report.rdl';
    Caption = 'AWB Report';
    UsageCategory = Administration;
    ApplicationArea = All;

    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            column(companyinforname; companyinfor.Name) { }
            column(companyinforname2; companyinfor."Name 2") { }
            column(companyinforaddress; companyinfor.Address) { }
            column(companyinforaddress2; companyinfor."Address 2") { }
            column(companyinforcity; companyinfor.City) { }
            column(companyinforCounty; companyinfor.County) { }
            column(companyinforpostcode; companyinfor."Post Code") { }
            column(companyinforPhoneNo; companyinfor."Phone No.") { }
            column(Sell_to_Customer_Name; "Sell-to Customer Name") { }
            column(Sell_to_Address; "Sell-to Address") { }
            column(Sell_to_Address_2; "Sell-to Address 2") { }
            column(Sell_to_City; "Sell-to City") { }
            column(Sell_to_County; "Sell-to County") { }
            column(Sell_to_Post_Code; "Sell-to Post Code") { }
            column(Sell_to_Contact; "Sell-to Contact") { }
            column(Sell_to_Phone_No_; "Sell-to Phone No.") { }
            column(External_Document_No_; "External Document No.") { }
            column(Posting_Date; "Posting Date") { }
            dataitem(SalesLine; "Sales Line")
            {
                column(No_; "No.") { }
                column(Description; Description) { }
                column(Quantity; Quantity) { }
                column(Unit_of_Measure; "Unit of Measure") { }

            }
            trigger OnAfterGetRecord()
            var

            begin
                companyinfor.get;
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
                    //field(Name; SourceExpression)
                    //{
                    //    ApplicationArea = All;

                    //}
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
        companyinfor: Record "Company Information";
}