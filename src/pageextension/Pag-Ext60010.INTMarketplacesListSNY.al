pageextension 60010 "INT_MarketplacesList_SNY" extends INT_MarketplacesList_SNY
{
    layout
    {
        // Add changes to page layout here
        addafter("Promotion Tolerence %")
        {
            field(INT_Signature_SNY; INT_Signature_SNY)
            {
                ApplicationArea = all;
            }
            field(INT_Priority_SNY; INT_Priority_SNY)
            {
                ApplicationArea = all;
            }
            field("INT_Allocation Percen_SNY"; "INT_Allocation Percen_SNY")
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