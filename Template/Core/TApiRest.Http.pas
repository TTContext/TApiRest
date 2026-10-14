(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Http;

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.JSon.Sqids,
  Trysil.Http,
  Trysil.Data.FireDAC.ConnectionPool,

  TApiRest.Config,
(* TFeature:!multitenant
  TApiRest.Connection,
*)
  TApiRest.Context,
{ TFeature:auth }
  TApiRest.Authentication,
{ TFeature:rs256 }
  TApiRest.Authentication.RSAKeys,
{ /TFeature:rs256 }
  TApiRest.Controller.Authentication,
{ /TFeature:auth }
{ TFeature:log }
  TApiRest.Log.LogWriter,
{ /TFeature:log }
  TApiRest.Controller;

type

{ THttp }

  THttp = class
  strict private
    FServer: TTHttpServer<TContext>;

    procedure ConfigureConnectionPool;
(* TFeature:!multitenant
    procedure RegisterConnections;
*)

{ TFeature:auth }
    procedure RegisterAuthentication;
{ /TFeature:auth }
    procedure RegisterControllers;
{ TFeature:log }
    procedure RegisterLog;
{ /TFeature:log }

    function GetPort: Word;
    function GetStarted: Boolean;
  strict protected
    procedure RegisterEntityControllers; virtual; abstract;

    property Server: TTHttpServer<TContext> read FServer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure Start;
    procedure Stop;

    property Port: Word read GetPort;
    property Started: Boolean read GetStarted;
  end;

{ THttpClass }

  THttpClass = class of THttp;

implementation

{ THttp }

constructor THttp.Create;
begin
  inherited Create;
  FServer := TTHttpServer<TContext>.Create;
end;

destructor THttp.Destroy;
begin
  FServer.Free;
  inherited Destroy;
end;

procedure THttp.AfterConstruction;
begin
  inherited AfterConstruction;
  TTJSonSqids.Instance.UseSqids := False;

  ConfigureConnectionPool;
(* TFeature:!multitenant
  RegisterConnections;
*)

  FServer.BaseUri := TConfig.Instance.Server.BaseUri;
  FServer.Port := TConfig.Instance.Server.Port;

  FServer.CorsConfig.AllowHeaders := TConfig.Instance.Cors.AllowHeaders;
  FServer.CorsConfig.AllowOrigin := TConfig.Instance.Cors.AllowOrigin;
(* TFeature:!auth
  FServer.AllowAnonymous := True;
*)

{ TFeature:log }
  RegisterLog;
{ /TFeature:log }
{ TFeature:auth }
{ TFeature:rs256 }
  // RSA keys must be created before the server starts, while single-threaded
  TJWTRSAKeys.Initialize();
{ /TFeature:rs256 }
  RegisterAuthentication;
{ /TFeature:auth }
  RegisterControllers;
end;

procedure THttp.ConfigureConnectionPool;
var
  LConfig: TTFireDACConfigConnectionPool;
begin
  LConfig := TTFireDACConnectionPool.Instance.Config;
  LConfig.Enabled := TConfig.Instance.ConnectionPool.Enabled;
  LConfig.MaximumItems := TConfig.Instance.ConnectionPool.MaximumItems;
end;

(* TFeature:!multitenant
procedure THttp.RegisterConnections;
begin
  TConnectionFactory.RegisterConnections;
end;
*)

{ TFeature:auth }
procedure THttp.RegisterAuthentication;
begin
  FServer.RegisterAuthentication<TAuthentication>();
end;
{ /TFeature:auth }

procedure THttp.RegisterControllers;
begin
{ TFeature:auth }
  FServer.RegisterController<TLoginController>();
  FServer.RegisterController<TChangePasswordController>();
  FServer.RegisterController<TRenewTokenController>();
{ /TFeature:auth }
  RegisterEntityControllers;
end;

{ TFeature:log }
procedure THttp.RegisterLog;
begin
  if TConfig.Instance.Log.Enabled then
    FServer.RegisterLogWriter<TLogWriter>();
end;
{ /TFeature:log }

procedure THttp.Start;
begin
  FServer.Start;
end;

procedure THttp.Stop;
begin
  FServer.Stop;
end;

function THttp.GetPort: Word;
begin
  result := FServer.Port;
end;

function THttp.GetStarted: Boolean;
begin
  result := FServer.Started;
end;

end.
