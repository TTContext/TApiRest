program TApiRestTemplate;

{$IFDEF LINUX}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  System.SysUtils,
(* TFeature:!multitenant
  TApiRest.Connection in 'Core\TApiRest.Connection.pas',
*)
  TApiRest.Consts in 'Core\TApiRest.Consts.pas',
  TApiRest.Context in 'Core\TApiRest.Context.pas',
  TApiRest.DBDrivers in 'Core\TApiRest.DBDrivers.pas',
  TApiRest.Http in 'Core\TApiRest.Http.pas',
{ TFeature:auth }
{ TFeature:rs256 }
  TApiRest.Authentication.RSAKeys in 'Core\Authentication\TApiRest.Authentication.RSAKeys.pas',
{ /TFeature:rs256 }
  TApiRest.Authentication.JWT in 'Core\Authentication\TApiRest.Authentication.JWT.pas',
  TApiRest.Authentication in 'Core\Authentication\TApiRest.Authentication.pas',
{ /TFeature:auth }
  TApiRest.Console in 'Core\Classes\TApiRest.Console.pas',
{ TFeature:auth }
  TApiRest.Password in 'Core\Classes\TApiRest.Password.pas',
{ /TFeature:auth }
  TApiRest.Config.JSon in 'Core\Config\TApiRest.Config.JSon.pas',
  TApiRest.Config in 'Core\Config\TApiRest.Config.pas',
{ TFeature:multitenant }
  TApiRest.Multitenant.Config in 'Core\Config\TApiRest.Multitenant.Config.pas',
{ /TFeature:multitenant }
  TApiRest.Controller in 'Core\Controllers\TApiRest.Controller.pas',
{ TFeature:auth }
  TApiRest.Controller.Authentication in 'Core\Controllers\TApiRest.Controller.Authentication.pas',
{ /TFeature:auth }
{ TFeature:log }
  TApiRest.Log.LogWriter in 'Core\Log\TApiRest.Log.LogWriter.pas',
{ /TFeature:log }
{ TFeature:auth }
  TApiRest.Model.Area in 'Core\Model\TApiRest.Model.Area.pas',
  TApiRest.Model.UserType in 'Core\Model\TApiRest.Model.UserType.pas',
  TApiRest.Model.User in 'Core\Model\TApiRest.Model.User.pas',
  TApiRest.Model.UserTypeArea in 'Core\Model\TApiRest.Model.UserTypeArea.pas',
{ /TFeature:auth }
{ TFeature:log }
(* TFeature:!multitenant
  TApiRest.Model.LogAction in 'Core\Model\TApiRest.Model.LogAction.pas',
*)
  TApiRest.Model.LogRequest in 'Core\Model\TApiRest.Model.LogRequest.pas',
  TApiRest.Model.LogResponse in 'Core\Model\TApiRest.Model.LogResponse.pas',
{ /TFeature:log }
  TApiRestTemplate.Consts in 'TApiRestTemplate.Consts.pas',
  TApiRestTemplate.Http in 'TApiRestTemplate.Http.pas',
  TApiRestTemplate.Target in 'TApiRestTemplate.Target.pas';

{$R *.RES}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}
  TTarget.Run;
end.
