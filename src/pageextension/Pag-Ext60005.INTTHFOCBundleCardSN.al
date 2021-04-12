pageextension 60005 "INT_TH_FOCBundleCard_SN" extends INT_FOCBundleCard_SNY
{

    layout
    {
        // Add changes to page layout here
        addafter(isActive)
        {
            field(FOCMessage; FOCMessage)
            {
                Caption = 'FOC Message';
                Editable = false;
                ApplicationArea = all;
                Style = StrongAccent;
            }
        }
        addbefore("No.")
        {
            field(Marketplace1; Marketplace)
            {
                Caption = 'MarketPlace';
                ApplicationArea = all;
                trigger OnValidate()
                var
                    myInt: Integer;
                begin
                    if "No." = '' then
                        NewDoc;
                    CurrPage.Update(false);
                end;
            }

        }
        addafter("Activated By")
        {
            field(INT_External_SYN; INT_External_SYN)
            {
                ApplicationArea = all;
            }
        }
        modify(isActive)
        {
            Editable = false;
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                CheckAmount2
            end;
        }
        modify("Activated Date")
        {
            Editable = false;
        }
        modify("Activated By")
        {
            Editable = false;
        }
        modify("Free Gift ID")
        {
            Visible = false;
        }
        modify(Marketplace)
        {
            Visible = false;
        }


    }

    actions
    {

        // Add changes to page actions here
        /*
        addfirst(Processing)
        {
            action(NewDoc)
            {
                Caption = 'New Document No.';
                Image = New;
                ApplicationArea = All;
                Promoted = true;
                trigger OnAction()
                begin
                    NewDoc();
                end;
            }
        }
        */
        addfirst(Processing)
        {
            action(CertifyFOC)
            {
                Caption = 'Certify Foc';
                Image = Approval;
                ApplicationArea = All;

                trigger OnAction()
                begin

                    "Is Active" := true;
                    "Activated By" := UserId;
                    "Activated Date" := today;
                    Modify();
                    CurrPage.Update(false);
                end;
            }
            action(UnCertifyFOC)
            {
                Caption = 'Un Certify Foc';
                Image = Reject;
                ApplicationArea = All;

                trigger OnAction()
                begin

                    "Is Active" := false;
                    "Activated By" := '';
                    "Activated Date" := 0D;
                    Modify();
                    CurrPage.Update(false);
                end;
            }
        }
    }
    var
        myInt: Integer;
        FOCMessage: text[100];

    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        //CheckAmount;
        if ("No." = '') then
            CurrPage.Update(false);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if ("No." = '') then
            CurrPage.Update(false);
    end;

    local procedure CheckAmount()
    var
        INT_BundleLine_SNY: Record INT_BundleLine_SNY;
        checksrpprice: Decimal;
        checkPromotionPrice: Decimal;
        checkline: Boolean;
    begin
        Clear(FOCMessage);
        INT_BundleLine_SNY.reset;
        INT_BundleLine_SNY.SetRange("No.", rec."No.");
        if INT_BundleLine_SNY.Find('-') then begin
            repeat
                INT_BundleLine_SNY.CalcSums("SRP Price");
                INT_BundleLine_SNY.CalcSums("Promotional Price");
                checksrpprice += INT_BundleLine_SNY."SRP Price";
                checkPromotionPrice += INT_BundleLine_SNY."Promotional Price";
            until INT_BundleLine_SNY.Next = 0;
            if checksrpprice <> 0 then
                FOCMessage := 'SRP Sum Amount Should equal to zero'
            else
                FOCMessage := '';

            if checkPromotionPrice <> 0 then
                FOCMessage := 'Promotional Amount Should equal to zero '
            else
                FOCMessage := '';
        end;
    end;

    local procedure CheckAmount2()
    var
        INT_BundleLine_SNY: Record INT_BundleLine_SNY;
        checksrpprice: Decimal;
        checkPromotionPrice: Decimal;
        checkline: Boolean;
    begin
        Clear(FOCMessage);
        INT_BundleLine_SNY.reset;
        INT_BundleLine_SNY.SetRange("No.", rec."No.");
        if INT_BundleLine_SNY.Find('-') then begin
            repeat
                INT_BundleLine_SNY.CalcSums("SRP Price");
                INT_BundleLine_SNY.CalcSums("Promotional Price");
                checksrpprice += INT_BundleLine_SNY."SRP Price";
                checkPromotionPrice += INT_BundleLine_SNY."Promotional Price";
            until INT_BundleLine_SNY.Next = 0;
            if checksrpprice <> 0 then
                Error('SRP Sum Amount Should equal to zero');
            if checkPromotionPrice <> 0 then
                error('Promotional Amount Should equal to zero');
        end;
    end;



}