tableextension 60001 "INT_TH_Item" extends item
{
    fields
    {
        // Add changes to table fields here
        field(60001; "TH Exclude Discount"; Boolean)
        {
            Caption = 'Exclude Discount';
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}