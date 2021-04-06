pageextension 60011 "INT_FOCBundleList_SNY" extends INT_FOCBundleList_SNY
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter(UpdateStatus)
        {
            action(INT_ImportSales_SNY)
            {
                caption = 'Import FOC';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = all;
                Image = Import;
                RunObject = page INT_ImportSalesList_SNY;
            }
        }

    }

    var
        myInt: Integer;
}