unit TApiRestTemplate.Http;

interface

uses
  System.SysUtils,
  System.Classes,
{ TFeature:openapi }
  Trysil.OpenAPI.Types,

  TApiRestTemplate.Consts,
{ /TFeature:openapi }

  TApiRest.Http;

type

{ TApiRestTemplateHttp }

  TApiRestTemplateHttp = class(THttp)
  strict protected
    procedure RegisterEntityControllers; override;
{ TFeature:openapi }
    function OpenApiInfo: TTOpenApiInfo; override;
{ /TFeature:openapi }
  end;

implementation

{ TApiRestTemplateHttp }

procedure TApiRestTemplateHttp.RegisterEntityControllers;
begin
end;

{ TFeature:openapi }
function TApiRestTemplateHttp.OpenApiInfo: TTOpenApiInfo;
begin
  result := TTOpenApiInfo.Create(SAppDescription, '1.0');
end;
{ /TFeature:openapi }

end.
