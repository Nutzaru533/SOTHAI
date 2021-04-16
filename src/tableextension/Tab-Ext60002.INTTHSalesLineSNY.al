tableextension 60002 "INT_TH_Sales_Line_SNY" extends "Sales Line"
{
    fields
    {
        field(60001; INT_Exclude_Discount_SNY; Boolean)
        {
            Caption = 'Exclude Discount';
            FieldClass = FlowField;
            CalcFormula = lookup(item.INT_Inclusive_Discount_SNY where("No." = FIELD("No.")));

        }
    }

    var
        myInt: Integer;
}