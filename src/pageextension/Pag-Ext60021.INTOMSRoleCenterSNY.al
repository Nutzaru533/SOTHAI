pageextension 60021 "INT_OMSRoleCenter_SNY" extends INT_OMSRoleCenter_SNY
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter(DeliveryDummy)
        {
            action(ActionName)
            {
                Caption = 'Flash Sales Price';

                RunObject = Page INT_FlashSalesPrice_SNY;
                ApplicationArea = All;
            }

        }
    }

    var
        myInt: Integer;
}