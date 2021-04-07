pageextension 60011 "INT_FOCBundleList_SNY" extends INT_FOCBundleList_SNY
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter(UpdateStatus)
        {
            group(FOCinport)
            {
                Caption = 'FOC Import';

                action(INT_ImportFOCHeader_SNY)
                {
                    caption = 'Import FOC Header';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = all;
                    Image = Import;
                    RunObject = xmlport INT_ImportFOCHeader_SNY;
                    trigger OnAction()
                    var
                        myInt: Integer;
                    begin
                        CurrPage.Update(false);
                    end;
                }
                action(INT_ImportFOCLine_SNY)
                {
                    caption = 'Import FOC Line';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = all;
                    Image = Import;
                    RunObject = xmlport INT_ImportFOCLines_SNY;
                    trigger OnAction()
                    var
                        myInt: Integer;
                    begin
                        CurrPage.Update(false);
                    end;
                }
            }
        }

    }

    var
        myInt: Integer;
}