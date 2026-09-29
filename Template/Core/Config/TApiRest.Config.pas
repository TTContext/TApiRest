(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Config;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.IOUtils,
  System.JSon,
  Trysil.Consts,
  Trysil.Data.FireDAC,

  TApiRest.Consts,
  TApiRest.Config.JSon;

type

{ TServerConfig }

  TServerConfig = record
  strict private
    FBaseUri: String;
    FPort: Word;
  private // internal
    procedure Load(const AJSon: TJSonValue);
  public
    property BaseUri: String read FBaseUri;
    property Port: Word read FPort;
  end;

(* TFeature:!multitenant

{ TDatabaseConfig }

  TDatabaseConfig = record
  strict private
    FParameters: TTFireDACConnectionParameters;
  private // internal
    procedure Load(const AJSon: TJSonValue; const APath: String);
  public
    property Parameters: TTFireDACConnectionParameters read FParameters;
  end;
*)

{ TFeature:log }

{ TLogConfig }

  TLogConfig = record
  strict private
    FEnabled: Boolean;
(* TFeature:!multitenant
    FDatabase: TDatabaseConfig;
*)
  private // internal
    procedure Load(const AJSon: TJSonValue);
  public
    property Enabled: Boolean read FEnabled;
(* TFeature:!multitenant
    property Database: TDatabaseConfig read FDatabase;
*)
  end;
{ /TFeature:log }

{ TFeature:auth }

{ TJWTKeyConfig }

  TJWTKeyConfig = record
  strict private
    FKeyID: String;
{ TFeature:rs256 }
    FPublicKey: String;
{ /TFeature:rs256 }
(* TFeature:!rs256
    FSecret: String;
*)
  private // internal
    procedure Load(const AJSon: TJSonValue);
  public
    property KeyID: String read FKeyID;
{ TFeature:rs256 }
    property PublicKey: String read FPublicKey;
{ /TFeature:rs256 }
(* TFeature:!rs256
    property Secret: String read FSecret;
*)
  end;

{ TSecretsConfig }

  TSecretsConfig = record
  strict private
    FPassword: String;
    FCurrentKeyID: String;
{ TFeature:rs256 }
    FSigningKey: String;
{ /TFeature:rs256 }
    FKeys: TArray<TJWTKeyConfig>;

    procedure LoadKeys(const AJSon: TJSonValue);
    procedure CheckKeys;
  private // internal
    procedure Load(const AJSon: TJSonValue);
  public
    function IndexOfKey(const AKeyID: String): Integer;
(* TFeature:!rs256
    function SecretFor(const AKeyID: String): String;
    function CurrentSecret: String;
*)

    property Password: String read FPassword;
    property CurrentKeyID: String read FCurrentKeyID;
{ TFeature:rs256 }
    property SigningKey: String read FSigningKey;
{ /TFeature:rs256 }
    property Keys: TArray<TJWTKeyConfig> read FKeys;
  end;

{ TAuthConfig }

  TAuthConfig = record
  strict private
    FAccessTokenMinutes: Integer;
  private // internal
    procedure Load(const AJSon: TJSonValue);
  public
    property AccessTokenMinutes: Integer read FAccessTokenMinutes;
  end;
{ /TFeature:auth }

{ TConnectionPoolConfig }

  TConnectionPoolConfig = record
  strict private
    FEnabled: Boolean;
    FMaximumItems: Integer;
  private // internal
    procedure Load(const AJSon: TJSonValue);
  public
    property Enabled: Boolean read FEnabled;
    property MaximumItems: Integer read FMaximumItems;
  end;

{ TCorsConfig }

  TCorsConfig = record
  strict private
    FAllowHeaders: String;
    FAllowOrigin: String;
  private // internal
    procedure Load(const AJSon: TJSonValue);
  public
    property AllowHeaders: String read FAllowHeaders;
    property AllowOrigin: String read FAllowOrigin;
  end;

{ TConfig }

  TConfig = class
  strict private
    class var FInstance: TConfig;

    class constructor ClassCreate;
    class destructor ClassDestroy;

    class function GetInstance: TConfig; static;
  strict private
    FServer: TServerConfig;
(* TFeature:!multitenant
    FDatabase: TDatabaseConfig;
*)
{ TFeature:log }
    FLog: TLogConfig;
{ /TFeature:log }
{ TFeature:auth }
    FSecrets: TSecretsConfig;
    FAuth: TAuthConfig;
{ /TFeature:auth }
    FConnectionPool: TConnectionPoolConfig;
    FCors: TCorsConfig;

    function GetJSonConfig: TJSonValue;
    procedure LoadFromFile;
  public
    procedure AfterConstruction; override;

    property Server: TServerConfig read FServer;
(* TFeature:!multitenant
    property Database: TDatabaseConfig read FDatabase;
*)
{ TFeature:log }
    property Log: TLogConfig read FLog;
{ /TFeature:log }
{ TFeature:auth }
    property Secrets: TSecretsConfig read FSecrets;
{ /TFeature:auth }
    property ConnectionPool: TConnectionPoolConfig read FConnectionPool;
{ TFeature:auth }
    property Auth: TAuthConfig read FAuth;
{ /TFeature:auth }
    property Cors: TCorsConfig read FCors;

    class property Instance: TConfig read GetInstance;
  end;

implementation

{ TServerConfig }

procedure TServerConfig.Load(const AJSon: TJSonValue);
begin
  if Assigned(AJSon) then
  begin
    FBaseUri := AJSon.GetValue<String>('baseUri', String.Empty);
    FPort := AJSon.GetValue<Integer>('port', 4450);
  end;
end;

(* TFeature:!multitenant

{ TDatabaseConfig }

procedure TDatabaseConfig.Load(const AJSon: TJSonValue; const APath: String);
begin
  if not Assigned(AJSon) then
    raise EJSonException.CreateFmt(
      TTLanguage.Instance.Translate(SConfigDriverNotFound), [APath]);

  FParameters.Driver := AJSon.GetValue<String>('driver', String.Empty);
  if FParameters.Driver.IsEmpty then
    raise EJSonException.CreateFmt(
      TTLanguage.Instance.Translate(SConfigDriverNotFound), [APath]);

  FParameters.Server := AJSon.GetValue<String>('server', String.Empty);
  FParameters.Port := AJSon.GetValue<Integer>('port', 0);
  FParameters.Username := AJSon.GetValue<String>('username', String.Empty);
  FParameters.Password := AJSon.GetValue<String>('password', String.Empty);
  FParameters.DatabaseName := AJSon.GetValue<String>(
    'databaseName', String.Empty);
end;

*)

{ TFeature:log }

{ TLogConfig }

procedure TLogConfig.Load(const AJSon: TJSonValue);
(* TFeature:!multitenant
var
  LDatabase: TJSonValue;
*)
begin
  FEnabled := True;
(* TFeature:!multitenant
  LDatabase := nil;
*)
  if Assigned(AJSon) then
  begin
    FEnabled := AJSon.GetValue<Boolean>('enabled', FEnabled);
(* TFeature:!multitenant
    LDatabase := AJSon.GetValue<TJSonValue>('database', nil);
*)
  end;

(* TFeature:!multitenant
  if FEnabled then
    FDatabase.Load(LDatabase, 'log.database');
*)
end;
{ /TFeature:log }

{ TFeature:auth }

{ TFeature:rs256 }
function LoadPem(const AFileName: String): String;
begin
  result := String.Empty;
  if not AFileName.IsEmpty then
  begin
    if not TFile.Exists(AFileName) then
      raise EFileNotFoundException.CreateFmt(
        TTLanguage.Instance.Translate(SConfigNotFound), [AFileName]);

    result := TFile.ReadAllText(AFileName);
  end;
end;
{ /TFeature:rs256 }

{ TJWTKeyConfig }

procedure TJWTKeyConfig.Load(const AJSon: TJSonValue);
begin
  FKeyID := AJSon.GetValue<String>('id', String.Empty);
{ TFeature:rs256 }
  FPublicKey := LoadPem(AJSon.GetValue<String>('publicKey', String.Empty));
  if FPublicKey.IsEmpty then
    raise EJSonException.CreateFmt(
      TTLanguage.Instance.Translate(SConfigJWTKeyNotValid), [FKeyID]);
{ /TFeature:rs256 }
(* TFeature:!rs256
  FSecret := AJSon.GetValue<String>('secret', String.Empty);
  if FSecret.IsEmpty then
    raise EJSonException.CreateFmt(
      TTLanguage.Instance.Translate(SConfigJWTKeyNotValid), [FKeyID]);
*)
end;

{ TSecretsConfig }

procedure TSecretsConfig.LoadKeys(const AJSon: TJSonValue);
var
  LKeys: TJSonArray;
  LIndex: Integer;
begin
  FCurrentKeyID := String.Empty;
{ TFeature:rs256 }
  FSigningKey := String.Empty;
{ /TFeature:rs256 }
  FKeys := [];
  if Assigned(AJSon) then
  begin
    FCurrentKeyID := AJSon.GetValue<String>('current', String.Empty);
{ TFeature:rs256 }
    FSigningKey := LoadPem(AJSon.GetValue<String>('signingKey', String.Empty));
{ /TFeature:rs256 }
    LKeys := AJSon.GetValue<TJSonArray>('keys', nil);
    if Assigned(LKeys) then
    begin
      SetLength(FKeys, LKeys.Count);
      for LIndex := 0 to LKeys.Count - 1 do
        FKeys[LIndex].Load(LKeys.Items[LIndex]);
    end;
  end;
end;

procedure TSecretsConfig.CheckKeys;
var
  LIndex, LOther: Integer;
begin
  for LIndex := Low(FKeys) to High(FKeys) do
    for LOther := LIndex + 1 to High(FKeys) do
      if SameText(FKeys[LIndex].KeyID, FKeys[LOther].KeyID) then
        raise EJSonException.CreateFmt(
          TTLanguage.Instance.Translate(SConfigJWTKeyDuplicated),
          [FKeys[LIndex].KeyID]);

  if IndexOfKey(FCurrentKeyID) < 0 then
    raise EJSonException.CreateFmt(
      TTLanguage.Instance.Translate(SConfigJWTKeyNotFound), [FCurrentKeyID]);
end;

procedure TSecretsConfig.Load(const AJSon: TJSonValue);
var
  LKeys: TJSonValue;
begin
  LKeys := nil;
  if Assigned(AJSon) then
  begin
    FPassword := AJSon.GetValue<String>('password', String.Empty);
    LKeys := AJSon.GetValue<TJSonValue>('jwtKeys', nil);
  end;

  LoadKeys(LKeys);

  if FPassword.IsEmpty or (Length(FKeys) = 0) then
    raise EJSonException.Create(
      TTLanguage.Instance.Translate(SConfigSecretsNotFound));

  CheckKeys;
end;

function TSecretsConfig.IndexOfKey(const AKeyID: String): Integer;
var
  LIndex: Integer;
begin
  result := -1;
  LIndex := Low(FKeys);
  while (result < 0) and (LIndex <= High(FKeys)) do
  begin
    if SameText(FKeys[LIndex].KeyID, AKeyID) then
      result := LIndex;
    Inc(LIndex);
  end;
end;

(* TFeature:!rs256
function TSecretsConfig.SecretFor(const AKeyID: String): String;
var
  LIndex: Integer;
begin
  result := String.Empty;
  LIndex := IndexOfKey(AKeyID);
  if LIndex >= 0 then
    result := FKeys[LIndex].Secret;
end;

function TSecretsConfig.CurrentSecret: String;
begin
  result := SecretFor(FCurrentKeyID);
end;
*)

{ TAuthConfig }

procedure TAuthConfig.Load(const AJSon: TJSonValue);
begin
  FAccessTokenMinutes := 20;
  if Assigned(AJSon) then
    FAccessTokenMinutes := AJSon.GetValue<Integer>('accessTokenMinutes', FAccessTokenMinutes);
end;

{ /TFeature:auth }

{ TConnectionPoolConfig }

procedure TConnectionPoolConfig.Load(const AJSon: TJSonValue);
begin
  FEnabled := True;
  FMaximumItems := 25;   // default per connection
  if Assigned(AJSon) then
  begin
    FEnabled := AJSon.GetValue<Boolean>('enabled', FEnabled);
    FMaximumItems := AJSon.GetValue<Integer>('maximumItems', FMaximumItems);
  end;
end;

{ TCorsConfig }

procedure TCorsConfig.Load(const AJSon: TJSonValue);
begin
  if Assigned(AJSon) then
  begin
    FAllowHeaders := AJSon.GetValue<String>('allowHeaders', String.Empty);
    FAllowOrigin := AJSon.GetValue<String>('allowOrigin', String.Empty);
  end;
end;

{ TConfig }

class constructor TConfig.ClassCreate;
begin
  FInstance := nil;
end;

class destructor TConfig.ClassDestroy;
begin
  if Assigned(FInstance) then
    FInstance.Free;
end;

class function TConfig.GetInstance: TConfig;
begin
  if not Assigned(FInstance) then
    FInstance := TConfig.Create;
  result := FInstance;
end;

procedure TConfig.AfterConstruction;
begin
  inherited AfterConstruction;
  LoadFromFile;
end;

function TConfig.GetJSonConfig: TJSonValue;
begin
  result := TJSonConfig.Load(TPath.ChangeExtension(ParamStr(0), '.json'));
end;

procedure TConfig.LoadFromFile;
var
  LJSon: TJSonValue;
begin
  LJSon := GetJSonConfig;
  try
    FServer.Load(LJSon.GetValue<TJSonValue>('server', nil));
(* TFeature:!multitenant
    FDatabase.Load(LJSon.GetValue<TJSonValue>('database', nil), 'database');
*)
{ TFeature:log }
    FLog.Load(LJSon.GetValue<TJSonValue>('log', nil));
{ /TFeature:log }
{ TFeature:auth }
    FSecrets.Load(LJSon.GetValue<TJSonValue>('secrets', nil));
{ /TFeature:auth }
    FConnectionPool.Load(LJSon.GetValue<TJSonValue>('connectionPool', nil));
{ TFeature:auth }
    FAuth.Load(LJSon.GetValue<TJSonValue>('auth', nil));
{ /TFeature:auth }
    FCors.Load(LJSon.GetValue<TJSonValue>('cors', nil));
  finally
    LJSon.Free;
  end;
end;

end.
