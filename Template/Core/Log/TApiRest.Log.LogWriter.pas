{ TFeature:log }
(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Log.LogWriter;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Context,
  Trysil.Data,
  Trysil.Http.Log.Types,
  Trysil.Http.Log.Writer,
{ TFeature:multitenant }
  Trysil.Http.MultiTenant,

  TApiRest.Multitenant.Config,
{ /TFeature:multitenant }
(* TFeature:!multitenant

  TApiRest.Connection,
  TApiRest.Model.LogAction,
*)
  TApiRest.Model.LogRequest,
  TApiRest.Model.LogResponse;

type

{ TLogWriter }

  TLogWriter = class(TTHttpLogAbstractWriter)
  strict private
{ TFeature:multitenant }
    function CreateLogConnection(const AHost: String): TTConnection;
{ /TFeature:multitenant }
(* TFeature:!multitenant
    procedure InternalWriteAction(const AAction: TTHttpLogAction);
*)
  public
    procedure WriteAction(const AAction: TTHttpLogAction); override;
    procedure WriteRequest(const ARequest: TTHttpLogRequest); override;
    procedure WriteResponse(const AResponse: TTHttpLogResponse); override;
  end;

implementation

{ TLogWriter }

{ TFeature:multitenant }
function TLogWriter.CreateLogConnection(const AHost: String): TTConnection;
begin
  result := TTMultiTenant<TLogTenantConfig>.Instance.GetOrAdd(
    TTenant.NameFromHost(AHost)).Connection.CreateConnection;
end;

procedure TLogWriter.WriteAction(const AAction: TTHttpLogAction);
begin
  // Actions are raised at service/application startup, with no request and
  // therefore no tenant (Host). They cannot be logged per-tenant.
end;
{ /TFeature:multitenant }
(* TFeature:!multitenant
procedure TLogWriter.InternalWriteAction(const AAction: TTHttpLogAction);
var
  LConnection: TTConnection;
  LContext: TTContext;
  LLog: TLogAction;
begin
  LConnection := TConnectionFactory.CreateLogConnection;
  try
    LContext := TTContext.Create(LConnection, False);
    try
      LLog := LContext.CreateEntity<TLogAction>();
      try
        LLog.SetValues(AAction);
        LContext.Insert<TLogAction>(LLog);
      finally
        LContext.FreeEntity<TLogAction>(LLog);
      end;
    finally
      LContext.Free;
    end;
  finally
    LConnection.Free;
  end;
end;

procedure TLogWriter.WriteAction(const AAction: TTHttpLogAction);
begin
  try
    InternalWriteAction(AAction);
  except
    // No exception here
  end;
end;
*)

procedure TLogWriter.WriteRequest(const ARequest: TTHttpLogRequest);
var
  LConnection: TTConnection;
  LContext: TTContext;
  LLog: TLogRequest;
begin
{ TFeature:multitenant }
  LConnection := CreateLogConnection(ARequest.Host);
{ /TFeature:multitenant }
(* TFeature:!multitenant
  LConnection := TConnectionFactory.CreateLogConnection;
*)
  try
    LContext := TTContext.Create(LConnection, False);
    try
      LLog := LContext.CreateEntity<TLogRequest>();
      try
        LLog.SetValues(ARequest);
        LContext.Insert<TLogRequest>(LLog);
      finally
        LContext.FreeEntity<TLogRequest>(LLog);
      end;
    finally
      LContext.Free;
    end;
  finally
    LConnection.Free;
  end;
end;

procedure TLogWriter.WriteResponse(const AResponse: TTHttpLogResponse);
var
  LConnection: TTConnection;
  LContext: TTContext;
  LLog: TLogResponse;
begin
{ TFeature:multitenant }
  LConnection := CreateLogConnection(AResponse.Host);
{ /TFeature:multitenant }
(* TFeature:!multitenant
  LConnection := TConnectionFactory.CreateLogConnection;
*)
  try
    LContext := TTContext.Create(LConnection, False);
    try
      LLog := LContext.CreateEntity<TLogResponse>();
      try
        LLog.SetValues(AResponse);
        LContext.Insert<TLogResponse>(LLog);
      finally
        LContext.FreeEntity<TLogResponse>(LLog);
      end;
    finally
      LContext.Free;
    end;
  finally
    LConnection.Free;
  end;
end;

end.
