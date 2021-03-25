pageextension 60005 TH_INT_FOCBundleCard_SN extends INT_FOCBundleCard_SNY
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

    }

    actions
    {

        // Add changes to page actions here
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


}