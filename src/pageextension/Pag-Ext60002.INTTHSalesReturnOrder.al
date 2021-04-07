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


    }

    var
        show_ProcessOrder: Boolean;
        show_SynctoSAP: Boolean;
        myInt: Integer;

    local procedure SetActionVisible()
    var
        UserActionCtrl: Codeunit INT_UserSecurityMgt_SNY;
    begin

        show_ProcessOrder := UserActionCtrl.ActionShow(Page::"Sales Return Order", 10);
        show_SynctoSAP := UserActionCtrl.ActionShow(Page::"Sales Return Order", 20);
    end;

    trigger OnAfterGetRecord()
    begin
        SetActionVisible();
    end;
}