report 60004 "INT_VAT_REPORT"
{
    RDLCLayout = './ReportDesign/VAT_REPORT.rdl';
    Caption = 'Vat Report';
    UsageCategory = Administration;
    ApplicationArea = All;

    dataset
    {
        dataitem(Integer; integer)
        {
            DataItemTableView = sorting(number) where(number = filter(1));


            dataitem("Sales Invoice Line"; "Sales Invoice Line")
            {
                DataItemTableView = sorting("Posting Date");

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
                        if not paymentmethod.get(SalesINV."Payment Method Code") then
                            paymentmethod.init;

                    end;

                    if "Sales Invoice Line"."Document No." <> '' then begin
                        lineno += 1;
                        //temp insert
                        //tempsalesline.init;
                        tempsalesline."Document Type" := tempsalesline."Document Type"::Invoice;
                        tempsalesline."Document No." := "Document No.";
                        tempsalesline."Line No." := "Line No.";
                        tempsalesline.Type := type;
                        tempsalesline."No." := "No.";
                        tempsalesline.Description := paymentmethod.Description;
                        if Description <> '' then
                            tempsalesline."Description 2" := Description
                        else begin
                            if not item.get("No.") then
                                item.init;
                            tempsalesline."Description 2" := item.Description;
                        end;
                        tempsalesline.Amount := Amount;
                        tempsalesline."Amount Including VAT" := "Amount Including VAT";
                        tempsalesline."VAT Base Amount" := "Amount Including VAT" - Amount;
                        CalcFields("Posting Date");
                        tempsalesline."Shipment Date" := "Posting Date";
                        tempsalesline.Insert();
                        //temp insert

                        //Message('%1 %2 %3', totalamountEx, totalAmtVat, TotalAmtIncVat);
                    end;

                    if companyinfor."VAT Registration No." <> '' then begin
                        VatID[1] := CopyStr(Format(companyinfor."VAT Registration No."), 1, 1);
                        VatID[2] := CopyStr(Format(companyinfor."VAT Registration No."), 2, 1);
                        VatID[3] := CopyStr(Format(companyinfor."VAT Registration No."), 3, 1);
                        VatID[4] := CopyStr(Format(companyinfor."VAT Registration No."), 4, 1);
                        VatID[5] := CopyStr(Format(companyinfor."VAT Registration No."), 5, 1);
                        VatID[6] := CopyStr(Format(companyinfor."VAT Registration No."), 6, 1);
                        VatID[7] := CopyStr(Format(companyinfor."VAT Registration No."), 7, 1);
                        VatID[8] := CopyStr(Format(companyinfor."VAT Registration No."), 8, 1);
                        VatID[9] := CopyStr(Format(companyinfor."VAT Registration No."), 9, 1);
                        VatID[10] := CopyStr(Format(companyinfor."VAT Registration No."), 10, 1);
                        VatID[11] := CopyStr(Format(companyinfor."VAT Registration No."), 11, 1);
                        VatID[12] := CopyStr(Format(companyinfor."VAT Registration No."), 12, 1);
                        VatID[13] := CopyStr(Format(companyinfor."VAT Registration No."), 13, 1);
                    end;


                end;
            }
            dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
            {
                DataItemTableView = sorting("Posting Date");

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
                        if not paymentmethod.get(SalesCr."Payment Method Code") then
                            paymentmethod.init;

                    end;
                    if "Sales Cr.Memo Line"."Document No." <> '' then begin
                        lineno += 1;
                        //temp insert
                        //tempsalesline.init;
                        tempsalesline."Document Type" := tempsalesline."Document Type"::"Credit Memo";
                        tempsalesline."Document No." := "Document No.";

                        tempsalesline."Line No." := "Line No.";
                        tempsalesline.Type := type;
                        tempsalesline."No." := "No.";
                        tempsalesline.Description := paymentmethod.Description;
                        if Description <> '' then
                            tempsalesline."Description 2" := Description
                        else begin
                            if not item.get("No.") then
                                item.init;
                            tempsalesline."Description 2" := item.Description;
                        end;
                        tempsalesline.Amount := Amount * -1;
                        tempsalesline."Amount Including VAT" := "Amount Including VAT" * -1;
                        tempsalesline."VAT Base Amount" := ("Amount Including VAT" - Amount) * -1;
                        CalcFields("Posting Date");
                        tempsalesline."Shipment Date" := "Posting Date";
                        tempsalesline.Insert();
                        //temp insert
                    end;

                end;
            }
            trigger OnPreDataItem()
            var
            begin
                companyinfor.get;
                if companyinfor."VAT Registration No." <> '' then begin
                    VatID[1] := CopyStr(Format(companyinfor."VAT Registration No."), 1, 1);
                    VatID[2] := CopyStr(Format(companyinfor."VAT Registration No."), 2, 1);
                    VatID[3] := CopyStr(Format(companyinfor."VAT Registration No."), 3, 1);
                    VatID[4] := CopyStr(Format(companyinfor."VAT Registration No."), 4, 1);
                    VatID[5] := CopyStr(Format(companyinfor."VAT Registration No."), 5, 1);
                    VatID[6] := CopyStr(Format(companyinfor."VAT Registration No."), 6, 1);
                    VatID[7] := CopyStr(Format(companyinfor."VAT Registration No."), 7, 1);
                    VatID[8] := CopyStr(Format(companyinfor."VAT Registration No."), 8, 1);
                    VatID[9] := CopyStr(Format(companyinfor."VAT Registration No."), 9, 1);
                    VatID[10] := CopyStr(Format(companyinfor."VAT Registration No."), 10, 1);
                    VatID[11] := CopyStr(Format(companyinfor."VAT Registration No."), 11, 1);
                    VatID[12] := CopyStr(Format(companyinfor."VAT Registration No."), 12, 1);
                    VatID[13] := CopyStr(Format(companyinfor."VAT Registration No."), 13, 1);
                end;
            end;

            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin

            end;
        }
        dataitem(tempsalesline; "Sales Line")
        {
            DataItemTableView = sorting("shipment Date");
            UseTemporary = true;

            column(companyinforName; companyinfor.Name) { }
            column(companyinforNameTH; companyinfor.INT_Name_TH_SNY) { }
            column(companyinforName2; companyinfor."Name 2") { }
            column(companyinforAddress; companyinfor.Address) { }
            column(companyinforAddress2; companyinfor."Address 2") { }
            column(companyinforCity; companyinfor.City) { }
            column(companyinforCounty; companyinfor.County) { }
            column(companyinforPostCode; companyinfor."Post Code") { }
            column(companyinforVatNo; companyinfor."VAT Registration No.") { }
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
            column(Enddate; Enddate) { }
            column(DocumentNo; tempsalesline."Document No.") { }
            column(PostingDate; tempsalesline."Shipment Date") { }
            column(Des; tempsalesline.Description) { }
            column(Des2; tempsalesline."Description 2") { }
            column(Amount; tempsalesline.Amount) { }
            column(VatAmount; tempsalesline."VAT Base Amount") { }
            column(AmountIncVat; tempsalesline."Amount Including VAT") { }

            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin
                //Message('%1', tempsalesline."Posting Date");
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
        if CustomerNO = '' then
            Error('Please Select Marketplace !');

        if (startDate = 0D) or (Enddate = 0D) then
            Error('Plase Filter Date !');


    end;

    var
        SalesINV: Record "Sales Invoice Header";
        SalesCr: Record "Sales Cr.Memo Header";
        paymentmethod: Record "Payment Method";
        startDate: date;
        Enddate: date;
        companyinfor: Record "Company Information";
        CustomerNO: Code[20];
        VatID: array[13] of text[20];
        customer: Record Customer;
        item: Record item;
        //tempsalesline: Record "Sales Line" temporary;
        lineno: Integer;
}