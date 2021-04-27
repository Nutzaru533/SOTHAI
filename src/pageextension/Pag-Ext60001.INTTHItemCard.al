pageextension 60001 "INT_TH_Item_Card" extends "Item Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("Purchasing Code")
        {
            field("Exclude Discount"; INT_Inclusive_Discount_SNY)
            {
                Caption = 'Inclusive Discount';
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        modify(INT_CopyMain_SNY)
        {
            Visible = false;
        }
        addafter(INT_CopyMain_SNY)
        {
            action("INT_CopyMain_SNY2")
            {
                ApplicationArea = All;
                Caption = 'Copy Main Model Details';
                Image = Copy;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ItemCopy: Codeunit INT_ItemCopy2_SNY;
                begin
                    TestField(INT_MainModel_SNY);
                    if not Confirm(StrSubstNo('Do you want to copy details of Main Model %1?\It will replace with new values!!! ', INT_MainModel_SNY), false) then
                        Error('');

                    ItemCopy.CopyMainModeDetails(rec);
                    Message('Copied Details');
                end;
            }
        }
    }

    var
        myInt: Integer;
}