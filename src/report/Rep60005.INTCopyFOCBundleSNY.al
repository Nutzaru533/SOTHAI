report 60005 "INT_CopyFOCBundle_SNY"
{
    Caption = 'Copy Package Bundle';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    requestpage
    {
        Caption = 'Filter';
        layout
        {
            area(Content)
            {
                group(GroupName)
                {


                    field(CopyFromPackageNo; CopyFromPackageNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Copy From FOC No.';
                        TableRelation = INT_BundleHeader_SNY."No." where(Type = filter(FOC));
                    }

                    field(CopyToPackageNo; CopyToPackageNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Copy To FOC No.';
                        Editable = false;
                    }
                    field(StartingDate; StartingDate)
                    {

                        Caption = 'Starting Date';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field(EndingDate; EndingDate)
                    {
                        Caption = 'Ending Date';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                }
            }
        }

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            DateBlankErr: Label 'Starting and Ending date must have value!\\Ending date should be greater than starting date!';
            SameCopyErr: Label 'Copy From and To Package No. cannot be same';
            PackageNoBlankErr: Label 'Copy From and To Package No. cannot be blank';
        begin
            if CloseAction = Action::ok then begin
                if (StartingDate = 0D) OR (EndingDate = 0D) or (StartingDate > EndingDate) THEN
                    Error(DateBlankErr);
                if (CopyFromPackageNo = '') or (CopyToPackageNo = '') then
                    Error(SameCopyErr);
                if CopyFromPackageNo = CopyToPackageNo then
                    Error(SameCopyErr);
            end;
        end;

    }

    var
        CopyFromPackageNo: code[20];
        CopyToPackageNo: Code[20];
        Type: Option FOC,Package;
        StartingDate: Date;
        EndingDate: Date;

    trigger OnPostReport()
    begin
        CopyToPackage(CopyFromPackageNo);
    end;


    procedure InitPackageNo(pType: Option FOC,Package; pPackageNo: code[20])
    var
    begin
        Type := pType;
        CopyToPackageNo := pPackageNo;
    end;

    procedure CopyToPackage(pCopyFromPackageNo: code[20])
    var
        FromBundleHeader: Record INT_BundleHeader_SNY;
        FromBundleLine: Record INT_BundleLine_SNY;
        ToBundleHeader: Record INT_BundleHeader_SNY;
        ToBundleLine: Record INT_BundleLine_SNY;
        DateBlankErr: Label 'Starting and Ending date must have value!\\Ending date should be greater than starting date!';
        SameCopyErr: Label 'Copy From and To Package No. cannot be same';
        PackageNoBlankErr: Label 'Copy From and To Package No. cannot be blank';
        guid: Guid;
    begin
        if (StartingDate = 0D) OR (EndingDate = 0D) or (StartingDate > EndingDate) THEN
            Error(DateBlankErr);
        if (pCopyFromPackageNo = '') or (CopyToPackageNo = '') then
            Error(SameCopyErr);
        if pCopyFromPackageNo = CopyToPackageNo then
            Error(SameCopyErr);

        FromBundleHeader.get(Type, CopyFromPackageNo);
        ToBundleHeader.get(Type, CopyToPackageNo);
        ToBundleLine.Reset();
        ToBundleLine.SetRange(Type, ToBundleHeader.Type);
        ToBundleLine.SetRange("No.", ToBundleHeader."No.");
        if not ToBundleLine.IsEmpty() then
            ToBundleLine.Delete(true);

        //Copy Headers
        ToBundleHeader.Marketplace := FromBundleHeader.Marketplace;
        ToBundleHeader.Validate("Item No.", FromBundleHeader."Item No.");
        ToBundleHeader.Description := FromBundleHeader.Description;
        ToBundleHeader."Starting Date" := StartingDate;
        ToBundleHeader."Ending Date" := EndingDate;
        ToBundleHeader.Status := ToBundleHeader.Status::"Config WIP";
        clear(ToBundleHeader."Certified By");
        clear(ToBundleHeader."Certified Date");
        clear(ToBundleHeader."Is Active");
        clear(ToBundleHeader."Activated By");
        clear(ToBundleHeader."Activated Date");
        ToBundleHeader.Modify();

        //Copy Lines
        FromBundleLine.Reset();
        FromBundleLine.SetRange(Type, FromBundleHeader.Type);
        FromBundleLine.SetRange("No.", FromBundleHeader."No.");
        if FromBundleLine.FindSet() then
            repeat
                ToBundleLine := FromBundleLine;
                ToBundleLine.Type := Type;
                ToBundleLine."Free Gift ID" := CopyToPackageNo;
                ToBundleLine."No." := CopyToPackageNo;
                ToBundleLine.Insert(true);
                ToBundleLine.Validate(Quantity);
                ToBundleLine.Modify(true);
            until FromBundleLine.Next() = 0;
        Commit();
    end;
}