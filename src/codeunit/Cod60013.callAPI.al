codeunit 60013 callAPI
{

    procedure sendAPI(var texttosend: Text)
    var
        tb: TextBuilder;
        lFile: File;
        ltxt: Text;
        ltxt1: Text;
        lInstream: InStream;
        lOutStream: OutStream;
        error: Text;
    begin
        Clear(gHttpHeaders);
        Clear(gHttpRequestMessage);
        Clear(gHttpResponseMessage);
        Clear(ghttpClient);
        Clear(ghttpContent);
        Clear(tb);
        Clear(gJSONText);

        //ltxt1 := gCUBase64.TextToBase64String(texttosend);
        ltxt1 := texttosend;
        //tb.AppendLine('--123456789');
        //tb.AppendLine(StrSubstNo('Content-Disposition: form-data; name="document"; file-name="%1"', 'FiltnameSalesOrder'));
        //tb.AppendLine('Content-Type: text/html');
        //tb.AppendLine(); // Empty line required to separate the header information from payload
        tb.AppendLine(ltxt1);
        //tb.AppendLine('--123456789--');
        APIURL := 'https://prod-05.southeastasia.logic.azure.com:443/workflows/212d3f3a62bb446b93a9efbf9070146b/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=rF9NCEswukB32s-0gbzAaCONYwgUzz-p5W0hkf_Zr0U';
        ghttpContent.WriteFrom(tb.ToText());

        // Get Content Headers
        ghttpContent.GetHeaders(gHttpHeaders);

        // update the content header information and define the boundary    
        if gHttpHeaders.Contains('Content-Type') then gHttpHeaders.Remove('Content-Type');
        gHttpHeaders.Add('Content-Type', 'text/html');
        gHttpHeaders.Add('file-name', 'SalesInvoie.pdf');
        // Setup the URL
        gHttpRequestMessage.SetRequestUri(APIURL);

        // Setup the HTTP Verb
        gHttpRequestMessage.Method := 'POST';

        // Add some request headers like:
        gHttpRequestMessage.GetHeaders(gHttpHeaders);
        //gHttpHeaders.Add('Authorization', gPEPPOLAPISetup."API TOKEN");

        // Set the content
        gHttpRequestMessage.Content := ghttpContent;


        if not ghttpClient.Send(gHttpRequestMessage, gHttpResponseMessage) then begin
            gHttpResponseMessage.Content.ReadAs(gJSONText);

            //lPEPPOLDocumentsSend."Sent to AP" := false;
            //lPEPPOLDocumentsSend."Error Message" := 'The call to the web service failed.';
            //lPEPPOLDocumentsSend.Modify();
            Message('The call to the web service failed.');
            //if not IsAuto then Error('The call to the web service failed.');
        end;

        if not gHttpResponseMessage.IsSuccessStatusCode then begin
            //lPEPPOLDocumentsSend."Sent to AP" := false;
            //lPEPPOLDocumentsSend."Error Message" := StrSubstNo('The web service returned an error message:\\' + 'Status code: %1\' + 'Description: %2', gHttpResponseMessage.HttpStatusCode, gHttpResponseMessage.ReasonPhrase);
            //lPEPPOLDocumentsSend.Modify();
            error := StrSubstNo('The web service returned an error message:\\' + 'Status code: %1\' + 'Description: %2', gHttpResponseMessage.HttpStatusCode, gHttpResponseMessage.ReasonPhrase);
            Message(error);
            //if not IsAuto then Error('The web service returned an error message:\\' + 'Status code: %1\' + 'Description: %2', gHttpResponseMessage.HttpStatusCode, gHttpResponseMessage.ReasonPhrase);
        end else begin

            //lPEPPOLDocumentsSend."Sent to AP" := true;
            //lPEPPOLDocumentsSend.calcfields("XML Data");
            //if lPEPPOLDocumentsSend."XML Data".HasValue then begin
            //    Clear(lPEPPOLDocumentsSend."XML Data");
            //end;
            //lPEPPOLDocumentsSend.Modify();
            gHttpResponseMessage.Content.ReadAs(gJSONText);
            Message('call success');
            APIResponseStaus();
            //if not IsAuto then Message('Invoice document sent to PEPPOL');

        end;

    end;

    procedure APIResponseStaus();
    var
        lJSONObject: JsonObject;
        lTaskId: Text;
        lJSONToken: JsonToken;
        lJSONArray: JsonArray;
        i: Integer;
    begin
        lJSONToken.ReadFrom(gJSONText);
        lJSONObject := lJSONToken.AsObject();
        lJSONToken.SelectToken('info', lJSONToken);
        lJSONArray := lJSONToken.AsArray();
        //Porcess JSON response
        for i := 0 to lJSONArray.Count - 1 do begin
            lJSONArray.Get(i, lJSONToken);
            lJSONObject := lJSONToken.AsObject();
            Message('Status %1', GetJSONToken(lJSONObject, 'status').AsValue().AsText());
            if lJSONObject.Get('sender', lJSONToken) then
                Message('sender %1', GetJSONToken(lJSONObject, 'sender').AsValue().AsText());
            if lJSONObject.Get('receiver', lJSONToken) then
                message('receiver %1', GetJSONToken(lJSONObject, 'receiver').AsValue().AsText());
            //lPEPPOLDocumentsSend.Status := GetJSONToken(lJSONObject, 'status').AsValue().AsText();
            //if lJSONObject.Get('sender', lJSONToken) then
            //    lPEPPOLDocumentsSend.Sender := GetJSONToken(lJSONObject, 'sender').AsValue().AsText();
            //if lJSONObject.Get('receiver', lJSONToken) then
            //    lPEPPOLDocumentsSend.Receiver := GetJSONToken(lJSONObject, 'receiver').AsValue().AsText();

            //lPEPPOLDocumentsSend."Status Message" := GetJSONToken(lJSONObject, 'statusMessage').AsValue().AsText();
            //lPEPPOLDocumentsSend.Modify();
        end;
    end;

    local procedure GetJSONToken(JsonObject: JsonObject;
    TokenKey: Text) JsonToken: JsonToken;
    var
    begin
        if not JsonObject.get(TokenKey, JsonToken) then Error('Could not find a token with key %1', TokenKey);
    end;

    var
        ghttpClient: HttpClient;
        ghttpContent: HttpContent;
        gHttpHeaders: HttpHeaders;
        gHttpRequestMessage: HttpRequestMessage;
        gHttpResponseMessage: HttpResponseMessage;
        APIURL: Text[300];
        gEntryNo: Integer;
        gJSONText: Text;
        gCUBase64: Codeunit "Ibiz50 Base64Convert";
}