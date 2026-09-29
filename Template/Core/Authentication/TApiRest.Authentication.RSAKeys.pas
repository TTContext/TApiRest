{ TFeature:auth }
{ TFeature:rs256 }
(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Authentication.RSAKeys;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  Trysil.Http.JWT.RSAKey,

  TApiRest.Config;

type

{ TJWTRSAKeys }

  TJWTRSAKeys = class
  strict private
    class var FInstance: TJWTRSAKeys;

    class constructor ClassCreate;
    class destructor ClassDestroy;

    class function GetInstance: TJWTRSAKeys; static;
  strict private
    FKeys: TObjectDictionary<String, TTHttpJWTRSAAbstractKey>;
    FSigningKey: TTHttpJWTRSAPrivateKey;

    procedure LoadKeys;
  public
    constructor Create;
    destructor Destroy; override;

    function VerificationKey(
      const AKeyID: String): TTHttpJWTRSAAbstractKey;

    property SigningKey: TTHttpJWTRSAPrivateKey read FSigningKey;

    class procedure Initialize;

    class property Instance: TJWTRSAKeys read GetInstance;
  end;

implementation

{ TJWTRSAKeys }

class constructor TJWTRSAKeys.ClassCreate;
begin
  FInstance := nil;
end;

class destructor TJWTRSAKeys.ClassDestroy;
begin
  if Assigned(FInstance) then
    FInstance.Free;
end;

class function TJWTRSAKeys.GetInstance: TJWTRSAKeys;
begin
  Initialize;
  result := FInstance;
end;

class procedure TJWTRSAKeys.Initialize;
begin
  if not Assigned(FInstance) then
    FInstance := TJWTRSAKeys.Create;
end;

constructor TJWTRSAKeys.Create;
begin
  inherited Create;
  FKeys := TObjectDictionary<String, TTHttpJWTRSAAbstractKey>.Create(
    [doOwnsValues], TIStringComparer.Ordinal);
  LoadKeys;
end;

destructor TJWTRSAKeys.Destroy;
begin
  if Assigned(FSigningKey) then
    FSigningKey.Free;
  FKeys.Free;
  inherited Destroy;
end;

procedure TJWTRSAKeys.LoadKeys;
var
  LSecrets: TSecretsConfig;
  LKey: TJWTKeyConfig;
begin
  LSecrets := TConfig.Instance.Secrets;
  for LKey in LSecrets.Keys do
    FKeys.Add(
      LKey.KeyID, TTHttpJWTRSAPublicKey.Create(LKey.PublicKey, LKey.KeyID));

  if not LSecrets.SigningKey.IsEmpty then
    FSigningKey := TTHttpJWTRSAPrivateKey.Create(
      LSecrets.SigningKey, LSecrets.CurrentKeyID);
end;

function TJWTRSAKeys.VerificationKey(
  const AKeyID: String): TTHttpJWTRSAAbstractKey;
begin
  if not FKeys.TryGetValue(AKeyID, result) then
    result := nil;
end;

end.
