pageextension 60022 "INT_SalesLine_Subform_SYN" extends "Sales Order Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter("Original Item No")
        {
            field("INT_New Description_SYN"; "INT_New Description_SYN")
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