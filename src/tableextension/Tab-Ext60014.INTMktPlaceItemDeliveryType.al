tableextension 60014 "INT_MktPlaceItemDelivery_Type" extends INT_MktPlaceItem_Delivery_Type
{

    fields
    {
        // Add changes to table fields here
    }
    trigger OnInsert()
    var
        itemMrk: Record INT_MktPlaceItem_SNY;
    begin
        itemMrk.reset;
        itemMrk.SetRange("Item No.", "Item No.");
        itemMrk.SetRange(Marketplace, Marketplace);
        itemMrk.SetRange(INT_DeliveryType_SNY, INT_DeliveryType_SNY);
        if itemMrk.Find('-') then
            error('Delivery type already have in Item Marketplace !!!');
    end;

    var
        myInt: Integer;
}