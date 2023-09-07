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

unit AuthFilter;

// note: this is unsupported example code

interface

uses
  djWebFilter,
  djServerContext,
  djTypes,
  djInterfaces,
  Classes, SysUtils;

type

  { TAuthFilter }

  TAuthFilter = class(TdjWebFilter)
  private
    RedirectURI: string;
  public
    procedure Init(const Config: IWebFilterConfig); override;
    procedure DoFilter(Context: TdjServerContext; Request: TdjRequest;
      Response: TdjResponse; const Chain: IWebFilterChain); override;
  end;

implementation

function CreateGUIDString: string;
var
  Guid: TGUID;
begin
  CreateGUID(Guid);
  Result := GUIDToString(Guid);
end;

{ TAuthFilter }

procedure TAuthFilter.Init(const Config: IWebFilterConfig);
begin
  RedirectURI := Config.GetInitParameter('RedirectURI');
end;

procedure TAuthFilter.DoFilter(Context: TdjServerContext; Request: TdjRequest;
  Response: TdjResponse; const Chain: IWebFilterChain);
var
  Credentials: string;
begin
  Credentials := Request.Session.Content.Values['credentials'];
  if Credentials = '' then
  begin
    Response.Session.Content.Values['nonce'] := CreateGUIDString;
    Response.Session.Content.Values['state'] := CreateGUIDString;
    Response.Redirect(RedirectURI);
  end
  else
  begin
    Chain.DoFilter(Context, Request, Response); // pass
  end;
end;

end.
