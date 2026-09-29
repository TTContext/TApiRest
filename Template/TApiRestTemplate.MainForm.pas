unit TApiRestTemplate.MainForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Menus,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  Vcl.ImgList,
  Vcl.Clipbrd,
  FireDAC.ConsoleUI.Wait,
  FireDAC.VCLUI.Wait,
  IdStack,
  IdStackWindows,

  TApiRest.Config,
  TApiRest.Http,

  TApiRestTemplate.Consts,
  TApiRestTemplate.Http;

type

{ TMainForm }

  TMainForm = class(TForm)
    ImageList: TImageList;
    PopupMenu: TPopupActionBar;
    UrlMenuItem: TMenuItem;
    Separator01MenuItem: TMenuItem;
    StartMenuItem: TMenuItem;
    StopMenuItem: TMenuItem;
    Separator02MenuItem: TMenuItem;
    TerminateMenuItem: TMenuItem;
    TrayIcon: TTrayIcon;
    procedure PopupMenuPopup(Sender: TObject);
    procedure StartMenuItemClick(Sender: TObject);
    procedure StopMenuItemClick(Sender: TObject);
    procedure TerminateMenuItemClick(Sender: TObject);
    procedure UrlMenuItemClick(Sender: TObject);
  strict private
    FHttp: THttp;

    function GetUrl: String;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AfterConstruction; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{ TMainForm }

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := SAppDescription;
  TrayIcon.Hint := SAppDescription;
  FHttp := TApiRestTemplateHttp.Create;
end;

destructor TMainForm.Destroy;
begin
  if FHttp.Started then
    FHttp.Stop;
  FHttp.Free;
  inherited Destroy;
end;

procedure TMainForm.AfterConstruction;
begin
  inherited AfterConstruction;
  FHttp.Start;
end;

function TMainForm.GetUrl: String;
var
  LStack: TIdStack;
begin
  LStack := TIdStackWindows.Create;
  try
    result := Format('http://%s:%d', [LStack.LocalAddress, FHttp.Port]);
    if not TConfig.Instance.Server.BaseUri.IsEmpty then
      result := Format('%s/%s', [result, TConfig.Instance.Server.BaseUri]);
    result := result.ToLower();
  finally
    LStack.Free;
  end;
end;

procedure TMainForm.PopupMenuPopup(Sender: TObject);
begin
  UrlMenuItem.Caption := GetUrl();
  StopMenuItem.Enabled := FHttp.Started;
  StartMenuItem.Enabled := not StopMenuItem.Enabled;
end;

procedure TMainForm.UrlMenuItemClick(Sender: TObject);
begin
  Clipboard.AsText := GetUrl();
end;

procedure TMainForm.StartMenuItemClick(Sender: TObject);
begin
  FHttp.Start;
end;

procedure TMainForm.StopMenuItemClick(Sender: TObject);
begin
  FHttp.Stop;
end;

procedure TMainForm.TerminateMenuItemClick(Sender: TObject);
begin
  Close;
end;

end.
