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
                Visible = false;
                //Promoted = true;
                RunObject = xmlport INT_ImportPromotion_SNY;
                //PromotedOnly = true;
                //PromotedCategory = Process;
                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;

            }
            action(ImportPackage2)
            {
                ApplicationArea = All;
                Caption = 'Import Package Bundle';
                Image = Import;
                Visible = true;
                //Promoted = true;
                RunObject = xmlport INT_ImportPromotionTemp_SNY;
                //PromotedOnly = true;
                //PromotedCategory = Process;
                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;

            }
            action(ImportPackage3)
            {
                ApplicationArea = All;
                Caption = 'Error Page';
                Image = Import;
                Visible = true;
                //Promoted = true;
                //RunObject = xmlport INT_ImportPromotionTemp_SNY;
                //PromotedOnly = true;
                //PromotedCategory = Process;
                trigger OnAction()
                var
                    INT_Temptableforimport: Record INT_Temptableforimport;
                    Checkerrorimport: Page Checkerrorimport_Promotion;
                begin
                    Clear(Checkerrorimport);
                    INT_Temptableforimport.reset;
                    INT_Temptableforimport.SetRange(foc, false);
                    INT_Temptableforimport.SetFilter(errordes, '<>%1', '');
                    Checkerrorimport.SetTableView(INT_Temptableforimport);
                    Checkerrorimport.run;
                    CurrPage.Update(false);
                end;

            }

        }

    }



    var
        myInt: Integer;
}