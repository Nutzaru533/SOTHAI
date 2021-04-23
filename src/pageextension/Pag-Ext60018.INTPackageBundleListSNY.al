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
                RunObject = xmlport INT_ImportPackage_SNY;
                PromotedOnly = true;
                PromotedCategory = Process;
                Visible = false;
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