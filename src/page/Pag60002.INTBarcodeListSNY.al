#pragma implicitwith disable
page 60002 "INT_BarcodeList_SNY"
{
    PageType = List;
    SourceTable = INT_Barcode_SNY;
    CaptionML = ENU = 'Barcode List', ITA = 'Barcode';
    CardPageId = INT_BarcodeCard_SNY;
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field(Width; Rec.Width)
                {
                    ApplicationArea = All;
                }
                field(Height; Rec.Height)
                {
                    ApplicationArea = All;
                }
                field(IncludeText; Rec.IncludeText)
                {
                    ApplicationArea = All;
                }
                field(Border; Rec.Border)
                {
                    ApplicationArea = All;
                }
                field(ReverseColors; Rec.ReverseColors)
                {
                    ApplicationArea = All;
                }
                field(ECCLevel; Rec.ECCLevel)
                {
                    ApplicationArea = All;
                }
                field(Size; Rec.Size)
                {
                    ApplicationArea = All;
                }
                field(PictureType; Rec.PictureType)
                { ApplicationArea = All; }
                field(Picture; Rec.Picture)
                {
                    ApplicationArea = All;
                }

            }
        }
    }
}
#pragma implicitwith restore
