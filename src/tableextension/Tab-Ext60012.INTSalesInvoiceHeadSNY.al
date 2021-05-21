tableextension 60012 "INT_SalesInvoice_Head_SNY" extends "Sales Invoice Header"
{
    fields
    {
        // Add changes to table fields here
        field(60002; INT_Print_Count_SNY; Integer)
        {
            Caption = 'Print Count';
            DataClassification = ToBeClassified;
        }
        field(60003; INT_Print_Date_Time_SNY; datetime)
        {
            Caption = 'Print Date&time';
            DataClassification = ToBeClassified;
        }
        field(60006; INT_PrintAWB_Count_SNY; Integer)
        {
            Caption = 'Print AWB Count';
            DataClassification = ToBeClassified;
        }
        field(60007; INT_PrintAWB_Date_Time_SNY; datetime)
        {
            Caption = 'Print AWB Date&time';
            DataClassification = ToBeClassified;
        }

    }

    var
        myInt: Integer;
}