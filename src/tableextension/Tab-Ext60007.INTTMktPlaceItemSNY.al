tableextension 60007 "INT_T_MktPlaceItem_SNY" extends INT_MktPlaceItem_SNY
{
    fields
    {
        // Add changes to table fields here
        field(60007; INT_Active_SNY; Boolean)
        {
            Caption = 'Active';
            DataClassification = ToBeClassified;
        }
        field(60008; INT_Inventory_SNY; Decimal)
        {
            Caption = 'Inventory';
            DataClassification = ToBeClassified;
        }

    }

    var
        myInt: Integer;
}