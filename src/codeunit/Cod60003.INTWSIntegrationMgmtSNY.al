codeunit 60003 "INT_WS_Integration_Mgmt_SNY"
{
    procedure Request(RequestJSON: Text): Text
    var
        IntegrationMethods: Codeunit "INT_WS_Integration Methods_SNY";
    begin
        IntegrationMethods.Set(requestJSON);
        if IntegrationMethods.Run() then
            exit(IntegrationMethods.WriteJSON(true));
        exit(IntegrationMethods.WriteJSON(false));
    end;
}