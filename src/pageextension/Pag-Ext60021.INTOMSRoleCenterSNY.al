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
        addafter(Setup)
        {
            group(Repoprt)
            {
                Caption = 'Report';
                ToolTip = 'Marketplaces List';
                Image = Report;
                action(VaTReport)
                {
                    Caption = 'Vat Report';
                    ToolTip = 'Marketplaces List';
                    RunObject = report INT_VAT_REPORT;
                    ApplicationArea = All;

                }
            }
        }
    }

    var
        myInt: Integer;
}