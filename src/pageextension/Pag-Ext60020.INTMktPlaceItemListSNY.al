pageextension 60020 "INT_MktPlaceItemList_SNY" extends INT_MktPlaceItemList_SNY
{

    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter(UpdatePriceSelectedLines2)
        {

            action(itemMrkdeliver)
            {
                ApplicationArea = All;
                Caption = 'Item Market Delivery';
                Image = Delivery;
                //Promoted = true;
                //RunObject = page INT_MktPlaceItem_Delivery_Type;
                //RunPageLink = "Item No." = field("Item No."), Marketplace = field(Marketplace);
                trigger OnAction()
                var
                    INT_MktPlaceItem_Delivery_Type: Record INT_MktPlaceItem_Delivery_Type;
                    Mktplacelist: page INT_MktPlaceItem_Delivery_Type;
                begin
                    INT_MktPlaceItem_Delivery_Type.reset;
                    INT_MktPlaceItem_Delivery_Type.SetRange("Item No.", "Item No.");
                    INT_MktPlaceItem_Delivery_Type.SetRange(Marketplace, Marketplace);
                    if INT_MktPlaceItem_Delivery_Type.Find('-') then begin
                        Clear(Mktplacelist);
                        Mktplacelist.SetTableView(INT_MktPlaceItem_Delivery_Type);
                        Mktplacelist.Run();
                    end else begin
                        Clear(Mktplacelist);
                        Mktplacelist.SetTableView(INT_MktPlaceItem_Delivery_Type);
                        Mktplacelist.Run();
                    end;

                end;

            }
        }
    }

    var
        myInt: Integer;
}