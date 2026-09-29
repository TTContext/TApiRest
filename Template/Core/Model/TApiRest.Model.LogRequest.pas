{ TFeature:log }
(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Model.LogRequest;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Http.Log.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes;

type

{ TLogRequest }

  [TTable('Log_Requests')]
  [TSequence('Log_RequestsID')]
  TLogRequest = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
    [TMaxLength(50)]
    [TColumn('TaskID')]
    FTaskID: String;

    [TRequired]
    [TMaxLength(255)]
    [TColumn('Host')]
    FHost: String;

    [TRequired]
    [TColumn('Date')]
    FDate: TDateTime;

    [TRequired]
    [TMaxLength(255)]
    [TColumn('Uri')]
    FUri: String;

    [TColumn('Params')]
    FParams: TTNullable<String>;

    [TRequired]
    [TMaxLength(255)]
    [TColumn('MethodType')]
    FMethodType: String;

    [TColumn('Content')]
    FContent: TTNullable<String>;

    [TColumn('Headers')]
    FHeaders: TTNullable<String>;

    [TRequired]
    [TMaxLength(255)]
    [TColumn('RemoteIP')]
    FRemoteIP: String;

    [TRequired]
    [TMaxLength(255)]
    [TColumn('ClientIP')]
    FClientIP: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    procedure SetValues(const ARequest: TTHttpLogRequest);

    property ID: TTPrimaryKey read FID;
    property TaskID: String read FTaskID;
    property Host: String read FHost;
    property Date: TDateTime read FDate;
    property Uri: String read FUri;
    property Params: TTNullable<String> read FParams;
    property MethodType: String read FMethodType;
    property Content: TTNullable<String> read FContent;
    property Headers: TTNullable<String> read FHeaders;
    property RemoteIP: String read FRemoteIP;
    property ClientIP: String read FClientIP;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

{ TLogRequest }

procedure TLogRequest.SetValues(const ARequest: TTHttpLogRequest);
begin
  FTaskID := ARequest.TaskID.ToString;
  FHost := ARequest.Host;
  FDate := ARequest.DateTime;
  FUri := ARequest.Uri;
  FParams := ARequest.Params.ToString;
  FMethodType := ARequest.MethodType;
  FContent := ARequest.Content;
  FHeaders := ARequest.Headers.ToString;
  FRemoteIP := ARequest.RemoteIP;
  FClientIP := ARequest.ClientIP;
end;

end.
