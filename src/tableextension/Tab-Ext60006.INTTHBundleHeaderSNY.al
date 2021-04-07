tableextension 60006 "INT_TH_BundleHeader_SNY" extends INT_BundleHeader_SNY
{
    fields
    {


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
}