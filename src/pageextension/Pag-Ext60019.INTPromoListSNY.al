pageextension 60019 "INT_PromoList_SNY" extends INT_PromoList_SNY
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter(ViewFOC)
        {
            action(ImportPackage)
            {
                ApplicationArea = All;
                Caption = 'Import Package Bundle';
                Image = Import;
                //Promoted = true;
                RunObject = xmlport INT_ImportPromotion_SNY;
                //PromotedOnly = true;
                //PromotedCategory = Process;
                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        myInt: Integer;
}