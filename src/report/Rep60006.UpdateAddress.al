report 60006 "UpdateAddress"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    dataset
    {
        dataitem(LAZ_Orders_COM; LAZ_Orders_COM)
        {
            DataItemTableView = where("internal Order No." = filter(<> ''));
            RequestFilterFields = "Internal Order No.", "Seller ID";
            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin
                salseheader.reset;
                salseheader.SetRange("Document Type", salseheader."Document Type"::Order);
                salseheader.SetRange("No.", "Internal Order No.");
                if salseheader.Find('-') then begin
                    salseheader."Sell-to Contact" := LAZ_Orders_COM.customer_first_name + ' ' + LAZ_Orders_COM.customer_last_name;
                    address1 := "Ship-to address1" + ',' + "Ship-to address2" + ',' + "Ship-to address3" + ',' + "Ship-to address4"
                    + ',' + "Ship-to address5";
                    address2 := "Ship-to address4" + ',' + "Ship-to address5";
                    address1 := CopyStr(address1, 1, 100);
                    address2 := CopyStr(address2, 1, 50);
                    salseheader."Sell-to Address" := address1;
                    salseheader."Sell-to Address 2" := address2;
                    salseheader."Sell-to City" := CopyStr("Ship-to city", 1, 30);
                    salseheader."Sell-to Post Code" := CopyStr("Ship-to postal_code", 1, 20);
                    salseheader."Sell-to Country/Region Code" := CopyStr("Ship-to country", 1, 10);
                    salseheader."Sell-to Phone No." := "Ship-to phone" + ',' + "Ship-to phone2";
                    salseheader."Sell-to E-Mail" := "Ship-to customer_email";

                    salseheader."Ship-to Contact" := LAZ_Orders_COM.customer_first_name + ' ' + LAZ_Orders_COM.customer_last_name;
                    salseheader."ship-to Address" := address1;
                    salseheader."ship-to Address 2" := address2;
                    salseheader."ship-to City" := CopyStr("Ship-to city", 1, 30);
                    salseheader."ship-to Post Code" := CopyStr("Ship-to postal_code", 1, 20);
                    salseheader."ship-to Country/Region Code" := CopyStr("Ship-to country", 1, 10);

                    billaddress1 := "Bill-to address1" + ',' + "Bill-to address2" + ',' + "Bill-to address3" + ',' + "Bill-to address4"
                    + ',' + "Bill-to address5";
                    billaddress2 := "Bill-to address4" + ',' + "Bill-to address5";
                    billaddress1 := CopyStr(billaddress1, 1, 100);
                    billaddress2 := CopyStr(billaddress2, 1, 50);

                    salseheader."Bill-to Contact" := LAZ_Orders_COM.customer_first_name + ' ' + LAZ_Orders_COM.customer_last_name;
                    salseheader."Bill-to Address" := billaddress1;
                    salseheader."Bill-to Address 2" := billaddress2;
                    salseheader."Bill-to City" := CopyStr("Bill-to city", 1, 30);
                    salseheader."Bill-to Post Code" := CopyStr("Bill-to post_code", 1, 20);
                    salseheader."Bill-to Country/Region Code" := CopyStr("Ship-to country", 1, 10);
                    salseheader.Modify();
                end;
            end;
        }


    }

    var
        myInt: Integer;
        salseheader: Record "Sales Header";
        address1: text[200];
        address2: text[200];
        billaddress1: Text[200];
        billaddress2: text[200];

}