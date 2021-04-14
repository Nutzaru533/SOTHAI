page 60006 "INT_Marketplace Card_SNY"
{
    Caption = 'Marketplace Card';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = INT_MarketPlaces_SNY;
    DeleteAllowed = false;
    PromotedActionCategories = 'New,Process,Report,Application Settings,System Settings,Currencies,Codes,Regional Settings';
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Marketplace; Marketplace)
                {
                    ApplicationArea = All;

                }
                field(Description; Description)
                {
                    ApplicationArea = all;
                }
                field(Channel; Channel)
                {
                    ApplicationArea = all;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = all;
                }
                field("Promo. Price Group"; "Promo. Price Group")
                {
                    ApplicationArea = all;
                }
                field("Seller ID"; "Seller ID")
                {
                    ApplicationArea = all;
                }
                field("Process ID"; "Process ID")
                {
                    ApplicationArea = all;
                }
                field("Sales Order Nos."; "Sales Order Nos.")
                {
                    ApplicationArea = all;
                }
                field("Sales Return Order Nos."; "Sales Return Order Nos.")
                {
                    ApplicationArea = all;
                }
                field("Inventory Tolerence %"; "Inventory Tolerence %")
                {
                    ApplicationArea = all;
                }
                field("Price Tolerence %"; "Price Tolerence %")
                {
                    ApplicationArea = all;
                }
                field(INT_Priority_SNY; INT_Priority_SNY)
                {
                    ApplicationArea = all;
                }
                field("INT_Allocation Percen_SNY"; "INT_Allocation Percen_SNY")
                {
                    ApplicationArea = all;
                }
                field(INT_Singatrue2_SNY; INT_Singatrue2_SNY)
                {
                    ApplicationArea = all;
                    Caption = 'Singatrue';
                    ToolTip = 'Specifies the picture that has been set up for the company, such as a company logo.';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                    end;
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