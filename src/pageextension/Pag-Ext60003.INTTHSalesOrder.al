pageextension 60003 "INT_TH_Sales_Order" extends "Sales Order"
{
    layout
    {
        // Add changes to page layout here
        addafter("Sell-to Address 2")
        {
            //field("Sell-to County"; "Sell-to County")
            //{
            //    Caption = 'County';
            //    ApplicationArea = all;
            // }
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

                trigger OnAction()
                var
                    SalesHeaderReport: Record "Sales Header";
                begin
                    if not (INT_DeliveryType_SNY=INT_DeliveryType_SNY::"DBS Home") then
                      Error('Only Print on Delivery Type is DBS Home');
                    SalesHeaderReport.reset;
                    SalesHeaderReport.SetRange("Document Type", "Document Type");
                    SalesHeaderReport.SetRange("No.", "No.");
                    if SalesHeaderReport.findfirst() then
                        Report.RunModal(60003, true, false, SalesHeaderReport);
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
                begin
                    SalesHeaderReport.reset;
                    SalesHeaderReport.SetRange("Document Type", "Document Type");
                    SalesHeaderReport.SetRange("No.", "No.");
                    if SalesHeaderReport.findfirst() then
                        Report.RunModal(60001, true, false, SalesHeaderReport);
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
                    //calculate
                    SalesHeader.Reset();
                    SalesHeader.SetRange("Document Type", rec."Document Type");
                    SalesHeader.SetRange("No.", rec."No.");
                    SalesHeader.FindFirst();
                    OrderProcessing.SetOrder(SalesHeader);
                    OrderProcessing.Run();
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
                    SalesHeader.Reset();
                    SalesHeader.SetRange("Document Type", rec."Document Type");
                    SalesHeader.SetRange("No.", rec."No.");
                    SalesHeader.FindFirst();
                    MarketPlace.Get(rec.INT_MarketPlace_SNY);
                    if MarketPlace."Process ID" = 1 then
                        OrderProcessing.ReprocessSalesOrder2(SalesHeader)
                    else
                        OrderProcessing.ReprocessSalesOrder(SalesHeader);
                    // OrderProcessing.Run();
                end;
            }
        }
        addafter("INT_PrintDocument_SNY")
        {
            action("INT_PrintDocument_SNY2")
            {
                ApplicationArea = All;
                Image = PrintDocument;
                Promoted = true;
                PromotedCategory = Process;
                Caption = 'Print Document';
                Visible = show_PrintDocument;
                trigger OnAction()
                var
                    EcomInterface: Codeunit INT_Even_Sub_SNY;
                    SalesHeaderReport: Record "Sales Header";
                    SalesInvoiceReport: Report "INT_Sales Invoice_SNY";
                begin
                    if rec.INT_MarketPlace_SNY = 'SONY STORE ONLINE' then begin
                        SalesHeaderReport.reset;
                        SalesHeaderReport.SetRange("Document Type", "Document Type");
                        SalesHeaderReport.SetRange("No.", "No.");
                        if SalesHeaderReport.findfirst() then
                            Report.RunModal(70003, true, false, SalesHeaderReport);
                    end
                    else
                        EcomInterface.PrintDocument(Rec);
                end;
            }
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
                    MaskAddress();
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        MaskText := true;
        intMaskAddress();
    end;

    trigger OnAfterGetRecord()

    begin
        SetActionVisible();
        MaskAddress();
    end;

    var
        usersetup: Record "User Setup";
        show_PrintDocument: Boolean;
        show_ProcessOrder: Boolean;
        show_ConfirmDeliveryAddress: Boolean;
        show_ConfirmCollect: Boolean;
        Show_ReprocessOrder: Boolean;
        MaskText: Boolean;
        selltoaddrss: Text[100];
        selltoaddress2: Text[100];
        selltocity: text[100];
        selltocoulty: text[100];
        selltopostcode: text[100];
        billtoaddess: Text[100];
        billtoaddress2: text[100];
        billtocity: text[100];
        billtocoulty: text[100];
        billtopostcode: text[100];
        shiptoaddress: text[100];
        shiptoaddress2: text[100];
        shiptocity: text[100];
        shiptocoulty: text[100];
        shiptopostcode: text[100];

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

    local procedure intMaskAddress()
    var
    begin
        selltoaddrss := "Sell-to Address";
        selltoaddress2 := "sell-to Address 2";
        selltocity := "Sell-to City";
        selltocoulty := "Sell-to County";
        selltopostcode := "Sell-to Post Code";

        billtoaddess := "Bill-to Address";
        billtoaddress2 := "Bill-to Address 2";
        billtocity := "Bill-to City";
        billtocoulty := "Bill-to County";
        billtopostcode := "Bill-to Post Code";

        shiptoaddress := "Ship-to Address";
        shiptoaddress2 := "Ship-to Address 2";
        shiptocity := "Ship-to City";
        shiptocoulty := "Ship-to County";
        shiptopostcode := "Ship-to Post Code";
    end;

    local procedure MaskAddress()
    var
        usersetup: Record "User Setup";
    begin
        //

        //
        //if usersetup.get(userid) then begin
        //if usersetup.INT_Unmark_SNY then
        //MaskText := true
        //else
        //MaskText := false;
        //end;

        if MaskText = true then begin
            "Sell-to Address" := 'XXXXXX';
            "Sell-to Address 2" := 'XXXXXX';
            "Sell-to City" := 'XXXXXX';
            "Sell-to County" := 'XXXXXX';
            "Sell-to Post Code" := 'XXXXXX';

            "bill-to Address" := 'XXXXXX';
            "bill-to Address 2" := 'XXXXXX';
            "bill-to City" := 'XXXXXX';
            "bill-to County" := 'XXXXXX';
            "bill-to Post Code" := 'XXXXXX';

            "ship-to Address" := 'XXXXXX';
            "ship-to Address 2" := 'XXXXXX';
            "ship-to City" := 'XXXXXX';
            "ship-to County" := 'XXXXXX';
            "ship-to Post Code" := 'XXXXXX';
        end;
        if MaskText = false then begin
            "Sell-to Address" := selltoaddrss;
            "Sell-to Address 2" := selltoaddress2;
            "Sell-to City" := selltocity;
            "Sell-to County" := selltocoulty;
            "Sell-to Post Code" := selltopostcode;

            "bill-to Address" := billtoaddess;
            "bill-to Address 2" := billtoaddress2;
            "bill-to City" := billtocity;
            "bill-to County" := billtocoulty;
            "bill-to Post Code" := billtopostcode;

            "ship-to Address" := shiptoaddress;
            "ship-to Address 2" := shiptoaddress2;
            "ship-to City" := shiptocity;
            "ship-to County" := shiptocoulty;
            "ship-to Post Code" := shiptopostcode;
        end;
    end;
}