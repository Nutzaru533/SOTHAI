pageextension 60014 "INT_Sales_retunr_OrderLine_SNY" extends "Sales Return Order Subform"
{
    layout
    {
        // Add changes to page layout here
        modify("Location Code")
        {
            Editable = confirmreturn;
        }
    }

    actions
    {
        // Add changes to page actions here

    }

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        Lock_location();
    end;

    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin
        Lock_location();
    end;

    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        Lock_location();
    end;

    var
        myInt: Integer;
        salesheader: Record "Sales Header";
        confirmreturn: Boolean;

    local procedure Lock_location()
    var
        myInt: Integer;
    begin
        salesheader.reset;
        salesheader.SetRange("Document Type", "Document Type");
        salesheader.SetRange("No.", "Document No.");
        if salesheader.find('-') then begin
            confirmreturn := not salesheader.INT_Order_Confirm_SNY;
        end;
    end;
}