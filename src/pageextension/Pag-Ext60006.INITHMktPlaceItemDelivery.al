pageextension 60006 "INI_TH_MktPlaceItem_Delivery" extends INT_MktPlaceItem_Delivery_Type
{
    layout
    {
        // Add changes to page layout here
        modify("Platform Product ID")
        {
            Visible = false;
        }
        modify("Platform SKU ID")
        {
            Visible = false;
        }
        modify("Seller SKU")
        {
            Visible = false;
        }
        modify(SRPPrice)
        {
            Visible = false;
        }
        modify(PromoPrice)
        {
            Visible = false;
        }
        modify("Inventory")
        {
            Visible = false;
        }
        modify("Is Master")
        {
            Visible = false;
        }
        modify("Active")
        {
            Visible = false;
        }
        modify("Url")
        {
            Visible = false;
        }
        modify("Order Type")
        {
            Visible = false;
        }
        modify(Name)
        {
            Visible = false;
        }
        modify("PublishDate")
        {
            Visible = false;
        }
        modify("PublishTime")
        {
            Visible = false;
        }
        modify("Product Code")
        {
            Visible = false;
        }
        modify(Published)
        {
            Visible = false;
        }
        modify(Historical)
        {
            Visible = false;
        }


    }

    actions
    {
        // Add changes to page actions here
    }

    //Variables, procedures and triggers are not allowed on Page Customizations
}