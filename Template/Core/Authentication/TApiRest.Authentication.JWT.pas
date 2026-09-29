{ TFeature:auth }
(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Authentication.JWT;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.JSon,
  System.DateUtils,
  Trysil.Http.Exceptions,
{ TFeature:rs256 }
  Trysil.Http.JWT.Payload.RS256,
  Trysil.Http.JWT.RSAKey,
{ /TFeature:rs256 }
(* TFeature:!rs256
  Trysil.Http.JWT.Payload.HS256,
*)
  Trysil.Http.Classes,

{ TFeature:rs256 }
  TApiRest.Authentication.RSAKeys,
{ /TFeature:rs256 }
  TApiRest.Config;

type

{ TJWTPayloadBase }

{ TFeature:rs256 }
  TJWTPayloadBase = TTHttpJWTRS256Payload;
{ /TFeature:rs256 }
(* TFeature:!rs256
  TJWTPayloadBase = TTHttpJWTHS256Payload;
*)

{ TJWTPayload }

  TJWTPayload = class(TJWTPayloadBase)
  strict private
    FID: Integer;
    FFirstname: String;
    FLastname: String;
    FUserTypeID: Integer;
    FEmail: String;
    FAreas: TList<String>;
{ TFeature:multitenant }
    FTenant: String;
{ /TFeature:multitenant }
    FExpireTime: Int64;
  strict protected
{ TFeature:rs256 }
    function GetSigningKey: TTHttpJWTRSAPrivateKey; override;
    function GetVerificationKey(
      const AKeyID: String): TTHttpJWTRSAAbstractKey; override;
{ /TFeature:rs256 }
(* TFeature:!rs256
    function GetSigningKeyID: String; override;
    function GetSecret: String; override;
    function GetSecretFor(const AKeyID: String): String; override;
*)
  public
    constructor Create;
    destructor Destroy; override;

    function IsExpired: Boolean;

    procedure Assign(const APayload: TJWTPayload);
    function ToJSon: String; override;
    procedure FromJSon(const AData: String); override;

    property ID: Integer read FID write FID;
    property Firstname: String read FFirstname write FFirstname;
    property Lastname: String read FLastname write FLastname;
    property UserTypeID: Integer read FUserTypeID write FUserTypeID;
    property Email: String read FEmail write FEmail;
    property Areas: TList<String> read FAreas;
{ TFeature:multitenant }
    property Tenant: String read FTenant write FTenant;
{ /TFeature:multitenant }
    property ExpireTime: Int64 read FExpireTime;
  end;

implementation

{ TJWTPayload }

constructor TJWTPayload.Create;
begin
  inherited Create;
  FAreas := TList<String>.Create;
end;

destructor TJWTPayload.Destroy;
begin
  FAreas.Free;
  inherited Destroy;
end;

{ TFeature:rs256 }
function TJWTPayload.GetSigningKey: TTHttpJWTRSAPrivateKey;
begin
  result := TJWTRSAKeys.Instance.SigningKey;
end;

function TJWTPayload.GetVerificationKey(
  const AKeyID: String): TTHttpJWTRSAAbstractKey;
begin
  result := TJWTRSAKeys.Instance.VerificationKey(AKeyID);
end;
{ /TFeature:rs256 }
(* TFeature:!rs256
function TJWTPayload.GetSigningKeyID: String;
begin
  result := TConfig.Instance.Secrets.CurrentKeyID;
end;

function TJWTPayload.GetSecret: String;
begin
  result := TConfig.Instance.Secrets.CurrentSecret;
end;

function TJWTPayload.GetSecretFor(const AKeyID: String): String;
begin
  result := TConfig.Instance.Secrets.SecretFor(AKeyID);
end;
*)

function TJWTPayload.IsExpired: Boolean;
var
  LCurrentTime: Int64;
begin
  LCurrentTime := Int64.Parse(FormatDateTime('yyyymmddhhnnss', now));
  result := (FExpireTime <= LCurrentTime);
end;

procedure TJWTPayload.Assign(const APayload: TJWTPayload);
begin
  FID := APayload.FID;
  FFirstname := APayload.FFirstname;
  FLastname := APayload.FLastname;
  FUserTypeID := APayload.UserTypeID;
  FEmail := APayload.FEmail;
{ TFeature:multitenant }
  FTenant := APayload.Tenant;
{ /TFeature:multitenant }

  FAreas.Clear;
  FAreas.AddRange(APayload.FAreas);

  FExpireTime := APayload.FExpireTime;
end;

procedure TJWTPayload.FromJSon(const AData: String);
var
  LJSon, LArea: TJSonValue;
  LAreas: TJSonArray;
begin
  LJSon := TJSonObject.ParseJSONValue(AData, False, True);
  try
    FID := LJSon.GetValue<Integer>('id', 0);
    FFirstname := LJSon.GetValue<String>('firstname', String.Empty);
    FLastname := LJSon.GetValue<String>('lastname', String.Empty);
    FUserTypeID := LJSon.GetValue<Integer>('userTypeID', 0);
    FEmail := LJSon.GetValue<String>('email', String.Empty);
{ TFeature:multitenant }
    FTenant := LJSon.GetValue<String>('tenant', String.Empty);
{ /TFeature:multitenant }

    FAreas.Clear;
    LAreas := LJSon.GetValue<TJSonArray>('areas', nil);
    if Assigned(LAreas) then
      for LArea in LAreas do
        if LArea is TJSonString then
          FAreas.Add(TJSonString(LArea).Value);

    FExpireTime := LJSon.GetValue<Int64>('expireTime', 0);
  finally
    LJSon.Free;
  end;
end;

function TJWTPayload.ToJSon: String;
var
  LExpireTime: TDateTime;
  LJSon: TJSonObject;
  LAreas: TJSonArray;
  LArea: String;
begin
  LExpireTime := IncMinute(now, TConfig.Instance.Auth.AccessTokenMinutes);

  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('id', FID);
    LJSon.AddPair('firstname', FFirstname);
    LJSon.AddPair('lastname', FLastname);
    LJSon.AddPair('userTypeID', FUserTypeID);
    LJSon.AddPair('email', FEmail);
{ TFeature:multitenant }
    LJSon.AddPair('tenant', FTenant);
{ /TFeature:multitenant }

    LAreas := TJSonArray.Create;
    try
      for LArea in FAreas do
        LAreas.AddElement(TJSonString.Create(LArea));
      LJSon.AddPair('areas', LAreas);
    except
      LAreas.Free;
      raise;
    end;

    FExpireTime := Int64.Parse(FormatDateTime('yyyymmddhhnnss', LExpireTime));
    LJSon.AddPair('expireTime', FExpireTime);

    result := LJSon.ToJSon();
  finally
    LJSon.Free;
  end;
end;

end.
