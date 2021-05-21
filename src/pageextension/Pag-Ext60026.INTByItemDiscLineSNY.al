pageextension 60026 "INT_ByItemDiscLine_SNY" extends INT_ByItemDiscLine_SNY
{
    layout
    {
        // Add changes to page layout here
        modify("Promotional Price")
        {
            trigger OnBeforeValidate()
            var
                myInt: Integer;
            begin
                if rec."SRP Price" < rec."Promotional Price" then
                    Error('Promo price should be less than SRP price');
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