pageextension 60023 "INT_PkgBundleLine_SNY" extends INT_PkgBundleLine_SNY
{
    layout
    {
        // Add changes to page layout here
        modify("Promotional Price")
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                if "Promotional Price" > "SRP Price" then
                    error('SRP Price should be greater then Promotion Price !!');
            end;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}