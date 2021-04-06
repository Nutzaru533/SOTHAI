tableextension 60004 "INT_TH_BundleLine_SNY" extends INT_BundleLine_SNY
{
    fields
    {
        // Add changes to table fields here
        modify("Item No.")
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
                item: Record item;
            begin
                INT_BundleHeader_SNY.reset;
                INT_BundleHeader_SNY.setrange("No.", "No.");
                if INT_BundleHeader_SNY.find('-') then begin
                    "Free Gift ID" := INT_BundleHeader_SNY."Free Gift ID";
                end;

                if item.get("Item No.") then begin
                    "Item Description" := item.Description;
                    Validate(uom, item."Base Unit of Measure");
                end;
            end;
        }

    }
    trigger OnInsert()
    var
        myInt: Integer;
    begin

        INT_BudleLine_SNY.reset;
        INT_BudleLine_SNY.SetRange("No.", "No.");
        if INT_BudleLine_SNY.FindLast then begin
            "Line No." := INT_BudleLine_SNY."Line No." + 10000;
        end else begin
            "Line No." := 10000;
        end;

    end;


    var
        INT_BundleHeader_SNY: Record INT_BundleHeader_SNY;
        INT_BudleLine_SNY: Record INT_BundleLine_SNY;
}