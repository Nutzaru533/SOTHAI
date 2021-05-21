pageextension 60025 "INT_ByItemDiscCard_SNY" extends INT_ByItemDiscCard_SNY
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }
    trigger OnDeleteRecord(): boolean
    var
        myInt: Integer;
        iNT_PromoMkt_SNY: Record iNT_PromoMkt_SNY;
    begin
        iNT_PromoMkt_SNY.reset;
        iNT_PromoMkt_SNY.SetRange("Promotion No.", "No.");
        iNT_PromoMkt_SNY.SetRange(Marketplace, Marketplace);
        iNT_PromoMkt_SNY.SetRange(Published, true);
        if iNT_PromoMkt_SNY.Find('-') then begin
            error('Promotion Published can not delete');
        end;
    end;

    var
        myInt: Integer;


}