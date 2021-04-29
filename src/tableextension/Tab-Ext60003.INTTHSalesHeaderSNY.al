tableextension 60003 "INT_TH_Sales_Header_SNY" extends "Sales Header"
{
    fields
    {
        // Add changes to table fields here
        field(60001; "INT_Order_Confirm_SNY"; Boolean)
        {
            Caption = 'Order Confirm';
            DataClassification = ToBeClassified;
            Editable = false;
        }
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
        field(60004; INT_Mask_SYN; Boolean)
        {
            Caption = 'Mask';
            DataClassification = ToBeClassified;
        }
        field(60005; "INT_BC Order Invoice No_SYN"; code[20])
        {
            caption = 'BC Order Invoice No.';
            DataClassification = ToBeClassified;
        }

    }

    var
        myInt: Integer;
}