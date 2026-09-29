{ TFeature:log }
(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Model.LogResponse;

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

{ TLogResponse }

  [TTable('Log_Responses')]
  [TSequence('Log_ResponsesID')]
  TLogResponse = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
    [TMaxLength(50)]
    [TColumn('TaskID')]
    FTaskID: String;

    [TRequired]
    [TColumn('Date')]
    FDate: TDateTime;

    [TMaxLength(255)]
    [TColumn('Username')]
    FUsername: String;

    [TColumn('UserAreas')]
    FUserAreas: TTNullable<String>;

    [TRequired]
    [TColumn('StatusCode')]
    FStatusCode: Integer;

    [TRequired]
    [TMaxLength(255)]
    [TColumn('ContentType')]
    FContentType: String;

    [TRequired]
    [TMaxLength(255)]
    [TColumn('ContentEncoding')]
    FContentEncoding: String;

    [TColumn('Content')]
    FContent: TTNullable<String>;

    [TColumn('BinaryContent')]
    FBinaryContent: TTNullable<String>;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    procedure SetValues(const AResponse: TTHttpLogResponse);

    property ID: TTPrimaryKey read FID;
    property TaskID: String read FTaskID;
    property Date: TDateTime read FDate;
    property Username: String read FUsername;
    property UserAreas: TTNullable<String> read FUserAreas;
    property StatusCode: Integer read FStatusCode;
    property ContentType: String read FContentType;
    property ContentEncoding: String read FContentEncoding;
    property Content: TTNullable<String> read FContent;
    property BinaryContent: TTNullable<String> read FBinaryContent;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

{ TLogResponse }

procedure TLogResponse.SetValues(const AResponse: TTHttpLogResponse);
begin
  FTaskID := AResponse.TaskID.ToString;
  FDate := AResponse.DateTime;
  FUsername := AResponse.User.Username;
  FUserAreas := AResponse.User.Areas.ToString;
  FStatusCode := AResponse.StatusCode;
  FContentType := AResponse.ContentType;
  FContentEncoding := AResponse.ContentEncoding;
  FContent := AResponse.Content;
  FBinaryContent := AResponse.BinaryContent;
end;

end.
