pageextension 60018 "INT_PackageBundleList_SNY" extends INT_PackageBundleList_SNY
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addfirst(Processing)
        {
            action(ImportPackage)
            {
                ApplicationArea = All;
                Caption = 'Import Package Bundle';
                Image = Import;
                Promoted = true;
                RunObject = xmlport INT_ImportPromotion_SNY;
                PromotedOnly = true;
                PromotedCategory = Process;
                Visible = false;
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
                Promoted = true;
                RunObject = xmlport INT_ImportPromotionTemp_SNY;
                PromotedOnly = true;
                PromotedCategory = Process;
                Visible = true;
                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
            action(ImportPackage3)
            {
                ApplicationArea = All;
                Caption = 'Check Error';
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Visible = true;
                trigger OnAction()
                var
                    INT_Temptableforimport: Record INT_Temptableforimport;
                    Checkerrorimport: Page Checkerrorimport_Package;
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