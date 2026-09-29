unit TApiRestTemplate.Target;

interface

uses
  System.SysUtils,

  TApiRestTemplate.Consts,
{$IFDEF MSWINDOWS}
  Vcl.Forms,
  Vcl.SvcMgr,

  TApiRestTemplate.MainForm,
  TApiRestTemplate.MainService;
{$ENDIF}

{$IFDEF LINUX}
  TApiRest.Console,

  TApiRestTemplate.Http;
{$ENDIF}

type

{ TTarget }

  TTarget = class
  strict private
{$IFDEF MSWINDOWS}
    class procedure RunDebug;
    class procedure RunService;
{$ENDIF}
{$IFDEF LINUX}
    class procedure RunConsole;
{$ENDIF}
  public
    class procedure Run;
  end;

implementation

{$IFDEF MSWINDOWS}
class procedure TTarget.RunDebug;
begin
  Vcl.Forms.Application.Initialize;
  Vcl.Forms.Application.MainFormOnTaskbar := False;
  Vcl.Forms.Application.ShowMainForm := False;
  Vcl.Forms.Application.Title := SAppDescription;
  Vcl.Forms.Application.CreateForm(TMainForm, MainForm);
  Vcl.Forms.Application.Run;
end;

class procedure TTarget.RunService;
begin
  if not Vcl.SvcMgr.Application.DelayInitialize or
    Vcl.SvcMgr.Application.Installing then
    Vcl.SvcMgr.Application.Initialize;
  Vcl.SvcMgr.Application.CreateForm(TApiRestTemplateService, ApiRestTemplateService);
  Vcl.SvcMgr.Application.Run;
end;
{$ENDIF}

{$IFDEF LINUX}
class procedure TTarget.RunConsole;
var
  LConsole: TConsole;
begin
  try
    LConsole := TConsole.Create(SAppDescription, TApiRestTemplateHttp);
    try
      LConsole.StartService;
    finally
      LConsole.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end;
{$ENDIF}

class procedure TTarget.Run;
begin
{$IFDEF MSWINDOWS}
  if FindCmdLineSwitch('debug', True) then
    RunDebug
  else
    RunService;
{$ENDIF}
{$IFDEF LINUX}
  RunConsole;
{$ENDIF}
end;

end.
