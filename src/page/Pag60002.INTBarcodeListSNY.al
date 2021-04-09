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
                field(Value; Value)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field(Width; Width)
                {
                    ApplicationArea = All;
                }
                field(Height; Height)
                {
                    ApplicationArea = All;
                }
                field(IncludeText; IncludeText)
                {
                    ApplicationArea = All;
                }
                field(Border; Border)
                {
                    ApplicationArea = All;
                }
                field(ReverseColors; ReverseColors)
                {
                    ApplicationArea = All;
                }
                field(ECCLevel; ECCLevel)
                {
                    ApplicationArea = All;
                }
                field(Size; Size)
                {
                    ApplicationArea = All;
                }
                field(PictureType; PictureType)
                { ApplicationArea = All; }
                field(Picture; Picture)
                {
                    ApplicationArea = All;
                }

            }
        }
    }
}