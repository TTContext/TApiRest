unit TApiRestTemplate.MainService;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Win.Registry,
  Vcl.SvcMgr,
  FireDAC.ConsoleUI.Wait,
  FireDAC.VCLUI.Wait,

  TApiRest.Http,

  TApiRestTemplate.Consts,
  TApiRestTemplate.Http;

type

{ TApiRestTemplateService }

  TApiRestTemplateService = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceExecute(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceAfterUninstall(Sender: TService);
  strict private
    FHttp: THttp;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetServiceController: TServiceController; override;
  end;

var
  ApiRestTemplateService: TApiRestTemplateService;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ApiRestTemplateService.Controller(CtrlCode);
end;

{ TApiRestTemplateService }

constructor TApiRestTemplateService.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DisplayName := SAppDescription;
  FHttp := TApiRestTemplateHttp.Create;
end;

destructor TApiRestTemplateService.Destroy;
begin
  FHttp.Free;
  inherited Destroy;
end;

function TApiRestTemplateService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TApiRestTemplateService.ServiceStart(
  Sender: TService; var Started: Boolean);
begin
  FHttp.Start;
  Started := FHttp.Started;
end;

procedure TApiRestTemplateService.ServiceStop(
  Sender: TService; var Stopped: Boolean);
begin
  FHttp.Stop;
  Stopped := not FHttp.Started;
end;

procedure TApiRestTemplateService.ServiceExecute(Sender: TService);
begin
  while not Terminated do
    ServiceThread.ProcessRequests(True);
end;

procedure TApiRestTemplateService.ServiceAfterInstall(Sender: TService);
var
  LRegistryKey: String;
  LRegistry: TRegistry;
begin
  LRegistryKey := '\SYSTEM\CurrentControlSet\Services\' + Self.Name;
  LRegistry := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    LRegistry.RootKey := HKEY_LOCAL_MACHINE;
    if LRegistry.OpenKey(LRegistryKey, False) then
    try
      LRegistry.WriteString('Description', SAppDescription);
    finally
      LRegistry.CloseKey;
    end;
  finally
    LRegistry.Free;
  end;
end;

procedure TApiRestTemplateService.ServiceAfterUninstall(Sender: TService);
var
  LRegistryKey: String;
  LRegistry: TRegistry;
begin
  LRegistryKey := '\SYSTEM\CurrentControlSet\Services\' + Self.Name;
  LRegistry := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    LRegistry.RootKey := HKEY_LOCAL_MACHINE;
    if LRegistry.KeyExists(LRegistryKey) then
        LRegistry.DeleteKey(LRegistryKey);
  finally
    LRegistry.Free;
  end;
end;

end.
