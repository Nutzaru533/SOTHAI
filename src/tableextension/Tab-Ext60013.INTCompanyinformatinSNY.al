tableextension 60013 "INT_Company_informatin_SNY" extends "Company Information"
{
    fields
    {
        // Add changes to table fields here
        field(60001; INT_Name_TH_SNY; text[100])
        {
            Caption = 'Name Thai';
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}