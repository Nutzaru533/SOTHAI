tableextension 60001 "INT_TH_Item_SNY" extends item
{
    fields
    {
        // Add changes to table fields here
        field(60001; "INT_Exclude_Discount_SNY"; Boolean)
        {
            Caption = 'Exclude Discount';
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}