{ TFeature:log }
{ TFeature:!multitenant }
(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Model.LogAction;

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

{ TLogAction }

  [TTable('Log_Actions')]
  [TSequence('Log_ActionsID')]
  TLogAction = class
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

    [TRequired]
    [TColumn('Action')]
    FAction: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    procedure SetValues(const AAction: TTHttpLogAction);

    property ID: TTPrimaryKey read FID;
    property TaskID: String read FTaskID;
    property Date: TDateTime read FDate;
    property Action: String read FAction;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

{ TLogAction }

procedure TLogAction.SetValues(const AAction: TTHttpLogAction);
begin
  FTaskID := AAction.TaskID;
  FDate := AAction.DateTime;
  FAction := AAction.Action;
end;

end.
