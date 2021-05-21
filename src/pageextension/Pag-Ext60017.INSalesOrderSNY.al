pageextension 60017 "IN_SalesOrder_SNY" extends "Sales Order List"
{
    layout
    {
        // Add changes to page layout here
        addafter("No.")
        {
            field("Posting No."; "Posting No.")
            {
                ApplicationArea = all;
            }
        }


    }

    actions
    {
        addafter("&Print")
        {
            action(test2)
            {
                ApplicationArea = all;
                Caption = 'test call api';
                Image = PrintDocument;
                trigger OnAction()
                var
                    TempBlob: Record TempBlob temporary;
                    OutStr: OutStream;
                    RecRef: RecordRef;
                    Base64EncodedString: Text;
                    Base64Convert: Codeunit "Ibiz50 Base64Convert";
                    salesheader: Record "Sales Header";
                    callAPI: Codeunit callAPI;
                    Taxinvoice: Report "INT_Sales Invoice_SNY";
                begin
                    TempBlob.DeleteAll();

                    salesheader.reset;
                    salesheader.SetRange("Document Type", rec."Document Type");
                    salesheader.SetRange("No.", Rec."No.");
                    if salesheader.find('-') then begin
                        salesheader.TestField("Posting No.");
                        RecRef.GetTable(salesheader);
                        //Message('%1', RecRef);
                        TempBlob.Blob.CreateOutStream(OutStr);
                        Report.SaveAs(Report::INT_TH_Sales_Invoice, '', ReportFormat::Pdf, OutStr, RecRef);
                        Base64EncodedString := TempBlob.ToBase64String();
                        //Base64EncodedString := Base64Convert.TextToBase64String(Base64EncodedString);
                        Message(Base64EncodedString);
                        callAPI.sendAPI(Base64EncodedString)
                    end

                    //Base64Convert.StreamToBase64String
                end;
            }
        }
        // Add changes to page actions here
        addafter("Sales Reservation Avail.")
        {

            action(SalesInvoice)
            {
                ApplicationArea = All;
                Caption = 'Receipt / Tax Invoice';
                Image = PrintDocument;
                Promoted = true;
                Visible = true;
                PromotedCategory = Report;
                RunObject = report INT_TH_Sales_Invoice2;
                trigger OnAction()
                var
                    salesheader: Record "Sales Header";
                    SalesHeaderReport: Record "Sales Header";
                begin
                    //salesheader.Reset();
                    //CurrPage.SetSelectionFilter(salesheader);
                    //if salesheader.FindSet() then
                    //repeat
                    //Message('%1', salesheader."No.");
                    //Report.RunModal(60001, false, false, salesheader);
                    //if (salesheader.INT_DeliveryType_SNY = salesheader.INT_DeliveryType_SNY::"DBS Home") then
                    //    Report.RunModal(60006, false, false, salesheader);
                    //until salesheader.next = 0;
                end;
            }
            action(test)
            {
                ApplicationArea = all;
                Caption = 'test call api';
                Image = PrintDocument;
                trigger OnAction()
                var
                    TempBlob: Record TempBlob temporary;
                    OutStr: OutStream;
                    RecRef: RecordRef;
                    Base64EncodedString: Text;
                    Base64Convert: Codeunit "Ibiz50 Base64Convert";
                    salesheader: Record "Sales Header";
                    callAPI: Codeunit callAPI;
                    Taxinvoice: Report "INT_Sales Invoice_SNY";
                begin
                    TempBlob.DeleteAll();

                    salesheader.reset;
                    salesheader.SetRange("Document Type", rec."Document Type");
                    salesheader.SetRange("No.", Rec."No.");
                    if salesheader.find('-') then begin
                        salesheader.TestField("Posting No.");
                        RecRef.GetTable(salesheader);
                        //Message('%1', RecRef);
                        TempBlob.Blob.CreateOutStream(OutStr);
                        Report.SaveAs(Report::INT_TH_Sales_Invoice, '', ReportFormat::Pdf, OutStr, RecRef);
                        Base64EncodedString := TempBlob.ToBase64String();
                        //Base64EncodedString := Base64Convert.TextToBase64String(Base64EncodedString);
                        Message(Base64EncodedString);
                        callAPI.sendAPI(Base64EncodedString)
                    end

                    //Base64Convert.StreamToBase64String
                end;
            }

        }
    }

    var
        myInt: Integer;
}