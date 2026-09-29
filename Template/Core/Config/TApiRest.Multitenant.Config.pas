{ TFeature:multitenant }
(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Multitenant.Config;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSon,
  System.IOUtils,
  Trysil.Consts,
  Trysil.Data.FireDAC,
  Trysil.Http.Exceptions,
  Trysil.Http.MultiTenant.Config,

  TApiRest.Consts,
  TApiRest.DBDrivers;   // registers the FireDAC drivers, do not remove

type

{ TTenantConfigBase }

  TTenantConfigBase = class abstract(TTTenantConfig)
  strict private
    FParameters: TTFireDACConnectionParameters;

    function CreateJSonConfig: TJSonValue;
    procedure LoadFromJSon;
    procedure LoadParameters(const AJSon: TJSonValue);
  strict protected
    const ConnectionPrefix = 'TApi';

    function GetPath: String; virtual; abstract;
    function GetParameters: TTFireDACConnectionParameters; override;
  public
    procedure AfterConstruction; override;
  end;

{ TTenantConfig }

  TTenantConfig = class(TTenantConfigBase)
  strict protected
    function GetPath: String; override;
    function GetConnectionName: String; override;
  end;

{ TFeature:log }

{ TLogTenantConfig }

  TLogTenantConfig = class(TTenantConfigBase)
  strict protected
    function GetPath: String; override;
    function GetConnectionName: String; override;
  end;
{ /TFeature:log }

{ TTenant }

  TTenant = class
  public
    class function NameFromHost(const AHost: String): String;
  end;

implementation

{ TTenantConfigBase }

procedure TTenantConfigBase.AfterConstruction;
begin
  inherited AfterConstruction;
  LoadFromJSon;
end;

function TTenantConfigBase.CreateJSonConfig: TJSonValue;
var
  LFolder, LFileName: String;
begin
  LFolder := TPath.Combine(
    TPath.Combine(
      TPath.GetDirectoryName(ParamStr(0)), 'Tenants'),
    FName);

  if not TDirectory.Exists(LFolder) then
    raise ETHttpUnauthorized.Create(
      TTLanguage.Instance.Translate(SInvalidCredentials));

  LFileName := TPath.Combine(LFolder, '_config.json');

  if not TFile.Exists(LFileName) then
    raise EFileNotFoundException.CreateFmt(
      TTLanguage.Instance.Translate(SConfigNotFound), [LFileName]);

  result := TJSonObject.ParseJSonValue(TFile.ReadAllText(LFileName));
  if not Assigned(result) then
    raise EJSonException.CreateFmt(
      TTLanguage.Instance.Translate(SConfigNotValid), [LFileName]);
end;

procedure TTenantConfigBase.LoadFromJSon;
var
  LJSon: TJSonValue;
begin
  LJSon := CreateJSonConfig;
  try
    LoadParameters(LJSon.GetValue<TJSonValue>(GetPath, nil));
  finally
    LJSon.Free;
  end;
end;

procedure TTenantConfigBase.LoadParameters(const AJSon: TJSonValue);
begin
  if not Assigned(AJSon) then
    raise EJSonException.CreateFmt(
      TTLanguage.Instance.Translate(SConfigDriverNotFound), [GetPath]);

  FParameters.Driver := AJSon.GetValue<String>('driver', String.Empty);
  if FParameters.Driver.IsEmpty then
    raise EJSonException.CreateFmt(
      TTLanguage.Instance.Translate(SConfigDriverNotFound), [GetPath]);

  FParameters.Server := AJSon.GetValue<String>('server', String.Empty);
  FParameters.Port := AJSon.GetValue<Integer>('port', 0);
  FParameters.Username := AJSon.GetValue<String>('username', String.Empty);
  FParameters.Password := AJSon.GetValue<String>('password', String.Empty);
  FParameters.DatabaseName := AJSon.GetValue<String>(
    'databaseName', String.Empty);
end;

function TTenantConfigBase.GetParameters: TTFireDACConnectionParameters;
begin
  result := FParameters;
end;

{ TTenantConfig }

function TTenantConfig.GetPath: String;
begin
  result := 'database';
end;

function TTenantConfig.GetConnectionName: String;
begin
  result := Format('%s_%s', [ConnectionPrefix, FName]);
end;

{ TFeature:log }

{ TLogTenantConfig }

function TLogTenantConfig.GetPath: String;
begin
  result := 'log.database';
end;

function TLogTenantConfig.GetConnectionName: String;
begin
  result := Format('%s_Log_%s', [ConnectionPrefix, FName]);
end;

{ /TFeature:log }

{ TTenant }

class function TTenant.NameFromHost(const AHost: String): String;
begin
  result := AHost.Replace(':', '-', [rfReplaceAll]);
end;

end.
