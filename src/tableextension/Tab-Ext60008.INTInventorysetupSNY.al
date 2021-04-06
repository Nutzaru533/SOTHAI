tableextension 60008 "INT_Inventory_setup_SNY" extends "Inventory Setup"
{
    fields
    {
        // Add changes to table fields here
        field(60001; "INT_Item_Allocation_SNY"; Boolean)
        {
            Caption = 'Calculate Item Allocaltion (TH)';
            DataClassification = ToBeClassified;
        }
        field(60002; "INT_LOCATION_MAIN"; code[20])
        {
            Caption = 'MAIN Location';
            TableRelation = Location;
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}