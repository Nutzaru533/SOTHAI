tableextension 60006 "INT_TH_BundleHeader_SNY" extends INT_BundleHeader_SNY
{
    fields
    {
        field(60001; INT_External_SYN; code[20])
        {
            Caption = 'External No.';
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        INT_InterfaceSetup_SNY: Record INT_InterfaceSetup_SNY;

    trigger OnBeforeInsert()
    var

    begin
    end;

    trigger OnInsert()
    var

    begin
        //InitInsert;
    end;

    procedure InitInsert()
    var
        myInt: Integer;
    begin
        INT_InterfaceSetup_SNY.get;
        if "No." = '' then begin
            NoSeriesMgt.InitSeries(INT_InterfaceSetup_SNY."FOC No. Series", xRec."No. Series", WorkDate, "No.", "No. Series");
        end;

    end;

    procedure NewDoc()
    var
        myInt: Integer;
        FOCHead: Record INT_BundleHeader_SNY;
        noserialMgn: Codeunit NoSeriesManagement;
        InterfaceSetup: Record INT_InterfaceSetup_SNY;
        focheadPage: page INT_FOCBundleCard_SNY;
    begin
        InterfaceSetup.get;
        Type := Type::FOC;
        "No. Series" := InterfaceSetup."FOC No. Series";
        "No." := noserialMgn.GetNextNo(InterfaceSetup."FOC No. Series", workdate, true);
        "Free Gift ID" := "No.";
        insert;

    end;
}