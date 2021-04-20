tableextension 60011 "INT_MarketPlaces_SNY" extends INT_MarketPlaces_SNY
{
    fields
    {
        // Add changes to table fields here

        field(60000; INT_Singatrue2_SNY; Blob)
        {
            Caption = 'Singatrue';
            SubType = Bitmap;
        }

    }

    var
        myInt: Integer;
}