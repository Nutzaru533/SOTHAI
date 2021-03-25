codeunit 60003 "TH_WS_Integration Mgmt._SNY"
{
    procedure Request(RequestJSON: Text): Text
    var
        IntegrationMethods: Codeunit "TH_WS_Integration Methods_SNY";
    begin
        IntegrationMethods.Set(requestJSON);
        if IntegrationMethods.Run() then
            exit(IntegrationMethods.WriteJSON(true));
        exit(IntegrationMethods.WriteJSON(false));
    end;
}