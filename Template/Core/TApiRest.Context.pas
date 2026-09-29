(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Context;

interface

{ TFeature:auth }
uses
  System.Classes,
  System.SysUtils,

  TApiRest.Authentication.JWT;
{ /TFeature:auth }

type

{ TContext }

  TContext = class
{ TFeature:auth }
  strict private
    FPayload: TJWTPayload;
{ /TFeature:auth }
  public
    constructor Create;
    destructor Destroy; override;
{ TFeature:auth }

    property Payload: TJWTPayload read FPayload;
{ /TFeature:auth }
  end;

implementation

{ TContext }

constructor TContext.Create;
begin
  inherited Create;
{ TFeature:auth }
  FPayload := TJWTPayload.Create;
{ /TFeature:auth }
end;

destructor TContext.Destroy;
begin
{ TFeature:auth }
  FPayload.Free;
{ /TFeature:auth }
  inherited Destroy;
end;

end.
