pageextension 60009 "INT_Inven_Setup_SNY" extends "Inventory Setup"
{
    layout
    {
        // Add changes to page layout here  
        addafter("Copy Item Descr. to Entries")
        {
            field(INT_Item_Allocation_SNY; INT_Item_Allocation_SNY)
            {
                ApplicationArea = all;
            }
            field(INT_LOCATION_MAIN; INT_LOCATION_MAIN)
            {
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