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
    }

    var
        myInt: Integer;
}