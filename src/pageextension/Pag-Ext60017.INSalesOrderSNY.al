pageextension 60017 "IN_SalesOrder_SNY" extends "Sales Order List"
{
    layout
    {
        // Add changes to page layout here

    }

    actions
    {
        // Add changes to page actions here
        addafter("Sales Reservation Avail.")
        {

            action(SalesInvoice)
            {
                ApplicationArea = All;
                Caption = 'Receipt / Tax Invoice';
                Image = PrintDocument;
                Promoted = true;
                PromotedCategory = Report;
                trigger OnAction()
                var
                    salesheader: Record "Sales Header";
                    SalesHeaderReport: Record "Sales Header";
                begin
                    salesheader.Reset();
                    CurrPage.SetSelectionFilter(salesheader);
                    if salesheader.FindSet() then
                        repeat
                            Message('%1', salesheader."No.");
                            Report.RunModal(60001, false, false, salesheader);
                            if (salesheader.INT_DeliveryType_SNY = salesheader.INT_DeliveryType_SNY::"DBS Home") then
                                Report.RunModal(60003, false, false, salesheader);
                        until salesheader.next = 0;
                end;
            }
        }
    }

    var
        myInt: Integer;
}