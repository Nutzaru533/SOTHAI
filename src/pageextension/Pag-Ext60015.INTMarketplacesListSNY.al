pageextension 60015 "INT_MarketplacesList_SNY" extends INT_MarketplacesList_SNY
{
    caption = 'Marketplaces';

    //CardPageID = "INT_Marketplace Card_SNY";
    layout
    {
        // Add changes to page layout here
        addafter(INT_Signature_SNY)
        {
            field(INT_Singatrue2_SNY; INT_Singatrue2_SNY)
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the picture that has been set up for the company, such as a company logo.';

                trigger OnValidate()
                begin
                    CurrPage.SaveRecord;
                end;
            }
        }
        modify(INT_Signature_SNY)
        {
            Visible = false;
        }

    }

    actions
    {
        // Add changes to page actions here

    }

    var
        myInt: Integer;
}