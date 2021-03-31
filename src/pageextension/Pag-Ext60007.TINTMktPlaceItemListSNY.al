pageextension 60007 "TINT_MktPlaceItemList_SNY" extends "INT_MktPlaceItemList_SNY"
{
    layout
    {
        // Add changes to page layout here
        modify(Active)
        {
            Visible = false;
        }
        addafter("Is Master")
        {
            field(INT_Active_SNY; INT_Active_SNY)
            {
                Caption = 'Active';
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