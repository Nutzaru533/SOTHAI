pageextension 60003 "INT_TH_Sales_Order" extends "Sales Order"
{
    layout
    {
        modify("Sell-to Address")
        {
            Visible = false;
        }
        modify("Sell-to Address 2")
        {
            Visible = false;
        }
        modify("Sell-to City")
        {
            Visible = false;
        }
        modify("Sell-to County")
        {
            Visible = false;
        }
        modify("Sell-to Post Code")
        {
            Visible = false;
        }
        modify("bill-to Address")
        {
            Visible = false;
        }
        modify("bill-to Address 2")
        {
            Visible = false;
        }
        modify("bill-to County")
        {
            Visible = false;
        }
        modify("bill-to Post Code")
        {
            Visible = false;
        }
        modify("ship-to Address")
        {
            Visible = false;
        }
        modify("ship-to Address 2")
        {
            Visible = false;
        }
        modify("ship-to City")
        {
            Visible = false;
        }
        modify("ship-to County")
        {
            Visible = false;
        }
        modify("ship-to Post Code")
        {
            Visible = false;
        }

        addafter("Sell-to Address")
        {
            group(MaskSell)
            {
                Visible = MaskText;
                field("MSell-to Address"; "Sell-to Address")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MSell-to Address2"; "Sell-to Address 2")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MSell-to City"; "Sell-to City")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MSell-to Country/Region Code"; "Sell-to Country/Region Code")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MSell-to County"; "Sell-to County")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }

            }
            group(UnMaskSell)
            {
                Visible = not MaskText;
                field("UMSell-to Address"; "Sell-to Address")
                {

                    ApplicationArea = all;
                }
                field("UMSell-to Address3"; "Sell-to Address 2")
                {

                    ApplicationArea = all;
                }
                field("UMSell-to City"; "Sell-to City")
                {

                    ApplicationArea = all;
                }
                field("UMSell-to Country/Region Code"; "Sell-to Country/Region Code")
                {

                    ApplicationArea = all;
                }
                field("UMSell-to County"; "Sell-to County")
                {

                    ApplicationArea = all;
                }
            }
        }
        addafter("Ship-to Address")
        {
            group(MaskShip)
            {
                Visible = MaskText;
                field("Mship-to Address"; "ship-to Address")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Mship-to Address2"; "ship-to Address 2")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Mship-to City"; "ship-to City")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Mship-to Country/Region Code"; "ship-to Country/Region Code")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Mship-to County"; "ship-to County")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }

            }
            group(UnMaskShip)
            {
                Visible = not MaskText;
                field("UMship-to Address"; "ship-to Address")
                {

                    ApplicationArea = all;
                }
                field("UMship-to Address3"; "ship-to Address 2")
                {

                    ApplicationArea = all;
                }
                field("UMship-to City"; "ship-to City")
                {

                    ApplicationArea = all;
                }
                field("UMship-to Country/Region Code"; "ship-to Country/Region Code")
                {

                    ApplicationArea = all;
                }
                field("UMship-to County"; "ship-to County")
                {

                    ApplicationArea = all;
                }
            }

        }
        addafter("Bill-to Address")
        {
            group(MaskBill)
            {
                Visible = MaskText;
                field("MBill-to Address"; "Bill-to Address")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MBill-to Address2"; "Bill-to Address 2")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MBill-to City"; "Bill-to City")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MBill-to Country/Region Code"; "Bill-to Country/Region Code")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MBill-to County"; "Bill-to County")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
            }
            group(UnMaskBill)
            {
                Visible = not MaskText;
                field("UMBill-to Address"; "Bill-to Address")
                {

                    ApplicationArea = all;
                }
                field("UMBill-to Address3"; "Bill-to Address 2")
                {

                    ApplicationArea = all;
                }
                field("UMBill-to City"; "Bill-to City")
                {

                    ApplicationArea = all;
                }
                field("UMBill-to Country/Region Code"; "Bill-to Country/Region Code")
                {

                    ApplicationArea = all;
                }
                field("UMBill-to County"; "Bill-to County")
                {

                    ApplicationArea = all;
                }
            }

        }

        // Add changes to page layout here
        addafter("Assigned User ID")
        {


            field("Posting No.2"; "Posting No.")
            {
                ApplicationArea = all;
                //Visible = not MaskText;
            }
            //}

        }


    }
    actions
    {
        // Add changes to page actions here
        addafter(INT_PrintDocument_SNY)
        {
            action(AWB)
            {
                Caption = 'AWB Report';
                ApplicationArea = All;
                Image = PrintDocument;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
                var
                    SalesHeaderReport: Record "Sales Header";
                begin
                    if not (INT_DeliveryType_SNY = INT_DeliveryType_SNY::"DBS Home") then
                        Error('Only Print on Delivery Type is DBS Home');
                    SalesHeaderReport.reset;
                    SalesHeaderReport.SetRange("Document Type", "Document Type");
                    SalesHeaderReport.SetRange("No.", "No.");
                    if SalesHeaderReport.findfirst() then
                        Report.RunModal(60003, true, false, SalesHeaderReport);
                end;
            }
            action("INT_PrintDocument_SNY2")
            {
                ApplicationArea = All;
                Image = PrintDocument;
                Promoted = true;
                PromotedCategory = Process;
                Caption = 'AWB';
                Visible = show_PrintDocument;
                trigger OnAction()
                var
                    EcomInterface: Codeunit INT_Even_Sub_SNY;
                    SalesHeaderReport: Record "Sales Header";
                    SalesInvoiceReport: Report "INT_Sales Invoice_SNY";

                begin

                    CurrPage.Update(false);
                    if rec.INT_MarketPlace_SNY = 'SONY STORE ONLINE' then begin
                        SalesHeaderReport.reset;
                        SalesHeaderReport.SetRange("Document Type", "Document Type");
                        SalesHeaderReport.SetRange("No.", "No.");
                        if SalesHeaderReport.findfirst() then
                            Report.RunModal(70003, true, false, SalesHeaderReport);
                    end
                    else
                        EcomInterface.PrintDocument(Rec);

                    CurrPage.Update(false);
                end;
            }

            action(TaxInvoice)
            {
                Caption = 'Receipt/Tax Invoice';
                ApplicationArea = All;
                Image = PrintDocument;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    EcomInterface: Codeunit INT_EcomInterface_SNY;
                    SalesHeaderReport: Record "Sales Header";
                    Filename: Text[100];
                    i: Integer;
                    INT_AWB_Report_SYN: Report INT_AWB_Report_SYN;
                    TempBlob_lRec: Record TempBlob temporary;
                    Out: OutStream;
                    RecRef: RecordRef;
                    FileManagement_lCdu: Codeunit "File Management";
                    SalesHeader_lRec: Record "Sales Header";
                    TempBlob: Codeunit "Temp Blob";
                begin

                    TestField("Posting No.");
                    SalesHeaderReport.reset;
                    SalesHeaderReport.SetRange("Document Type", "Document Type");
                    SalesHeaderReport.SetRange("No.", "No.");
                    if SalesHeaderReport.findfirst() then begin

                        //REPORT.run(REPORT::INT_TH_Sales_Invoice, true, false, SalesHeaderReport);
                        REPORT.run(REPORT::INT_TH_Sales_Invoice, true, true, SalesHeaderReport);
                        CurrPage.Update(false);
                        Commit();
                    end;

                end;
            }
        }
        addafter(INT_ProcessOrder_SNY)
        {
            action("TH_INT_ProcessOrder_SNY")
            {
                ApplicationArea = All;
                Image = CancelAllLines;
                Caption = 'Process Order ';
                ToolTip = 'Incase of Manual Process Order or user need to push to SAP immediately';
                Promoted = true;
                Visible = show_ProcessOrder;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    //OrderProcessing: Codeunit "INT_OrderProcesssSch._SNY";
                    SalesHeader: Record "Sales Header";
                    OrderProcessing: Codeunit "INT_TH_OrderProcessing_SNY";
                    salesline: Record "Sales Line";
                    item: Record item;
                begin
                    //calculate
                    /*
                    salesline.reset;
                    salesline.SetRange("Document Type", "Document Type");
                    salesline.SetRange("Document No.", "No.");
                    salesline.SetFilter(Quantity, '>%1', 0);
                    salesline.SetFilter("Unit Price", '>%1', 0);
                    salesline.SetRange(Type, salesline.type::Item);
                    if salesline.Find('-') then
                        repeat
                            if item.get(salesline."No.") then begin
                                if not item.INT_Exclude_Discount_SNY then begin
                                    salesline.Validate("Line Discount Amount", "Seller Voucher Amount");
                                    salesline.Modify();
                                end
                            end
                        until salesline.Next = 0;
                        */

                    CurrPage.Update(false);
                    SalesHeader.Reset();
                    SalesHeader.SetRange("Document Type", rec."Document Type");
                    SalesHeader.SetRange("No.", rec."No.");
                    SalesHeader.FindFirst();
                    OrderProcessing.SetOrder(SalesHeader);
                    OrderProcessing.Run();

                    CurrPage.Update(false);
                end;
            }

        }
        addafter("INT_ConfirmDelivery_SNY")
        {
            action("TH_INT_ConfirmDelivery_SNY")
            {
                ApplicationArea = All;
                Image = Delivery;
                Promoted = true;
                PromotedCategory = Process;
                Visible = show_ConfirmDeliveryAddress;
                Caption = 'Confirm Delivery Address';

                trigger OnAction()
                var
                    OrderProcessing: Codeunit "INT_TH_OrderProcessing_SNY";
                    SalesHeader: Record "Sales Header";
                    MarketPlace: Record INT_MarketPlaces_SNY;
                begin

                    CurrPage.Update(false);
                    SalesHeader.Reset();
                    SalesHeader.SetRange("Document Type", rec."Document Type");
                    SalesHeader.SetRange("No.", rec."No.");
                    SalesHeader.FindFirst();
                    OrderProcessing.SetOrder(SalesHeader);
                    MarketPlace.Get(rec.INT_MarketPlace_SNY);
                    if MarketPlace."Process ID" = 1 then
                        OrderProcessing.DeliveryConfirm2(true)
                    else
                        OrderProcessing.DeliveryConfirm(true);

                    CurrPage.Update(false);
                end;
            }
        }
        addafter("INT_ConfirmCollect_SNY")
        {
            action("TH_INT_ConfirmCollect_SNY")
            {
                ApplicationArea = All;
                Image = Delivery;
                Promoted = true;
                PromotedCategory = Process;
                Visible = show_ConfirmCollect;
                Caption = 'Confirm Collect';
                trigger OnAction()
                var
                    OrderProcessing: Codeunit "INT_TH_OrderProcessing_SNY";
                    SalesHeader: Record "Sales Header";
                    MarketPlace: Record INT_MarketPlaces_SNY;
                begin
                    CurrPage.Update(false);

                    SalesHeader.Reset();
                    SalesHeader.SetRange("Document Type", rec."Document Type");
                    SalesHeader.SetRange("No.", rec."No.");
                    SalesHeader.FindFirst();
                    OrderProcessing.SetOrder(SalesHeader);
                    MarketPlace.Get(rec.INT_MarketPlace_SNY);
                    if MarketPlace."Process ID" = 1 then
                        OrderProcessing.FullfillmentCollectConfirm(true)
                    else
                        OrderProcessing.CollectConfirm(true);

                    CurrPage.Update(false);
                end;
            }

        }
        addafter("INT_ReProcessOrder_SNY")
        {
            action("TH_INT_ReProcessOrder_SNY")
            {
                ApplicationArea = All;
                Image = RefreshPlanningLine;
                Caption = 'Re-Process Order';
                ToolTip = 'Incase of Manual Re- Process Order';
                Promoted = true;
                Visible = Show_ReprocessOrder;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    //OrderProcessing: Codeunit "INT_OrderProcesssSch._SNY";
                    SalesHeader: Record "Sales Header";
                    OrderProcessing: Codeunit "INT_TH_OrderProcessing_SNY";
                    MarketPlace: Record INT_MarketPlaces_SNY;
                begin

                    CurrPage.Update(false);
                    SalesHeader.Reset();
                    SalesHeader.SetRange("Document Type", rec."Document Type");
                    SalesHeader.SetRange("No.", rec."No.");
                    SalesHeader.FindFirst();
                    MarketPlace.Get(rec.INT_MarketPlace_SNY);
                    if MarketPlace."Process ID" = 1 then
                        OrderProcessing.ReprocessSalesOrder2(SalesHeader)
                    else
                        if MarketPlace."Process ID" = 2 then
                            OrderProcessing.ReprocessSalesOrder3(SalesHeader)
                        else
                            OrderProcessing.ReprocessSalesOrder(SalesHeader);
                    // OrderProcessing.Run();

                    CurrPage.Update(false);
                end;
            }
        }
        addafter("INT_PrintDocument_SNY")
        {

        }
        modify("INT_PrintDocument_SNY")
        {
            Visible = false;
        }
        modify("INT_ConfirmCollect_SNY")
        {
            Visible = false;
        }
        modify(INT_ConfirmDelivery_SNY)
        {
            Visible = false;
        }
        modify(INT_ProcessOrder_SNY)
        {
            Visible = false;
        }
        modify(INT_ReProcessOrder_SNY)
        {
            Visible = false;
        }



        addafter("&Order Confirmation")
        {
            action(Unmark)
            {
                ApplicationArea = All;
                Caption = 'UNMask Address';
                Image = Lock;
                trigger OnAction()
                begin
                    if usersetup.get(UserId) then begin
                        usersetup.TestField(INT_Unmark_SNY);
                        MaskText := false;
                    end;

                end;
            }
        }
    }


    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        MaskText := true;
        //INT_Mask_SYN := MaskText;
        //Modify();
        //Commit();
        //CurrPage.Update(false);
        //intMaskAddress();
        //MaskAddress();
    end;


    trigger OnAfterGetRecord()
    begin
        SetActionVisible();
        //resetmask();
        //MaskAddress();
    end;

    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin
        //MaskAddress();
        //resetmask();
        //MaskAddress();
    end;

    trigger OnModifyRecord(): Boolean;
    begin
        //MaskAddress();
        //resetmask();
        //MaskAddress();
    end;

    var
        usersetup: Record "User Setup";
        show_PrintDocument: Boolean;
        show_ProcessOrder: Boolean;
        show_ConfirmDeliveryAddress: Boolean;
        show_ConfirmCollect: Boolean;
        Show_ReprocessOrder: Boolean;
        MaskText: Boolean;


    local procedure SetActionVisible()
    var
        UserActionCtrl: Codeunit INT_UserSecurityMgt_SNY;
    begin
        show_PrintDocument := UserActionCtrl.ActionShow(Page::"Sales Order", 10);
        show_ProcessOrder := UserActionCtrl.ActionShow(Page::"Sales Order", 80);
        show_ConfirmDeliveryAddress := UserActionCtrl.ActionShow(Page::"Sales Order", 30);
        show_ConfirmCollect := UserActionCtrl.ActionShow(Page::"Sales Order", 100);
        Show_ReprocessOrder := UserActionCtrl.ActionShow(Page::"Sales Order", 110);
    end;





}