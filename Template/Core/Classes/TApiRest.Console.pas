(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Console;

interface

{$IFDEF LINUX}
uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Posix.Unistd,
  Posix.Signal,

  TApiRest.Http;

type

{ TConsoleCommand }

  TConsoleCommand = procedure of object;

{ TConsole }

  TConsole = class
  strict private
    const Reset: Integer = 0;
    const Black: Integer = 30;
    const Red: Integer = 31;
    const Green: Integer = 32;
    const Yellow: Integer = 33;
    const Blue: Integer = 34;
    const Magenta: Integer = 35;
    const Cyan: Integer = 36;
    const White: Integer = 37;
    const Gray: Integer = 90;
  strict private
    FDescription: String;
    FIsInteractive: Boolean;
    FHttp: THttp;
    FCommands: TDictionary<String, TConsoleCommand>;

    procedure SetColor(const AColor: Integer);
    procedure SetColorDefault;

    procedure InvalidCommand(const ACommand: String);

    procedure Start;
    procedure Stop;
    procedure Status;
    procedure ShowCommand(const ACommand: String; const ADescription: String);
    procedure Help;
    procedure SystemInfo;
    procedure About;
    procedure WaitCommand;
    procedure WaitTerminated;
  public
    constructor Create(
      const ADescription: String; const AHttpClass: THttpClass);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure StartService;
  end;
{$ENDIF}

implementation

{$IFDEF LINUX}

{ TConsole }

constructor TConsole.Create(
  const ADescription: String; const AHttpClass: THttpClass);
begin
  inherited Create;
  FDescription := ADescription;
  FIsInteractive := isatty(0) = 1;
  FHttp := AHttpClass.Create;
  FCommands := TDictionary<String, TConsoleCommand>.Create;
end;

destructor TConsole.Destroy;
begin
  FCommands.Free;
  FHttp.Free;
  inherited Destroy;
end;

procedure TConsole.AfterConstruction;
begin
  inherited AfterConstruction;
  FCommands.Add('status', Status);
  FCommands.Add('start', Start);
  FCommands.Add('stop', Stop);
  FCommands.Add('help', Help);
  FCommands.Add('about', About);
  FCommands.Add('systeminfo', SystemInfo);
  FCommands.Add('exit', nil); // nil = exit
end;

procedure TConsole.StartService;
begin
  SystemInfo;
  Writeln;
  About;
  Writeln;

  if FIsInteractive then
  begin
    Help;
    Writeln;
  end;

  Start;
  if FIsInteractive then
    WaitCommand
  else
    WaitTerminated;
  Stop;
end;

procedure TConsole.SetColor(const AColor: Integer);
begin
  if FIsInteractive then
    Write(Format(#$1B'[%dm', [AColor]));
end;

procedure TConsole.SetColorDefault;
begin
  SetColor(Reset);
end;

procedure TConsole.InvalidCommand(const ACommand: String);
begin
  SetColor(Gray);
  Write('Invalid command "');
  SetColor(Red);
  Write(ACommand);
  SetColor(Gray);
  Writeln('".');

  SetColorDefault();
end;

procedure TConsole.Start;
begin
  if not FHttp.Started then
    FHttp.Start;
  Status;
end;

procedure TConsole.Stop;
begin
  if FHttp.Started then
    FHttp.Stop;
  Status;
end;

procedure TConsole.Status;
begin
  SetColor(Gray);
  Write('Service ');
  if FHttp.Started then
  begin
    SetColor(Green);
    Write('started');
    SetColor(Gray);
    Write(' on port ');
    SetColor(Green);
    Writeln(Format('%d', [FHttp.Port]));
  end
  else
  begin
    SetColor(Red);
    Writeln('stopped');
  end;

  SetColorDefault();
end;

procedure TConsole.ShowCommand(
  const ACommand: String; const ADescription: String);
var
  LLen: Integer;
begin
  SetColor(White);
  Write(ACommand);

  LLen := 12 - ACommand.Length;
  if LLen < 1 then
    LLen := 1;

  SetColor(Gray);
  Writeln(Format('%s%s', [String.Create(' ', LLen), ADescription]));
end;

procedure TConsole.Help;
begin
  ShowCommand('systeminfo', 'Show system information');
  ShowCommand('about', 'About this application');
  ShowCommand('help', 'Show available commands');
  ShowCommand('start', 'Start the service');
  ShowCommand('stop', 'Stop the service');
  ShowCommand('status', 'Show service status');
  ShowCommand('exit', 'Exit application');
  SetColorDefault();
end;

procedure TConsole.SystemInfo;
begin
  SetColor(Cyan);
  Writeln(TOSVersion.ToString());

  SetColorDefault();
end;

procedure TConsole.About;
begin
  SetColor(Yellow);
  Writeln('┏┳┓     •┓ ');
  Writeln(' ┃ ┏┓┓┏┏┓┃ ');
  Writeln(' ┻ ┛ ┗┫┛┗┗ ');
  Writeln('      ┛    ');
  Writeln(Format('      %s', [FDescription]));

  SetColorDefault();
end;

procedure TConsole.WaitCommand;
var
  LCommand: String;
  LConsoleCommand: TConsoleCommand;
begin
  while True do
  begin
    Write('# ');
    Flush(Output);
    Readln(LCommand);
    if not FCommands.TryGetValue(
      LCommand.ToLower().Trim(), LConsoleCommand) then
      InvalidCommand(LCommand)
    else if Assigned(LConsoleCommand) then
      LConsoleCommand()
    else
      Break;
  end;
end;

var
  IsTerminated: Boolean = False;

procedure SignalHandler(ASigNum: Integer); cdecl;
begin
  IsTerminated := True;
end;

procedure TConsole.WaitTerminated;
begin
  signal(SIGINT, SignalHandler);
  signal(SIGTERM, SignalHandler);

  while not IsTerminated do
    Sleep(500);
end;

{$ENDIF}

end.
