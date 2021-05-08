pageextension 60011 "INT_FOCBundleList_SNY" extends INT_FOCBundleList_SNY
{
    layout
    {
        addafter("No.")
        {
            field(Marketplace2; Marketplace)
            {
                ApplicationArea = all;
                Caption = 'Marketplace';
            }
        }
        addafter("No.")
        {
            field(INT_External_SYN; INT_External_SYN)
            {
                ApplicationArea = all;
            }
        }
        modify(Marketplace)
        {
            Visible = false;
        }
        // Add changes to page layout here
        modify("Free Gift ID")
        {
            Visible = false;
        }
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
                    caption = 'Import FOC';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = all;
                    Image = Import;
                    Visible = false;
                    RunObject = xmlport INT_ImportFOCHeader_SNY;
                    trigger OnAction()
                    var
                        myInt: Integer;
                    begin
                        //XMLPORT.RUN(60001, true, FALSE);
                        CurrPage.Update(false);
                    end;
                }
                action(INT_ImportFOCHeader_SNY3)
                {
                    caption = 'Import FOC';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = all;
                    Image = Import;
                    RunObject = xmlport INT_ImportFOCTemp_SNY;
                    trigger OnAction()
                    var
                        myInt: Integer;
                    begin
                        //XMLPORT.RUN(60001, true, FALSE);
                        CurrPage.Update(false);
                    end;
                }
                group(Checkerror)
                {
                    Caption = 'Check Error Import';
                    action(CheckErrorPage)
                    {
                        caption = 'Check Error';
                        Promoted = true;
                        PromotedOnly = true;
                        PromotedCategory = Process;
                        ApplicationArea = all;
                        Image = Import;

                        trigger OnAction()
                        var
                            INT_Temptableforimport: Record INT_Temptableforimport;
                            Checkerrorimport: Page Checkerrorimport;
                        begin
                            Clear(Checkerrorimport);
                            INT_Temptableforimport.reset;
                            INT_Temptableforimport.SetRange(foc, true);
                            INT_Temptableforimport.SetRange(error, true);
                            INT_Temptableforimport.SetFilter(errordes, '<>%1', '');
                            Checkerrorimport.SetTableView(INT_Temptableforimport);
                            Checkerrorimport.run;
                            CurrPage.Update(false);
                        end;
                    }
                }

            }
        }

    }

    var
        myInt: Integer;
}