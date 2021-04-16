tableextension 60001 "INT_TH_Item_SNY" extends item
{
    fields
    {
        // Add changes to table fields here
        field(60001; "INT_Inclusive_Discount_SNY"; Boolean)
        {
            Caption = 'Inclusive Discount';
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}