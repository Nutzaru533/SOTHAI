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
        addbefore("INT_SyncToSAP_SNY")
        {
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
                        "INT_Order_Confirm_SNY" := true;
                        Modify;
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
                        TestField("INT_Order_Confirm_SNY");
                        NotifySAP.ManualNotify(Rec);
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
                    SalesHeaderReport.reset;
                    SalesHeaderReport.SetRange("Document Type", "Document Type");
                    SalesHeaderReport.SetRange("No.", "No.");
                    if SalesHeaderReport.findfirst() then
                        Report.RunModal(60002, true, false, SalesHeaderReport);
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
                        INT_Mask_SYN := false;
                        Modify();
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
        INT_Mask_SYN := MaskText;
        Modify();
        Commit();
        CurrPage.Update(false);
        intMaskAddress();
    end;

    trigger OnAfterGetRecord()
    begin
        SetActionVisible();
        MaskAddress();
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