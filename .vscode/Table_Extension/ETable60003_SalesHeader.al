tableextension 60003 "TH Sales Header" extends "Sales Header"
{
    fields
    {
        // Add changes to table fields here
        field(60001; "TH Order Confirm"; Boolean)
        {
            Caption = 'Order Confirm';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    var
        myInt: Integer;
}