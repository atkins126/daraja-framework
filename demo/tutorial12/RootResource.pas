(*

    Daraja HTTP Framework
    Copyright (C) Michael Justin

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


    You can be released from the requirements of the license by purchasing
    a commercial license. Buying such a license is mandatory as soon as you
    develop commercial activities involving the Daraja framework without
    disclosing the source code of your own applications. These activities
    include: offering paid services to customers as an ASP, shipping Daraja
    with a closed source product.

*)

unit RootResource;

// note: this is unsupported example code

interface

uses
  djWebComponent, djTypes;

type

  { TRootResource }

  TRootResource = class(TdjWebComponent)
  private
    function ReadUserProfile(const AccessToken: string): string;
    function SendMail(const AccessToken: string): string;
  public
    procedure OnGet(Request: TdjRequest; Response: TdjResponse); override;
  end;

implementation

uses
  {$IFDEF FPC}{$NOTES OFF}{$ENDIF}{$HINTS OFF}{$WARNINGS OFF}
  IdHTTP, IdSSLOpenSSL, IdSSLOpenSSLHeaders,
  {$IFDEF FPC}{$ELSE}{$HINTS ON}{$WARNINGS ON}{$ENDIF}
  SysUtils, Classes;

function CreateIdHTTPwithSSL12(const AccessToken: string): TIdHTTP;
var
  IOHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  Result := TIdHTTP.Create;

  IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(Result);
  IOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
  Result.IOHandler := IOHandler;

  Result.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + AccessToken;
end;

{ TRootResource }

procedure TRootResource.OnGet(Request: TdjRequest; Response: TdjResponse);
var
  AccessToken: string;
  APIResponse: string;
begin
  AccessToken := Request.Session.Content.Values['access_token'];

  APIResponse := ReadUserProfile(AccessToken);

  SendMail(AccessToken);

  Response.ContentText := Format('<html><body><h1>Graph API example</h1>'
    + '<h2>Signed-in user profile:</h2><p>%s</p>'
    + '<h2>Send email:</h2><p>Email has been sent.</p></body></html>',
    [APIResponse]);
  Response.ContentType := 'text/html';
  Response.CharSet := 'utf-8';
end;

function TRootResource.ReadUserProfile(const AccessToken: string): string;
var
  HTTP: TIdHTTP;
begin
  HTTP := CreateIdHTTPwithSSL12(AccessToken);
  try
    try
      Result := HTTP.Get('https://graph.microsoft.com/v1.0/users/me');
    except
      WriteLn(IdSSLOpenSSLHeaders.WhichFailedToLoad);
      raise;
    end;
  finally
    HTTP.Free;
  end;
end;

function TRootResource.SendMail(const AccessToken: string): string;
const
  JSON =
     '{'+ #10
    +' "message": {'+ #10
    +' "subject": "Meet for lunch?",'+ #10
    +' "body": {'+ #10
    +'   "contentType": "Text",'+ #10
    +'   "content": "The new cafeteria is open."'+ #10
    +' },'+ #10
    +' "toRecipients": ['+ #10
    +'   {'+ #10
    +'     "emailAddress": {'+ #10
    +'       "address": "info@habarisoft.com"'+ #10
    +'     }'+ #10
    +'   }'+ #10
    +' ]'+ #10
    +' },'+ #10
    +' "saveToSentItems": "false"'+ #10
    +'}';
var
  HTTP: TIdHTTP;
  RequestBody: TStream;
  ResponseBody: string;
begin
  WriteLn(JSON);

  HTTP := CreateIdHTTPwithSSL12(AccessToken);
  try
    try
      HTTP.Request.ContentType := 'application/json';
      RequestBody := TStringStream.Create(JSON, TEncoding.UTF8);
      ResponseBody := HTTP.Post('https://graph.microsoft.com/v1.0/me/sendMail', RequestBody);
      WriteLn('Response: "' + ResponseBody + '"');
    except
      on E: EIdHTTPProtocolException do
      begin
        WriteLn(E.Message);
        WriteLn(E.ErrorMessage);
        raise;
      end;
      on E: Exception do
      begin
        WriteLn(E.Message);
        raise;
      end;
    end;
  finally
    HTTP.Free;
  end;
end;

end.
