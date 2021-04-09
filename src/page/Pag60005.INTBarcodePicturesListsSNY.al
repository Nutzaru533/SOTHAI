page 60005 "INT_BarcodePicturesLists_SNY"
{
    PageType = ListPlus;
    SourceTable = INT_Barcode_SNY;
    CaptionML = ENU = 'Barcode Pictures List', ITA = 'Barcode Immagini lista';
    UsageCategory = Documents;
    ApplicationArea = All;

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