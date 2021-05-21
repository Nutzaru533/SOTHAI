#pragma implicitwith disable
pageextension 60002 "INT_TH_Sales_Return_Order" extends "Sales Return Order"
{
    layout
    {
        // Add changes to page layout here
        addafter(Status)
        {
            field("Order Confirm"; Rec.INT_Order_Confirm_SNY)
            {
                Caption = 'Goods Received';
                ApplicationArea = All;
            }
            field("Posting No."; Rec."Posting No.")
            {
                Caption = 'Posting No.';
                ApplicationArea = all;
            }
        }
        addafter(INT_BCOrderNo_SNY)
        {
            field("INT_BC Order Invoice No_SYN"; Rec."INT_BC Order Invoice No_SYN")
            {
                ApplicationArea = all;
            }
        }
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
        modify(INT_Remarks1_SNY)
        {
            Caption = 'Remasks(Report)';
        }


        addafter("Sell-to Address")
        {
            group(MaskSell)
            {
                Visible = MaskText;
                field("MSell-to Address"; Rec."Sell-to Address")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MSell-to Address2"; Rec."Sell-to Address 2")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MSell-to City"; Rec."Sell-to City")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MSell-to Country/Region Code"; Rec."Sell-to Country/Region Code")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MSell-to County"; Rec."Sell-to County")
                {
                    //Caption = 'Countries';
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }

            }
            group(UnMaskSell)
            {
                Visible = not MaskText;
                field("UMSell-to Address"; Rec."Sell-to Address")
                {

                    ApplicationArea = all;
                }
                field("UMSell-to Address3"; Rec."Sell-to Address 2")
                {

                    ApplicationArea = all;
                }
                field("UMSell-to City"; Rec."Sell-to City")
                {

                    ApplicationArea = all;
                }
                field("UMSell-to Country/Region Code"; Rec."Sell-to Country/Region Code")
                {

                    ApplicationArea = all;
                }
                field("UMSell-to County"; Rec."Sell-to County")
                {
                    //Caption = 'Countries';
                    ApplicationArea = all;
                }
            }
        }
        addafter("Ship-to Address")
        {
            group(MaskShip)
            {
                Visible = MaskText;
                field("Mship-to Address"; Rec."ship-to Address")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Mship-to Address2"; Rec."ship-to Address 2")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Mship-to City"; Rec."ship-to City")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Mship-to Country/Region Code"; Rec."ship-to Country/Region Code")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Mship-to County"; Rec."ship-to County")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }

            }
            group(UnMaskShip)
            {
                Visible = not MaskText;
                field("UMship-to Address"; Rec."ship-to Address")
                {

                    ApplicationArea = all;
                }
                field("UMship-to Address3"; Rec."ship-to Address 2")
                {

                    ApplicationArea = all;
                }
                field("UMship-to City"; Rec."ship-to City")
                {

                    ApplicationArea = all;
                }
                field("UMship-to Country/Region Code"; Rec."ship-to Country/Region Code")
                {

                    ApplicationArea = all;
                }
                field("UMship-to County"; Rec."ship-to County")
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
                field("MBill-to Address"; Rec."Bill-to Address")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MBill-to Address2"; Rec."Bill-to Address 2")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MBill-to City"; Rec."Bill-to City")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MBill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("MBill-to County"; Rec."Bill-to County")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
            }
            group(UnMaskBill)
            {
                Visible = not MaskText;
                field("UMBill-to Address"; Rec."Bill-to Address")
                {

                    ApplicationArea = all;
                }
                field("UMBill-to Address3"; Rec."Bill-to Address 2")
                {

                    ApplicationArea = all;
                }
                field("UMBill-to City"; Rec."Bill-to City")
                {

                    ApplicationArea = all;
                }
                field("UMBill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
                {

                    ApplicationArea = all;
                }
                field("UMBill-to County"; Rec."Bill-to County")
                {

                    ApplicationArea = all;
                }
            }

        }
        addbefore("Posting No.")
        {
            field("Vat Registration No.2"; Rec."Vat Registration No.2")
            {
                ApplicationArea = all;
            }
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
                        Rec."INT_Order_Confirm_SNY" := true;
                        Rec.Modify;
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
                        CurrPage.Update(false);
                        Rec.TestField("INT_Order_Confirm_SNY");
                        NotifySAP.ManualNotify(Rec);
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

                    CurrPage.Update(false);
                    Rec.TestField("Posting No.");
                    SalesHeaderReport.reset;
                    SalesHeaderReport.SetRange("Document Type", Rec."Document Type");
                    SalesHeaderReport.SetRange("No.", Rec."No.");
                    if SalesHeaderReport.findfirst() then
                        Report.RunModal(60002, true, false, SalesHeaderReport);

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

    end;

    trigger OnAfterGetRecord()
    begin
        SetActionVisible()
    end;

    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin

    end;


}
#pragma implicitwith restore
