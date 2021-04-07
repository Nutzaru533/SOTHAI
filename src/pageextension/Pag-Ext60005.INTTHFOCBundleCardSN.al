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
        modify(isActive)
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                CheckAmount2
            end;
        }
        modify(Marketplace)
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                NewDoc;
            end;
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
    }
    var
        myInt: Integer;
        FOCMessage: text[100];

    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        CheckAmount;

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

    local procedure NewDoc()
    var
        myInt: Integer;
        FOCHead: Record INT_BundleHeader_SNY;
        noserialMgn: Codeunit NoSeriesManagement;
        InterfaceSetup: Record INT_InterfaceSetup_SNY;
        focheadPage: page INT_FOCBundleCard_SNY;
    begin
        InterfaceSetup.get;

        "Free Gift ID" := 'Temp Free Fift ID';
        Type := Type::FOC;
        "No." := noserialMgn.GetNextNo(InterfaceSetup."FOC No. Series", workdate, true);
        "No. Series" := InterfaceSetup."FOC No. Series";
        Insert();
        Commit();

    end;
}