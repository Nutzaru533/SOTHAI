tableextension 60003 "INT_TH_Sales_Header_SNY" extends "Sales Header"
{
    fields
    {
        // Add changes to table fields here
        field(60001; "INT_Order_Confirm_SNY"; Boolean)
        {
            Caption = 'Order Confirm';
            DataClassification = ToBeClassified;
            Editable = false;
        }

    }

    var
        myInt: Integer;
}