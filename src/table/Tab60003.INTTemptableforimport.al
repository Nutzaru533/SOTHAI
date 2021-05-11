table 60003 "INT_Temptableforimport"
{
    Caption = 'Temp tableforimport';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; entryno; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
        }
        field(2; gNo; Text[100])
        {
            Caption = 'External No.';
            DataClassification = ToBeClassified;

        }
        field(3; gMarketplace; Text[100])
        {
            Caption = 'Marketplace';
            DataClassification = ToBeClassified;

        }

        field(4; gDes; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;

        }
        field(5; gStartingDate; Text[100])
        {
            Caption = 'Starting Date';
            DataClassification = ToBeClassified;

        }
        field(6; gEndingDate; Text[100])
        {
            Caption = 'Ending Date';
            DataClassification = ToBeClassified;

        }
        field(7; gLineItemNo; Text[100])
        {
            Caption = 'Line Item No.';
            DataClassification = ToBeClassified;

        }
        field(8; gQty; Text[100])
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;

        }
        field(9; gSRPPriece; Text[100])
        {
            Caption = 'SRP Price';
            DataClassification = ToBeClassified;

        }
        field(10; gPromotionalPrice; Text[100])
        {
            Caption = 'Promotional Price';
            DataClassification = ToBeClassified;

        }
        field(11; gRelated_Item_Type; Text[100])
        {
            Caption = 'Related item Type';
            DataClassification = ToBeClassified;

        }
        field(12; gStorageLocation; Text[100])
        {
            Caption = 'Storeage Location';
            DataClassification = ToBeClassified;

        }
        field(13; error; Boolean)
        {
            Caption = 'Error';
            DataClassification = ToBeClassified;
        }
        field(14; ErrorDes; text[500])
        {
            Caption = 'Error Description';
            DataClassification = ToBeClassified;
        }
        field(15; Type; text[50])
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;
        }
        field(16; DocNo; text[50])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
        }
        field(17; gItemNo; text[50])
        {
            Caption = 'Item No.';
            DataClassification = ToBeClassified;
        }
        field(18; gPromotionType; code[100])
        {
            Caption = 'Promotion Type';
            DataClassification = ToBeClassified;
        }
        field(23; gPromotionType2; Option)
        {
            Caption = 'Promotion Type 2';
            OptionMembers = "NONE",FOC,"FOC WITH DISCOUNT","GROUP DISCOUNT","ITEM DISCOUNT";
            DataClassification = ToBeClassified;
        }
        field(19; gPeriodStart; Text[100])
        {
            Caption = 'Period Start';
            DataClassification = ToBeClassified;
        }
        field(20; gPeriodEnd; Text[100])
        {
            Caption = 'Period End';
            DataClassification = ToBeClassified;
        }
        field(21; gInclude_FOC; Text[100])
        {
            Caption = 'Inculde FOC';
            DataClassification = ToBeClassified;
        }
        field(22; gMain_Item_For_Delivery; Text[100])
        {
            Caption = 'Main Item For Delivery';
            DataClassification = ToBeClassified;
        }
        field(24; Foc; Boolean)
        {
            Caption = 'FOC';
            DataClassification = ToBeClassified;
        }
        field(25; SortNo; Integer)
        {
            Caption = 'Excel Line number';
            DataClassification = ToBeClassified;
        }



    }

    keys
    {
        key(Key1; entryno)
        {
            Clustered = true;
        }
        key(sort; SortNo)
        {
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}