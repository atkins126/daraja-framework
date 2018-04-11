(*

    Daraja Framework
    Copyright (C) 2016  Michael Justin

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

unit LoginResource;

interface

uses
  djWebComponent, djTypes;

type
  TLoginResource = class(TdjWebComponent)
  private
    function CheckPwd(const Username, Password: string): Boolean;
  public
    procedure OnGet(Request: TdjRequest; Response: TdjResponse); override;
    procedure OnPost(Request: TdjRequest; Response: TdjResponse); override;
  end;

implementation

uses
  Bcrypt;

procedure TLoginResource.OnGet(Request: TdjRequest; Response: TdjResponse);
begin
  if Request.Session.Content.Values['form:username'] <> '' then
  begin
    Response.ContentText := '<!DOCTYPE html>' + #13
    + '<html>' + #13
    + '  <head>' + #13
    + '    <title>Form based login example</title>' + #13
    + '  </head>' + #13
    + '  <body>' + #13
    + '    <p>you are logged in</p>' + #13
    + '    <form method="post">' + #13
    + '     <input type="submit" name="submit" value="Logout">' + #13
    + '    </form>' + #13
    + '  </body>' + #13
    + '</html>';
  end
  else
  begin
    Response.ContentText := '<!DOCTYPE html>' + #13
    + '<html>' + #13
    + '  <head>' + #13
    + '    <title>Form based login example</title>' + #13
    + '  </head>' + #13
    + '  <body>' + #13
    + '    <form method="post">' + #13
    + '     <input type="text" name="username" required>' +#13
    + '     <input type="password" name="password" required>' + #13
    + '     <input type="submit" name="submit" value="Login">' + #13
    + '    </form>' + #13
    + '  </body>' + #13
    + '</html>';
  end;

  Response.ContentType := 'text/html';
  Response.CharSet := 'utf-8';
end;

procedure TLoginResource.OnPost(Request: TdjRequest; Response: TdjResponse);
var
  Username: string;
  Password: string;
begin
  if Request.Params.Values['submit'] = 'Logout' then
  begin
    Request.Session.Free;
    Response.Redirect(Request.Document);
    Exit;
  end;

  // read form data
  Username := Utf8ToString(RawByteString(Request.Params.Values['username']));
  Password := Utf8ToString(RawByteString(Request.Params.Values['password']));

  if CheckPwd(Username, Password) then
  begin
    // store username in session
    Request.Session.Content.Values['form:username'] := Username;
    // success: redirect to home page
    Response.Redirect(Request.Document);
  end else begin
    // bad user/password: return authentication error
    Response.ResponseNo := 401;
  end;
end;

function TLoginResource.CheckPwd(const Username, Password: string): Boolean;
const
  HASH_GUEST = '$2a$11$tDOG9GRbsg8IusbCeKd4muN1dGpuQDwDR4rdWfnFb3GoE6IuZeyaS';
var
  PasswordRehashNeeded: Boolean;
begin
  // ExpectedHash := TBCrypt.HashPassword(Password);

  Result := False;

  if Username = 'guest' then
  begin
    Result := TBCrypt.CheckPassword(Password, HASH_GUEST, PasswordRehashNeeded);
  end;
end;

end.
