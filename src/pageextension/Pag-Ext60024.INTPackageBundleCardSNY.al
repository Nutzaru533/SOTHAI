pageextension 60024 INT_PackageBundleCard_SNY extends "INT_PackageBundleCard_SNY"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        modify(UpdateStatus)
        {
            Visible = false;
        }
        addafter(UpdateStatus)
        {
            action(UpdateStatus2)
            {
                ApplicationArea = All;
                Image = Approve;
                Promoted = false;
                Caption = 'Certify Package';
                trigger OnAction()
                var
                    BundleMgnt: Codeunit INT_BundleManagement_SNY;
                begin
                    CertifyBundleHeader(Rec);
                end;
            }
        }

    }

    var
        myInt: Integer;

    procedure CertifyBundleHeader(var BundleHeader: Record INT_BundleHeader_SNY);
    var
        ActivateLbl: Label 'Do you want to certify %1 Bundle No.: %2?', Comment = '%1 = Bundle Type; %2 = Bundle No.';
    begin
        BundleHeader.TestField(BundleHeader.Type, BundleHeader.Type::Package);
        BundleHeader.CheckStatus();
        ValidatePackage(BundleHeader);
        if not Confirm(StrSubstNo(ActivateLbl, BundleHeader.Type, BundleHeader."No."), false) then
            Error('');
        ActivateBundle(BundleHeader);
        Message('Certified Successfully!');
    end;

    local procedure ValidatePackage(var BundleHeader: Record INT_BundleHeader_SNY);
    begin
        ValidateHeaderFields(BundleHeader);
        BundleHeader.CalcFields("SRP Price", BundleHeader."Promotion Price");
        BundleHeader.TestField("SRP Price");
        BundleHeader.TestField("Promotion Price");
        CheckDuplicate(BundleHeader);
    end;

    Local procedure ActivateBundle(var BundleHeader: Record INT_BundleHeader_SNY);
    begin

        BundleHeader."Certified By" := copystr(userid(), 1, 50);
        BundleHeader."Certified Date" := Today();
        BundleHeader.Status := BundleHeader.Status::Certified;
        BundleHeader.UpdateStatus();
        BundleHeader."Is Active" := true;
        BundleHeader.Modify();
    end;

    local procedure ValidateHeaderFields(var BundleHeader: Record INT_BundleHeader_SNY);
    begin
        BundleHeader.TestField(Marketplace);
        if BundleHeader."Promotion Type" = BundleHeader."Promotion Type"::None then
            BundleHeader.TestField("Item No.");

        if BundleHeader."Promotion Type" = BundleHeader."Promotion Type"::"Item Discount" then begin
            BundleHeader.TestField("Period Start");
            BundleHeader.TestField("Period End");
        end else begin
            BundleHeader.TestField("Starting Date");
            BundleHeader.TestField("Ending Date");
        end;
    end;

    local procedure CheckDuplicate(BundleHeader: Record INT_BundleHeader_SNY);
    var
        BundleHeader2: Record INT_BundleHeader_SNY;
        BundleLine: Record INT_BundleLine_SNY;
        BundleLine2: Record INT_BundleLine_SNY;
        DuplicateHeaderErr: Label 'Duplicate Package find for overlapping period. \Package No. %1 \ Starting Date: %2 \Ending Date: %3', Comment = '%1 = Package No. %2-Starting Date, %3 - Ending Date';
        DuplicateLineErr: Label 'Duplicate Item Found in Lines. \Item No.: %1', Comment = '%1 = Item No.';
        BackupateDummyMsg: Label 'Package default dummy delivery fee is not configured!\Do you want to continue?';
        NoPackageLineErr: Label 'There is no package line with "Realted Item Type" as "Package"';
        MultipleDummyDeliveryErr: Label 'More than two default dummy delivery fee is configured! Please make only one line item as default';
    begin

        BundleLine.Reset();
        BundleLine.SetRange(Type, BundleHeader.Type);
        BundleLine.SetRange("No.", BundleHeader."No.");
        BundleLine.SetRange("Related Item Type", BundleLine."Related Item Type"::"Package");
        //if BundleLine.IsEmpty() then
        //    Error(NoPackageLineErr);

        BundleLine.SetRange("Main Item for Delivery", true);
        if BundleLine.Count() > 1 then
            Error(MultipleDummyDeliveryErr);

        //if BundleLine.IsEmpty() then
        //    if not confirm(BackupateDummyMsg, false) then
        //        Error('');

        //if BundleLine.FindFirst() then
        //repeat
        // BundleLine.TestField("Related Item No.");
        //until BundleLine.Next() = 0;


        //Check header duplicates
        BundleHeader2.Reset();
        BundleHeader2.SetRange(Type, BundleHeader2.Type::Package);
        BundleHeader2.SetRange("Item No.", BundleHeader."Item No.");
        //Added by Sri Filter only within Marketplace
        BundleHeader2.SetRange(BundleHeader2.Marketplace, BundleHeader.Marketplace);
        BundleHeader2.SetRange(Status, BundleHeader2.Status::Certified);
        if BundleHeader2.FindSet() then
            repeat
                if (BundleHeader."Starting Date" in [BundleHeader2."Starting Date", BundleHeader2."Ending Date"])
                 or (BundleHeader."Ending Date" in [BundleHeader2."Starting Date", BundleHeader2."Ending Date"]) then
                    Error(DuplicateHeaderErr, BundleHeader2."No.", BundleHeader2."Starting Date", BundleHeader2."Ending Date");
            until BundleHeader2.Next() = 0;

        //Line Duplicates
        BundleLine.Reset();
        BundleLine.SetRange(Type, BundleHeader.Type);
        BundleLine.SetRange("No.", BundleHeader."No.");
        if BundleLine.FindSet() then
            repeat
                BundleLine.TestField("Item No.");
                BundleLine.TestField(Quantity);
                BundleLine.TestField("SRP Price");
                BundleLine2.Reset();
                BundleLine2.SetRange(Type, BundleHeader.Type);
                BundleLine2.SetRange("No.", BundleHeader."No.");
                BundleLine2.SetFilter("line No.", '<>%1', BundleLine."Line No.");
                BundleLine2.SetRange("Item No.", BundleLine."Item No.");
                if not BundleLine2.IsEmpty() then
                    Error(DuplicateLineErr, BundleLine2."Item No.");
            until BundleLine.Next() = 0;


    end;

}