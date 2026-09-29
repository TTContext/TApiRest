{ TFeature:!multitenant }
(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Connection;

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Data,
  Trysil.Data.FireDAC,

  TApiRest.Config,
  TApiRest.DBDrivers;   // registers the FireDAC drivers, do not remove

type

{ TConnectionFactory }

  TConnectionFactory = class
  strict private
    const DataConnectionName: String = 'TApi';
{ TFeature:log }
    const LogConnectionName: String = 'TApi_Log';
{ /TFeature:log }
  public
    class procedure RegisterConnections;

    class function CreateConnection: TTConnection;
{ TFeature:log }
    class function CreateLogConnection: TTConnection;
{ /TFeature:log }
  end;

implementation

{ TConnectionFactory }

class procedure TConnectionFactory.RegisterConnections;
var
  LFactory: TTFireDACConnectionFactory;
begin
  LFactory := TTFireDACConnectionFactory.Instance;
  LFactory.RegisterConnection(
    DataConnectionName, TConfig.Instance.Database.Parameters);
{ TFeature:log }
  if TConfig.Instance.Log.Enabled then
    LFactory.RegisterConnection(
      LogConnectionName, TConfig.Instance.Log.Database.Parameters);
{ /TFeature:log }
end;

class function TConnectionFactory.CreateConnection: TTConnection;
begin
  result := TTFireDACConnectionFactory.Instance.CreateConnection(
    DataConnectionName);
end;

{ TFeature:log }
class function TConnectionFactory.CreateLogConnection: TTConnection;
begin
  result := TTFireDACConnectionFactory.Instance.CreateConnection(
    LogConnectionName);
end;
{ /TFeature:log }

end.
