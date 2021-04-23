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
        addafter("Assigned User ID")
        {
            field("Posting No."; "Posting No.")
            {
                ApplicationArea = all;
            }
        }
        modify("Sell-to Address")
        {
            Editable = not MaskText;
        }
        modify("Sell-to Address 2")
        {
            Editable = not MaskText;
        }
        modify("Sell-to City")
        {
            Editable = not MaskText;
        }
        modify("Sell-to County")
        {
            Editable = not MaskText;
        }
        modify("Sell-to Post Code")
        {
            Editable = not MaskText;
        }
        modify("bill-to Address")
        {
            Editable = not MaskText;
        }
        modify("bill-to Address 2")
        {
            Editable = not MaskText;
        }
        modify("bill-to County")
        {
            Editable = not MaskText;
        }
        modify("bill-to Post Code")
        {
            Editable = not MaskText;
        }
        modify("ship-to Address")
        {
            Editable = not MaskText;
        }
        modify("ship-to Address 2")
        {
            Editable = not MaskText;
        }
        modify("ship-to City")
        {
            Editable = not MaskText;
        }
        modify("ship-to County")
        {
            Editable = not MaskText;
        }
        modify("ship-to Post Code")
        {
            Editable = not MaskText;
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

                    resetmask;

                    SalesHeaderReport.reset;
                    SalesHeaderReport.SetRange("Document Type", "Document Type");
                    SalesHeaderReport.SetRange("No.", "No.");
                    if SalesHeaderReport.findfirst() then begin

                        //REPORT.run(REPORT::INT_TH_Sales_Invoice, true, false, SalesHeaderReport);
                        REPORT.run(REPORT::INT_TH_Sales_Invoice, false, false, SalesHeaderReport);
                        CurrPage.Update(false);
                        Commit();

                        //Sleep(10000);
                        if (SalesHeaderReport.INT_DeliveryType_SNY = SalesHeaderReport.INT_DeliveryType_SNY::"DBS Home") then begin

                            REPORT.RunModal(REPORT::INT_AWB_Report_SYN, true, false, SalesHeaderReport);
                            CurrPage.Update(false);
                            Commit();
                            //INT_AWB_Report_SYN.SetTableView(SalesHeaderReport);
                            //INT_AWB_Report_SYN.UseRequestPage(true);
                            //INT_AWB_Report_SYN.Run();
                        end;
                        CurrPage.Update(false);
                    end;
                    MaskAddress;
                end;
            }
            action("Download Report")
            {
                ApplicationArea = All;
                Image = ExportFile;
                Caption = 'Test Download';
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
                var
                    TempBlob_lRec: Record TempBlob temporary;
                    ReportOut: OutStream;
                    ReportIn: InStream;
                    RecRef: RecordRef;
                    ReportOut2: OutStream;
                    ReportIn2: InStream;
                    RecRef2: RecordRef;
                    FileManagement_lCdu: Codeunit "File Management";
                    SalesHeader_lRec: Record "Sales Header";
                    TempBlob: Codeunit "Temp Blob";
                    MyPath: Text[100];
                    MyPath2: Text[100];
                    Temppath: Text[1000];
                begin
                    //TempBlob_lRec.Blob.CreateOutStream(Out, TEXTENCODING::UTF8);
                    /*
                    TempBlob.CreateOutStream(Out, TEXTENCODING::UTF8);
                    SalesHeader_lRec.Reset;
                    SalesHeader_lRec.SetRange("Document Type", "Document Type");
                    SalesHeader_lRec.SetRange("No.", "No.");
                    SalesHeader_lRec.FindFirst();
                    RecRef.GetTable(SalesHeader_lRec);
                    REPORT.SAVEAS(60001, '', REPORTFORMAT::Pdf, Out, RecRef);
                    REPORT.SAVEAS(60003, '', REPORTFORMAT::Pdf, Out, RecRef);
                    FileManagement_lCdu.BLOBExport(TempBlob, STRSUBSTNO('SalesOrder_%1.Pdf', "No."), TRUE);
                    */
                    SalesHeader_lRec.Reset;
                    SalesHeader_lRec.SetRange("Document Type", "Document Type");
                    SalesHeader_lRec.SetRange("No.", "No.");
                    if SalesHeader_lRec.Find('-') then begin
                        RecRef.GetTable(SalesHeader_lRec);
                        TempBlob.CreateOutStream(ReportOut, TEXTENCODING::UTF8);
                        REPORT.SAVEAS(60001, SalesHeader_lRec.GetFilters, REPORTFORMAT::Pdf, ReportOut, RecRef);
                        TempBlob.CreateInStream(ReportIn, TEXTENCODING::UTF8);
                        MyPath := 'SO.PDF';
                        DownloadFromStream(ReportIn, '', '', '', MyPath);
                    end;

                    SalesHeader_lRec.Reset;
                    SalesHeader_lRec.SetRange("Document Type", "Document Type");
                    SalesHeader_lRec.SetRange("No.", "No.");
                    if SalesHeader_lRec.Find('-') then begin
                        RecRef2.GetTable(SalesHeader_lRec);

                        TempBlob.CreateOutStream(ReportOut2, TEXTENCODING::UTF8);
                        REPORT.SAVEAS(60003, SalesHeader_lRec.GetFilters, REPORTFORMAT::Pdf, ReportOut2, RecRef2);
                        TempBlob.CreateInStream(ReportIn2, TEXTENCODING::UTF8);
                        MyPath2 := 'AWB.PDF';
                        DownloadFromStream(ReportIn2, '', '', '', MyPath2);
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
                    resetmask;
                    CurrPage.Update(false);
                    SalesHeader.Reset();
                    SalesHeader.SetRange("Document Type", rec."Document Type");
                    SalesHeader.SetRange("No.", rec."No.");
                    SalesHeader.FindFirst();
                    OrderProcessing.SetOrder(SalesHeader);
                    OrderProcessing.Run();
                    MaskAddress;
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
                    resetmask;
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
                    MaskAddress;
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
                    resetmask;
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
                    MaskAddress;
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
                    resetmask;
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
                    MaskAddress;
                    CurrPage.Update(false);
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
                    resetmask;
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
                    MaskAddress;
                    CurrPage.Update(false);
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
        //INT_Mask_SYN := MaskText;
        //Modify();
        //Commit();
        //CurrPage.Update(false);
        intMaskAddress();
        MaskAddress();
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
        CurrPage.Update(false);
    end;

    local procedure resetmask()
    var
        myInt: Integer;
    begin
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
        CurrPage.Update(false);
    end;

}