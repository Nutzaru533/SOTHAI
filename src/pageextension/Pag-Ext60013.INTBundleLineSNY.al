pageextension 60013 "INT_BundleLine_SNY" extends INT_BundleLine_SNY
{
    layout
    {
        // Add changes to page layout here
        modify("Free Gift ID")
        {
            Visible = false;
        }
        addafter("Storage Location")
        {
            field(INT_External_SYN; INT_External_SYN)
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