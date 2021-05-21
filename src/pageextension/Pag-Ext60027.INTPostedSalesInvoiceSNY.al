pageextension 60027 "INT_Posted_SalesInvoice_SNY" extends "Posted Sales Invoice"
{
    layout
    {
        // Add changes to page layout here
        addafter(Closed)
        {
            field(INT_Print_Date_Time_SNY; rec.INT_Print_Date_Time_SNY)
            {
                ApplicationArea = all;
            }
            field(INT_Print_Count_SNY; INT_Print_Count_SNY)
            {
                ApplicationArea = all;
            }
            field(INT_PrintAWB_Date_Time_SNY; INT_PrintAWB_Date_Time_SNY)
            {
                ApplicationArea = all;
            }
            field(INT_PrintAWB_Count_SNY; INT_PrintAWB_Count_SNY)
            {
                ApplicationArea = all;
            }

        }

    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}