page 60004 "INT_BarcodePicture_SNY"
{
    PageType = CardPart;
    SourceTable = INT_Barcode_SNY;
    CaptionML = ENU = 'Barcode', ITA = 'Barcode';
    //UsageCategory = Documents;
    //ApplicationArea = All;

    layout
    {
        area(content)
        {
            field(Picture; Picture)
            {
                ApplicationArea = All;
                Editable = false;
                ShowCaption = false;
            }
        }
    }
}