report 60003 "INT_AWB_Report_SYN"
{
    RDLCLayout = './ReportDesign/AWB_Report.rdl';
    Caption = 'AWB Report';
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    PreviewMode = PrintLayout;

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
            column(Sell_to_Customer_No_; "Sell-to Customer No.") { }
            column(Sell_to_Customer_Name; "Sell-to Customer Name") { }
            column(Sell_to_Address; "Sell-to Address") { }
            column(Sell_to_Address_2; "Sell-to Address 2") { }
            column(Sell_to_City; "Sell-to City") { }
            column(Sell_to_County; "Sell-to County") { }
            column(Sell_to_Post_Code; "Sell-to Post Code") { }
            column(Sell_to_Contact; "Sell-to Contact") { }
            column(Sell_to_Phone_No_; "Sell-to Phone No.") { }
            column(shipName; shipName) { }
            column(shipaddress; shipadd1) { }
            column(shipaddress2; shipadd2) { }
            column(shipCity; shipcity) { }
            column(shipCountry; shipCountry) { }
            column(ShipPostcode; shippostcode) { }
            column(shipCounty; shipCounty) { }
            column(shipPhoneNo; shipPhoneNo) { }
            column(shipContact; shipContact) { }
            column(External_Document_No_; "External Document No.") { }
            column(Posting_Date; "Posting Date") { }
            column(BarCodePicture; BarCode.Picture) { }
            dataitem(SalesLine; "Sales Line")
            {
                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                DataItemLinkReference = SalesHeader;
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") where(Type = const(Item));

                column(No_; "No.") { }
                column(Description; Description) { }
                column(Quantity; Quantity) { }
                column(Unit_of_Measure; "Unit of Measure") { }
                column(lineNo; lineNo) { }
                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    if SalesLine."No." <> '' then
                        lineNo += 1;
                end;
            }
            trigger OnPostDataItem()
            var
                myInt: Integer;
            begin
                BarCode.Reset();
                BarCode.SetFilter(Value, '<>%1', '');
                if BarCode.Find('-') then begin
                    BarCode.Delete()
                end;
            end;

            trigger OnAfterGetRecord()
            var

            begin




                companyinfor.get;
                if not Customer.get("Sell-to Customer No.") then
                    Customer.init;

                BarCode.reset;
                BarCode.SetRange("INT_Ref_NO.SNY", "No.");
                if BarCode.find('-') then begin
                    BarCode."INT_Ref_NO.SNY" := "No.";
                    BarCode.Value := "External Document No.";
                    BarCode.Type := BarCode.Type::c128a;
                    BarCode.Width := 250;
                    BarCode.Height := 100;
                    BarCode.Modify();
                    Commit();
                    GenerateBarcodeCode.GenerateBarcode(BarCode);
                    //Message('%1', BarCode."INT_Ref_NO.SNY");
                end else begin
                    BarCode.PrimaryKey := CreateGuid();
                    BarCode."INT_Ref_NO.SNY" := "No.";
                    BarCode.Value := "External Document No.";
                    BarCode.Type := BarCode.Type::c128a;
                    BarCode.Width := 250;
                    BarCode.Height := 100;
                    BarCode.Insert();
                    Commit();
                    GenerateBarcodeCode.GenerateBarcode(BarCode);
                    //Message('%1', BarCode."INT_Ref_NO.SNY");
                end;


                shipName := "Sell-to Customer Name" + "Sell-to Customer Name 2";
                shipadd1 := "Bill-to Address";
                shipadd2 := "bill-to Address 2";
                shipcity := "bill-to City";
                shipCountry := "bill-to County";
                shipCounty := "Bill-to Country/Region Code";
                shippostcode := "bill-to Post Code";
                shipPhoneNo := "Sell-to Phone No.";
                shipContact := "Bill-to Contact";
                //end;
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
        BarCode: Record "INT_Barcode_SNY";
        GenerateBarcodeCode: Codeunit INT_GenerateBarcode_SNY;
        Customer: Record Customer;
        lineNo: Integer;
        shipName: text[100];
        shipadd1: text[100];
        shipadd2: text[100];
        shipcity: text[100];
        shipCountry: Text[100];
        shipCounty: text[100];
        shippostcode: text[100];
        shipPhoneNo: Text[100];
        shipContact: text[100];
}