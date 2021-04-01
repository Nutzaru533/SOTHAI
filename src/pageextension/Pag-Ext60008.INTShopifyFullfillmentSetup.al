pageextension 60008 "INT_ShopifyFullfillmentSetup" extends "INT_Shopify Fullfillment Setup"
{
    layout
    {
        // Add changes to page layout here
        modify("Default Location")
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