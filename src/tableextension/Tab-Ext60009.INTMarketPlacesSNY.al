tableextension 60009 "INT_MarketPlaces_SNY" extends INT_MarketPlaces_SNY
{
    fields
    {
        // Add changes to table fields here
        // Add changes to table fields here
        field(60001; INT_Signature_SNY; Blob)
        {
            Caption = 'Signature';
            DataClassification = ToBeClassified;
        }
        field(60002; INT_Priority_SNY; Decimal)
        {
            Caption = 'Priority';
            DataClassification = ToBeClassified;
        }
        field(60003; "INT_Allocation Percen_SNY"; Integer)
        {
            Caption = 'Allocation %';
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}