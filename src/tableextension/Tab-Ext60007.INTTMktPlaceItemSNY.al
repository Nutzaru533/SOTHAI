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
    }

    var
        myInt: Integer;
}