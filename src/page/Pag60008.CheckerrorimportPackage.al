page 60008 "Checkerrorimport_Package"
{
    Caption = 'Import Check Error Package';
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

                }
                field(Type; Type)
                {
                    ApplicationArea = all;

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