page 60001 "TH_WS_Gen JSON Response_SNY"
{
    Caption = 'Generate JSON Response TH';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(RequestJSON; RequestJSON)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    Width = 1000;
                    Caption = 'Request JSON';
                    ToolTip = 'Specifies the request JSON received as a parameter to InitWSFunctions.';
                }
            }
            group(response)
            {
                field(ResponseJSON; ResponseJSON)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    Width = 1000;
                    Caption = 'Response JSON';
                    ToolTip = 'Specifies the response JSON sent with respect to the Request JSON.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(GenerateJSON)
            {
                ApplicationArea = All;
                Caption = 'Generate JSON';
                Image = Action;
                ToolTip = 'Generates the Response JSON';

                trigger OnAction()
                var
                    IntegrationMgmt: Codeunit "TH_WS_Integration Mgmt._SNY";
                begin
                    if RequestJSON = '' then exit;
                    ResponseJSON := IntegrationMgmt.Request(RequestJSON);
                end;
            }
        }
    }
    var
        RequestJSON: Text;
        ResponseJSON: Text;
}
