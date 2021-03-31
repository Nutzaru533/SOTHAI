pageextension 60001 "INT_TH_Item_Card" extends "Item Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("Purchasing Code")
        {
            field("Exclude Discount"; INT_Exclude_Discount_SNY)
            {
                Caption = 'Exclude Discount';
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}