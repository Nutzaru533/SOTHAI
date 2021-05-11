page 60009 "Checkerrorimport_Promotion"
{
    Caption = 'Import Check Error Promotion';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = INT_Temptableforimport;
    SourceTableView = sorting(sortno);


    layout
    {
        area(content)
        {
            repeater(Control1)
            {

                field(error; error) { ApplicationArea = all; }
                field(ErrorDes; ErrorDes) { ApplicationArea = all; }
                field(SortNo; SortNo) { ApplicationArea = all; }
                field(gNo; gNo) { ApplicationArea = all; }
                field(gDes; gDes) { ApplicationArea = all; }
                field(gMarketplace; gMarketplace) { ApplicationArea = all; }
                field(gStartingDate; gStartingDate) { ApplicationArea = all; }
                field(gEndingDate; gEndingDate) { ApplicationArea = all; }
                field(gLineItemNo; gLineItemNo) { ApplicationArea = all; }
                field(gQty; gQty) { ApplicationArea = all; }
                field(gSRPPriece; gSRPPriece) { ApplicationArea = all; }
                field(gPromotionalPrice; gPromotionalPrice) { ApplicationArea = all; }
                field(gRelated_Item_Type; gRelated_Item_Type) { ApplicationArea = all; }
                field(gStorageLocation; gStorageLocation) { ApplicationArea = all; }
                field(DocNo; DocNo)
                {
                    ApplicationArea = all;
                    Visible = true;
                }
                field(Type; Type)
                {
                    ApplicationArea = all;
                    Visible = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}