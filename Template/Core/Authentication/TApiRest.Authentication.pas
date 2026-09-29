{ TFeature:auth }
(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Authentication;

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Consts,
  Trysil.Http.Classes,
  Trysil.Http.Exceptions,
  Trysil.Http.JWT,
  Trysil.Http.Authentication,
  Trysil.Http.Authentication.Bearer,

  TApiRest.Consts,
  TApiRest.Context,
  TApiRest.Authentication.JWT;

type

{ TAuthentication }

  TAuthentication = class(TTHttpAuthenticationBearer<TContext, TJWTPayload>)
  strict private
    FRequest: TTHttpRequest;
    FResponse: TTHttpResponse;

    procedure InvalidToken(const AError: String; const AMessage: String);
    procedure CheckToken(const AToken: String);
  strict protected
    function CreatePayload: TJWTPayload; override;
    function IsValid(const APayload: TJWTPayload): Boolean; override;
  public
    procedure Check(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
  end;

implementation

{ TAuthentication }

procedure TAuthentication.InvalidToken(
  const AError: String; const AMessage: String);
begin
  FResponse.AddHeader(
    'WWW-Authenticate', Format('Bearer error="%s"', [AError]));
  raise ETHttpUnauthorized.Create(TTLanguage.Instance.Translate(AMessage));
end;

procedure TAuthentication.CheckToken(const AToken: String);
var
  LPayload: TJWTPayload;
  LJWT: TTHttpJWT<TJWTPayload>;
begin
  LPayload := CreatePayload;
  try
    LJWT := TTHttpJWT<TJWTPayload>.Create(LPayload);
    try
      if not LJWT.LoadFromToken(AToken) then
        InvalidToken('invalid_token', SInvalidToken)
      else if LJWT.Payload.IsExpired then
        InvalidToken('invalid_token', SExpiredToken)
      else if not IsValid(LJWT.Payload) then
        InvalidToken('invalid_token', SInvalidToken);
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;
end;

procedure TAuthentication.Check(
  const ARequest: TTHttpRequest; const AResponse: TTHttpResponse);
begin
  FRequest := ARequest;
  FResponse := AResponse;
  CheckToken(GetValue(ARequest, AResponse));
end;

function TAuthentication.CreatePayload: TJWTPayload;
begin
  result := TJWTPayload.Create;
end;

function TAuthentication.IsValid(const APayload: TJWTPayload): Boolean;
begin
  result := not APayload.IsExpired;
  if result then
  begin
    Context.Payload.Assign(APayload);
    FRequest.User.Username := APayload.Email;
  end;
end;

end.
