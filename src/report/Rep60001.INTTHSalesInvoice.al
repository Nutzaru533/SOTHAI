
report 60001 "INT_TH_Sales_Invoice"
{
    RDLCLayout = './ReportDesign/TH_Sales_Invoice.rdl';
    Caption = 'Sales Invoice TH';
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem(Header; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.") where("Document Type" = const(Order));
            RequestFilterFields = "Document Type", "No.";
            column(HeaderDocType; "Document Type")
            {
            }
            column(DocNo; "No.") { }
            column(MarketPlace; INT_MarketPlace_SNY) { }
            column(markeINT_Signature_SNY; marketplace.INT_Singatrue2_SNY) { }
            column(HeaderDocNo; "External Document No.")
            {
            }
            column(DocDate; "Order Date")
            {
            }
            column(ShiptoName; "Bill-to Name")
            {
            }
            column(ShiptoAddress; "Bill-to Address")
            {
            }
            column(ShiptoAddress2; "Bill-to Address 2")
            {
            }
            column(ShiptoCity; "Bill-to City")
            {
            }
            column(ShiptoPostCode; "Bill-to Post Code")
            {
            }
            column(ShiptoContact; "Bill-to Contact")
            {
            }
            column(shipPhoneNo; shipPhoneNo)
            {

            }
            column(Deliveryexist; Deliveryexist)
            {
            }
            column(ShopifyPaymentMethod; "Shopify Payment Method")
            {
            }
            column(CompName; CompanyInfo.Name)
            {
            }
            column(CompName2; CompanyInfo."Name 2")
            {
            }
            column(CompAddress; CompanyInfo.Address)
            {
            }
            column(CompAddress2; CompanyInfo."Address 2")
            {
            }
            column(PostCode; CompanyInfo."Post Code")
            {
            }
            column(PhoneNo; CompanyInfo."Phone No.")
            {
            }
            column(faxNo; CompanyInfo."Fax No.")
            {
            }
            column(CoRegNo; CompanyInfo."Co Reg. No.")
            {
            }
            column(VatRegNo; CompanyInfo."VAT Registration No.")
            {
            }
            column(Logo; CompanyInfo.Picture)
            {
            }
            column(Branch1; CompanyInfo.Branch1)
            { }
            column(Branch2; CompanyInfo.Branch2)
            { }
            column(Branch3; CompanyInfo.Branch3)
            { }
            column(Branch4; CompanyInfo.Branch4)
            { }
            column(Branch5; CompanyInfo.Branch5)
            { }
            column(Branch6; CompanyInfo.Branch6)
            { }
            column(BranchAddress1; CompanyInfo."Branch Address 1")
            { }
            column(BranchAddress2; CompanyInfo."Branch Address 2")
            { }
            column(BranchAddress3; CompanyInfo."Branch Address 3")
            { }
            column(BranchAddress4; CompanyInfo."Branch Address 4")
            { }
            column(BranchAddress5; CompanyInfo."Branch Address 5")
            { }
            column(BranchAddress6; CompanyInfo."Branch Address 6")
            { }
            column(BranchContact1; CompanyInfo."Branch Contact 1")
            { }
            column(BranchContact2; CompanyInfo."Branch Contact 2")
            { }
            column(BranchContact3; CompanyInfo."Branch Contact 3")
            { }
            column(BranchContact4; CompanyInfo."Branch Contact 4")
            { }
            column(BranchContact5; CompanyInfo."Branch Contact 5")
            { }
            column(BranchContact6; CompanyInfo."Branch Contact 6")
            { }
            column(Website; CompanyInfo.Website)
            { }
            column(Sell_to_Customer_Name; "Bill-to Name") { }
            column(Sell_to_Address; "Bill-to Address") { }
            column(Sell_to_Address_2; "bill-to Address 2") { }
            column(Sell_to_City; "bill-to City") { }
            column(Sell_to_County; "bill-to County") { }
            column(Sell_to_Post_Code; "bill-to Post Code") { }
            column(Sell_to_Phone_No_; contact."Phone No.") { }
            column(Branch; showBranch) { }
            column(Companybranch; Companybranch) { }
            column(shipName; shipName) { }
            column(shipadd1; shipadd1) { }
            column(shipadd2; shipadd2) { }
            column(shipcity; shipcity) { }
            column(shipCountry; shipCountry) { }
            column(shippostcode; shippostcode) { }

            column(VAT_Registration_No_; "VAT Registration No.") { }
            column(TotalSalesValue; TotalSalesValue)
            {
                DecimalPlaces = 2 : 2;
            }
            column(SalesbeforeGST; SalesbeforeGST)
            {
                DecimalPlaces = 2 : 2;

            }
            column(GSTValue; GSTValue)
            {
                DecimalPlaces = 2 : 2;
            }
            column(CustomerRemarks; "Fullfillment Remarks")
            { }
            column(TotalDiscountCode; TotalDiscountCode)
            { }
            column(TotalRebateAmount; TotalRebateAmount)
            { }
            column(DiscountExist; DiscountExist)
            { }
            column(DeliveryChargesExist; DeliveryChargesExist)
            { }
            column(TotalDeliveryCharges; TotalDeliveryCharges)
            { }
            column(texamtth; texamtth) { }

            dataitem(Line; "Sales Line")
            {
                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                DataItemLinkReference = Header;
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") where(Type = const(Item));

                column(LineNo; Line."Line No.")
                {
                }
                column(LineInfo;
                LineInfo)
                {
                }
                column(ItemNo; "No.")
                {
                }
                column(Description; Description)
                {
                }
                column(QtytoInvoice; RepQuantity)
                {
                }
                column(UnitPrice; UnitPrice)
                {
                }
                column(LineDiscountAmount; "Line Discount Amount")
                {
                }
                column(SubTotal; SubTotal)
                {
                }

                column(SerialNo; INT_SerialNo_SNY)
                {
                }
                column(SerialNoExist; SerialNoExist)
                {

                }
                column(DiscountCode; DiscountCode)
                {
                }
                column(FOCexist; FOCexist)
                {
                }
                column(LineDeliveryexist; LineDeliveryexist)
                {
                }
                column(LineDeliveryDate; LineDeliveryDate)
                {
                }
                column(LineDeliveryTime; LineDeliveryTime)
                {
                }



                trigger OnPreDataItem()
                var
                begin
                    SetFilter(INT_RelatedItemType_SNY, '<>%1&<>%2&<>%3', Line.INT_RelatedItemType_SNY::"FOC Dummy", Line.INT_RelatedItemType_SNY::Package, Line.INT_RelatedItemType_SNY::"Main Delivery");
                end;

                trigger OnAfterGetRecord()
                var
                    VirtualSalesLine: Record "Sales Line";
                    BundleHeader: Record INT_BundleHeader_SNY;
                    BundleLine: Record INT_BundleLine_SNY;
                    VirtualQty: Decimal;
                begin
                    Clear(LineInfo);
                    Clear(SKU);
                    Clear(Rebate);
                    Clear(VirtualQty);
                    Clear(RepQuantity);
                    FOCexist := false;
                    LineDeliveryexist := false;

                    if Type = Type::" " then
                        LineInfo := ''
                    else begin
                        LineNo := LineNo + 1;
                        LineInfo := STRSUBSTNO('%1.', LineNo);
                        Item.Get("No.");
                        SKU := Item.INT_SellerSKU_SNY;
                        UnitPrice := 0;
                        RepQuantity := "Qty. to Invoice";
                        if INT_SerialNo_SNY <> '' then
                            SerialNoExist := true
                        else
                            SerialNoExist := false;
                    end;

                    if INT_RelatedItemType_SNY = Line.INT_RelatedItemType_SNY::FOC then begin
                        SubTotal := 0;
                        UnitPrice := 0;
                        FOCexist := true
                    end else begin
                        if "INT_Rebate Amount_SNY" > 0 then
                            if Quantity > 0 then
                                UnitPrice := ("INT_Rebate Amount_SNY" / Quantity) + "Unit Price"
                            else begin
                            end
                        else
                            UnitPrice := "Unit Price";
                        if Header.Discount_Target = 'all' then
                            SubTotal := UnitPrice * Quantity
                        else
                            SubTotal := "Line Amount";
                    end;
                    if Deliveryexist = true then
                        if ("Location Code" = 'COMS') or ("Location Code" = 'MAIN') then begin
                            LineDeliveryexist := true;
                            LineDeliveryDate := Header."Requested Delivery Date";
                            LineDeliveryTime := Header.INT_Remarks1_SNY;
                        end;
                    if Header.Discount_Target = 'all' then begin
                        Rebate := 0;
                        DiscountCode := '';
                    end
                    else begin
                        Rebate := "INT_Rebate Amount_SNY";
                        DiscountCode := "INT_Discount Code_SNY";
                    end;

                    if INT_RelatedItemType_SNY = Line.INT_RelatedItemType_SNY::Virtual then begin
                        BundleHeader.SetRange("Item No.", "No.");
                        if BundleHeader.FindFirst() then begin
                            BundleLine.SetRange("No.", BundleHeader."No.");
                            BundleLine.SetRange("Item No.", INT_RelatedItemNo_SNY);
                            if BundleLine.FindFirst() then begin
                                VirtualSalesLine.Reset;
                                VirtualSalesLine.SetRange("Document Type", "Document Type");
                                VirtualSalesLine.SetRange("Document No.", "Document No.");
                                VirtualSalesLine.SetRange("No.", INT_RelatedItemNo_SNY);
                                if VirtualSalesLine.FindFirst() then
                                    VirtualQty := (VirtualSalesLine.Quantity / BundleLine.Quantity);
                            end;

                        end;
                        RepQuantity := VirtualQty;
                        UnitPrice := ("INT_Rebate Amount_SNY" / VirtualQty) + "Unit Price";
                        if Header.Discount_Target = 'all' then
                            SubTotal := UnitPrice * VirtualQty
                        else
                            SubTotal := (UnitPrice * VirtualQty) - "INT_Rebate Amount_SNY";
                    end;
                    if "No." <> '' then
                        countLine += 1;


                end;
            }
            dataitem(Integer; integer)
            {
                //DataItemTableView = where(number = filter(1));
                DataItemTableView = SORTING(Number);
                DataItemLinkReference = header;
                column(Number; number) { }
                trigger OnPreDataItem()
                var
                begin
                    //fixline := 13;
                    //countLine := fixline - LineNo;
                    //SetRange(Number, countLine);
                    IF countLine > 12 THEN
                        countLine := (27 - countLine)
                    ELSE
                        countLine := 12 - countLine;
                    SETRANGE(Number, 1, countLine);
                end;
            }
            trigger OnAfterGetRecord()
            var
                TotalSalesLine: Record "Sales Line";
            begin
                Clear(LineNo);
                Clear(countLine);
                Clear(SubTotal);
                Clear(Deliveryexist);
                Clear(TotalRebateAmount);
                Clear(TotalDeliveryCharges);
                DeliveryChargesExist := false;

                if "Requested Delivery Date" <> 0D then
                    Deliveryexist := true;
                TotalSalesValue := 0;
                SalesbeforeGST := 0;
                GSTValue := 0;
                TotalSalesLine.Reset();
                TotalSalesLine.SetRange("Document Type", Header."Document Type");
                TotalSalesLine.setrange("Document No.", Header."No.");
                if TotalSalesLine.FindFirst() then
                    TotalDiscountCode := TotalSalesLine."INT_Discount Code_SNY";

                TotalSalesLine.Reset();
                TotalSalesLine.SetRange("Document Type", Header."Document Type");
                TotalSalesLine.setrange("Document No.", Header."No.");
                if TotalSalesLine.FindSet() then
                    repeat
                        TotalSalesValue += (TotalSalesLine."Line Amount");
                        TotalRebateAmount += TotalSalesLine."INT_Rebate Amount_SNY";
                    //- TotalSalesLine."INT_Rebate Amount_SNY"
                    until TotalSalesLine.Next() = 0;
                TotalRebateAmount := Round(TotalRebateAmount, 0.01, '=');
                TotalSalesValue := Round(TotalSalesValue, 0.01, '=');
                SalesbeforeGST := Round((TotalSalesValue / 1.07), 0.01, '=');
                GSTValue := Round((TotalSalesValue - SalesbeforeGST), 0.01, '=');


                if Discount_Target = 'all' then
                    DiscountExist := true;

                TotalSalesLine.Reset();
                TotalSalesLine.SetRange("Document Type", Header."Document Type");
                TotalSalesLine.setrange("Document No.", Header."No.");
                TotalSalesLine.SetRange(INT_RelatedItemType_SNY, TotalSalesLine.INT_RelatedItemType_SNY::"Main Delivery");
                if TotalSalesLine.FindSet() then
                    repeat
                        DeliveryChargesExist := true;
                        TotalDeliveryCharges += TotalSalesLine."Line Amount";
                    until TotalSalesLine.Next() = 0;
                TotalDeliveryCharges := Round(TotalDeliveryCharges, 0.01, '=');

                /*
                if "Ship-to Name" <> '' then begin
                    shipName := "Ship-to Name";
                    shipadd1 := "Ship-to Address";
                    shipadd2 := "Ship-to Address 2";
                    shipcity := "Ship-to City";
                    shipCountry := "Ship-to County";
                    shippostcode := "Ship-to Post Code";
                end else begin
                    */
                shipName := "Sell-to Customer Name" + "Sell-to Customer Name 2";
                shipadd1 := "Sell-to Address";
                shipadd2 := "Sell-to Address 2";
                shipcity := "sell-to City";
                shipCountry := "sell-to County";
                shippostcode := "sell-to Post Code";
                shipPhoneNo := "Sell-to Phone No.";
                //end;

                if "Branch No." <> '' then
                    showBranch := 'สาขาที่ : ' + "Branch No."
                else
                    if "Branch No." = '00000' then
                        showBranch := 'สำนักงานใหญ่'
                    else
                        showBranch := 'สำนักงานใหญ่';

                //Companybranch
                Companybranch := 'สำนักงานใหญ่';
                //TH Tex Amount
                texamtth := TH_Even_Sub.FormatNoThaiText(TotalSalesValue);
                //TH Tex Amount

                marketplace.reset;
                marketplace.SetRange(marketplace, INT_MarketPlace_SNY);
                if marketplace.Find('-') then begin
                    marketplace.CalcFields(INT_Singatrue2_SNY);
                end;
                if not contact.get("Bill-to Contact No.") then
                    contact.init;
            end;

        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(SalesOrder)
                {


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
    begin
        CompanyInfo.GET;
        CompanyInfo.CalcFields(Picture);
    end;

    var
        LineInfo: Text[100];
        LineNo: Integer;
        OutputNo: Integer;
        NoOfCopies: Integer;
        CopyText: Text[100];
        CompanyInfo: Record "Company Information";
        DiscountSalesLine: Record "Sales Line";
        SubTotal: Decimal;
        Deliveryexist: Boolean;
        FOCexist: Boolean;
        SKU: Text[100];
        Item: Record Item;
        LineDeliveryDate: Date;
        LineDeliveryTime: Text[40];
        LineDeliveryexist: Boolean;
        SerialNoExist: Boolean;
        Rebate: Decimal;
        TotalSalesValue: Decimal;
        SalesbeforeGST: Decimal;
        GSTValue: Decimal;
        UnitPrice: Decimal;
        DiscountCode: Code[100];
        TotalRebateAmount: Decimal;
        TotalDiscountCode: Code[100];
        DiscountExist: Boolean;
        DeliveryChargesExist: Boolean;
        TotalDeliveryCharges: Decimal;
        RepQuantity: Decimal;
        shipName: text[100];
        shipadd1: text[100];
        shipadd2: text[100];
        shipcity: text[100];
        shipCountry: Text[100];
        shippostcode: text[100];
        shipPhoneNo: Text[100];
        countLine: Integer;
        showBranch: text[50];
        TH_Even_Sub: Codeunit INT_Even_Sub_SNY;
        texamtth: Text[200];
        marketplace: Record INT_MarketPlaces_SNY;
        Companybranch: Text[50];

        contact: Record Contact;

}