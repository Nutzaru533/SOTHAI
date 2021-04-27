pageextension 60002 "INT_TH_Sales_Return_Order" extends "Sales Return Order"
{
    layout
    {
        // Add changes to page layout here
        addafter(Status)
        {
            field("Order Confirm"; INT_Order_Confirm_SNY)
            {
                Caption = 'Goods Received';
                ApplicationArea = All;
            }
            field("Posting No."; "Posting No.")
            {
                Caption = 'Posting No.';
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
        modify(INT_ProcessOrder_SNY)
        {
            Visible = false;
        }

        addbefore("INT_SyncToSAP_SNY")
        {
            action("INT_ProcessOrder_SNY2")
            {
                ApplicationArea = All;
                Image = CancelAllLines;
                Caption = 'Process Order';
                ToolTip = 'Incase of Manual Process Order or user need to push to SAP immediately';
                Promoted = true;
                Visible = show_ProcessOrder;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    //OrderProcessing: Codeunit "INT_OrderProcesssSch._SNY";
                    OrderProcessing: Codeunit INT_TH_OrderProcessing_SNY;
                begin
                    OrderProcessing.SetOrder(Rec);
                    OrderProcessing.Run();
                end;
            }
            group("Confirm Order TH")
            {
                action("Confirm Order")
                {

                    ApplicationArea = All;
                    Image = Confirm;
                    Promoted = true;
                    PromotedCategory = Process;
                    Caption = 'Goods Received';
                    trigger OnAction()
                    begin
                        CurrPage.Update(false);
                        resetmask;
                        "INT_Order_Confirm_SNY" := true;
                        Modify;
                        MaskAddress;
                        CurrPage.Update(false);
                    end;
                }

                action("TH_INT_SyncToSAP_SNY")
                {
                    ApplicationArea = All;
                    Image = UpdateShipment;
                    Visible = show_SynctoSAP;
                    Promoted = true;
                    PromotedCategory = Process;
                    Caption = 'Sync To Sap';
                    trigger OnAction()
                    var
                        NotifySAP: Codeunit INT_SAPAPI_SNY;
                    begin
                        resetmask;
                        CurrPage.Update(false);
                        TestField("INT_Order_Confirm_SNY");
                        NotifySAP.ManualNotify(Rec);
                        MaskAddress;
                        CurrPage.Update(false);
                    end;

                }
            }


        }
        addbefore(INT_ProcessOrder_SNY)
        {
            action(PrintCreditNote)
            {
                Caption = 'Credit Note/Tax Invoice';
                ApplicationArea = All;
                Image = PrintDocument;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    EcomInterface: Codeunit INT_EcomInterface_SNY;
                    SalesHeaderReport: Record "Sales Header";
                begin
                    resetmask;
                    CurrPage.Update(false);
                    SalesHeaderReport.reset;
                    SalesHeaderReport.SetRange("Document Type", "Document Type");
                    SalesHeaderReport.SetRange("No.", "No.");
                    if SalesHeaderReport.findfirst() then
                        Report.RunModal(60002, true, false, SalesHeaderReport);
                    MaskAddress;
                    CurrPage.Update(false);
                end;
            }
        }
        modify("INT_SyncToSAP_SNY")
        {
            Visible = false;
        }
        addafter("&Print")
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

    var
        show_SynctoSAP: Boolean;
        myInt: Integer;
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
        salesheader: Record "Sales Header";

    local procedure SetActionVisible()
    var
        UserActionCtrl: Codeunit INT_UserSecurityMgt_SNY;
    begin

        show_ProcessOrder := UserActionCtrl.ActionShow(Page::"Sales Return Order", 10);
        show_SynctoSAP := UserActionCtrl.ActionShow(Page::"Sales Return Order", 20);
    end;

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
        resetmask();
        MaskAddress();
    end;

    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin
        MaskAddress();
        resetmask();
        MaskAddress();
    end;

    local procedure intMaskAddress()
    var
    begin
        salesheader.reset;
        if salesheader.get("Document Type", "No.") then begin
            selltoaddrss := salesheader."Sell-to Address";
            selltoaddress2 := salesheader."sell-to Address 2";
            selltocity := salesheader."Sell-to City";
            selltocoulty := salesheader."Sell-to County";
            selltopostcode := salesheader."Sell-to Post Code";

            billtoaddess := salesheader."Bill-to Address";
            billtoaddress2 := salesheader."Bill-to Address 2";
            billtocity := salesheader."Bill-to City";
            billtocoulty := salesheader."Bill-to County";
            billtopostcode := salesheader."Bill-to Post Code";

            shiptoaddress := salesheader."Ship-to Address";
            shiptoaddress2 := salesheader."Ship-to Address 2";
            shiptocity := salesheader."Ship-to City";
            shiptocoulty := salesheader."Ship-to County";
            shiptopostcode := salesheader."Ship-to Post Code";
        end;

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

    procedure resetmask()
    var
        myInt: Integer;
    begin
        salesheader.reset;
        if salesheader.get("Document Type", "No.") then begin
            "Sell-to Address" := salesheader."Sell-to Address";
            "Sell-to Address 2" := salesheader."Sell-to Address 2";
            "Sell-to City" := salesheader."Sell-to City";
            "Sell-to County" := salesheader."Sell-to County";
            "Sell-to Post Code" := salesheader."Sell-to Post Code";

            "bill-to Address" := salesheader."bill-to Address";
            "bill-to Address 2" := salesheader."bill-to Address 2";
            "bill-to City" := salesheader."bill-to City";
            "bill-to County" := salesheader."bill-to County";
            "bill-to Post Code" := salesheader."bill-to Post Code";

            "ship-to Address" := salesheader."ship-to Address";
            "ship-to Address 2" := salesheader."ship-to Address 2";
            "ship-to City" := salesheader."ship-to City";
            "ship-to County" := salesheader."ship-to County";
            "ship-to Post Code" := salesheader."ship-to Post Code";

            selltoaddrss := salesheader."Sell-to Address";
            selltoaddress2 := salesheader."sell-to Address 2";
            selltocity := salesheader."Sell-to City";
            selltocoulty := salesheader."Sell-to County";
            selltopostcode := salesheader."Sell-to Post Code";

            billtoaddess := salesheader."Bill-to Address";
            billtoaddress2 := salesheader."Bill-to Address 2";
            billtocity := salesheader."Bill-to City";
            billtocoulty := salesheader."Bill-to County";
            billtopostcode := salesheader."Bill-to Post Code";

            shiptoaddress := salesheader."Ship-to Address";
            shiptoaddress2 := salesheader."Ship-to Address 2";
            shiptocity := salesheader."Ship-to City";
            shiptocoulty := salesheader."Ship-to County";
            shiptopostcode := salesheader."Ship-to Post Code";

        end;
        CurrPage.Update(false);
    end;
}