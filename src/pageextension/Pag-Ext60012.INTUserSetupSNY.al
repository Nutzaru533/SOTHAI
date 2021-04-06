pageextension 60012 "INT_User_Setup_SNY" extends "User Setup"
{
    layout
    {
        // Add changes to page layout here
        addafter(Marketplace)
        {
            field(INT_Unmark_SNY; INT_Unmark_SNY)
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