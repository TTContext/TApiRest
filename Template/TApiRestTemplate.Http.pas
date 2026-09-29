unit TApiRestTemplate.Http;

interface

uses
  System.SysUtils,
  System.Classes,

  TApiRest.Http;

type

{ TApiRestTemplateHttp }

  TApiRestTemplateHttp = class(THttp)
  strict protected
    procedure RegisterEntityControllers; override;
  end;

implementation

{ TApiRestTemplateHttp }

procedure TApiRestTemplateHttp.RegisterEntityControllers;
begin
end;

end.
