tableextension 60010 "INT_USER_SETUP_SNY" extends "User Setup"
{
    fields
    {
        // Add changes to table fields here
        field(60000; INT_Unmark_SNY; Boolean)
        {
            Caption = 'Unmark';
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}