tableextension 60015 "INT_Sales Price_SYN" extends "Sales Price"
{
    fields
    {
        // Add changes to table fields here.
        modify("Unit Price")
        {
            trigger OnBeforeValidate()
            var
                myInt: Integer;
                salesprice: Record "Sales Price";
            begin
                if "Sales Code" = 'LAZ PRO' then begin
                    salesprice.reset;
                    salesprice.SetRange("Item No.", "Item No.");
                    salesprice.SetRange("Sales Type", salesprice."Sales Type"::"All Customers");
                    salesprice.SetRange("Unit of Measure Code", "Unit of Measure Code");
                    if salesprice.Find('-') then begin
                        if "Unit Price" > salesprice."Unit Price" then begin
                            Error('Promo price should be less than SRP price');
                        end;
                    end;
                end;
            end;
        }
    }

    var
        myInt: Integer;
}