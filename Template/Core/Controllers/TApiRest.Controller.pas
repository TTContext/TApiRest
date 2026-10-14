(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Controller;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
{ TFeature:openapi }
  System.TypInfo,
{ /TFeature:openapi }
  Trysil.Types,
  Trysil.Filter,
  Trysil.Data,
  Trysil.Http.Attributes,
  Trysil.Http.Classes,
  Trysil.Http.Context,
  Trysil.Http.Filter,
  Trysil.Http.Controller,
  Trysil.Http.Entity,
{ TFeature:openapi }
  Trysil.OpenAPI.Types,
  Trysil.OpenAPI.Attributes,
{ /TFeature:openapi }
{ TFeature:multitenant }
  Trysil.Http.MultiTenant,
{ /TFeature:multitenant }

  TApiRest.Context,
{ TFeature:multitenant }
  TApiRest.Multitenant.Config;
{ /TFeature:multitenant }
(* TFeature:!multitenant
  TApiRest.Connection;
*)

type

{ TController }

  TController = class(TTHttpController<TContext>)
  strict private
{ TFeature:multitenant }
    FTenantName: String;
    FTenant: TTTenant<TTenantConfig>;
{ /TFeature:multitenant }
    FConnection: TTConnection;
    FHttpContext: TTHttpContext;

    function GetHttpContext: TTHttpContext;
  strict protected
{ TFeature:multitenant }
    property TenantName: String read FTenantName;
    property Tenant: TTTenant<TTenantConfig> read FTenant;
{ /TFeature:multitenant }
    property HttpContext: TTHttpContext read GetHttpContext;
  public
    constructor Create(
      const AContext: TContext;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
    destructor Destroy; override;
  end;

{ TReadOnlyController<T> }

  TReadOnlyController<T: class> = class(TController)
  strict private
    FReader: TTHttpEntityReader<T>;

    function GetReader: TTHttpEntityReader<T>;
  strict protected
    function GetFilterParameters: TTHttpFilterParameters; virtual;

    procedure AddEntityFilter(var AFilter: TTFilter); virtual;
    procedure BeforeSerializeEntity(const AEntity: T); virtual;

    property Reader: TTHttpEntityReader<T> read GetReader;
  public
    constructor Create(
      const AContext: TContext;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
    destructor Destroy; override;

{ TFeature:openapi }
    class function EntityClass: TClass; override;

{ /TFeature:openapi }
    [TGet('/?')]
{ TFeature:openapi }
    [TSummary('Read by ID')]
    [TResponse(200, TTOpenApiShape.Single, 'The entity, with its details')]
{ /TFeature:openapi }
    procedure Get(const AID: TTPrimaryKey); virtual;

    [TGet]
{ TFeature:openapi }
    [TSummary('Read all')]
    [TResponse(200, TTOpenApiShape.Page, 'Count and rows')]
{ /TFeature:openapi }
    procedure SelectAll; virtual;

    [TPost('/select')]
{ TFeature:openapi }
    [TSummary('Read with a filter')]
    [TRequestBody(TTOpenApiFilter, TTOpenApiShape.Single, 'Filter')]
    [TResponse(200, TTOpenApiShape.Page, 'Count and rows')]
{ /TFeature:openapi }
    procedure Select; virtual;

    [TGet('/find/?')]
{ TFeature:openapi }
    [TSummary('Read by ID, without details')]
    [TResponse(200, TTOpenApiShape.Single, 'The entity')]
{ /TFeature:openapi }
    procedure Find(const AID: TTPrimaryKey); virtual;

    [TGet('/metadata')]
{ TFeature:openapi }
    [TSummary('Metadata')]
    [TResponse(
      200, TTOpenApiMetadata, TTOpenApiShape.Single, 'Columns and keys')]
{ /TFeature:openapi }
    procedure Metadata; virtual;
  end;

{ TReadWriteController<T> }

  TReadWriteController<T: class> = class(TReadOnlyController<T>)
  strict private
    FWriter: TTHttpEntityWriter<T>;

    function GetWriter: TTHttpEntityWriter<T>;
  strict protected
    procedure BeforeInsert(const AEntity: T); virtual;
    procedure AfterInsert(const AEntity: T); virtual;
    procedure BeforeUpdate(const AEntity: T); virtual;
    procedure AfterUpdate(const AEntity: T); virtual;
    procedure BeforeDelete(const AEntity: T); virtual;
    procedure AfterDelete(const AEntity: T); virtual;
    procedure ApplyDetails(const AEntity: T); virtual;

    property Writer: TTHttpEntityWriter<T> read GetWriter;
  public
    constructor Create(
      const AContext: TContext;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
    destructor Destroy; override;

    [TPost]
{ TFeature:openapi }
    [TSummary('Insert')]
    [TRequestBody(TTOpenApiShape.Single, 'The entity to insert')]
    [TResponse(200, TTOpenApiShape.Single, 'The inserted entity')]
{ /TFeature:openapi }
    procedure Insert; virtual;

    [TPut]
{ TFeature:openapi }
    [TSummary('Update')]
    [TRequestBody(TTOpenApiShape.Single, 'The entity to update')]
    [TResponse(200, TTOpenApiShape.Single, 'The updated entity')]
    [TResponse(404, 'The entity does not exist')]
    [TResponse(409, 'The version changed in the meantime')]
{ /TFeature:openapi }
    procedure Update; virtual;

    [TDelete('/?/?')]
{ TFeature:openapi }
    [TSummary('Delete')]
    [TResponse(200, 'Deleted')]
    [TResponse(409, 'The version changed in the meantime')]
{ /TFeature:openapi }
    procedure Delete(
      const AID: TTPrimaryKey;
      [TNotSqid] const AVersionID: TTVersion); virtual;

    [TGet('/createnew')]
{ TFeature:openapi }
    [TSummary('A new entity with its defaults')]
    [TResponse(200, TTOpenApiShape.Single, 'The new entity')]
{ /TFeature:openapi }
    procedure CreateNew; virtual;
  end;

implementation

{ TController }

constructor TController.Create(
  const AContext: TContext;
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
begin
  inherited Create(AContext, ARequest, AResponse);
{ TFeature:multitenant }
  FTenantName := TTenant.NameFromHost(ARequest.Host);
  FTenant := TTMultiTenant<TTenantConfig>.Instance.GetOrAdd(FTenantName);
{ /TFeature:multitenant }
  FConnection := nil;
  FHttpContext := nil;
end;

destructor TController.Destroy;
begin
  if Assigned(FHttpContext) then
    FHttpContext.Free;
  if Assigned(FConnection) then
    FConnection.Free;
  inherited Destroy;
end;

function TController.GetHttpContext: TTHttpContext;
begin
  if not Assigned(FConnection) then
{ TFeature:multitenant }
    FConnection := FTenant.Connection.CreateConnection;
{ /TFeature:multitenant }
(* TFeature:!multitenant
    FConnection := TConnectionFactory.CreateConnection;
*)
  if not Assigned(FHttpContext) then
    FHttpContext := TTHttpContext.Create(FConnection, False);
  result := FHttpContext;
end;

{ TReadOnlyController<T> }

{ TFeature:openapi }
class function TReadOnlyController<T>.EntityClass: TClass;
begin
  result := GetTypeData(TypeInfo(T))^.ClassType;
end;

{ /TFeature:openapi }
constructor TReadOnlyController<T>.Create(
  const AContext: TContext;
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
begin
  inherited Create(AContext, ARequest, AResponse);
  FReader := nil;
end;

destructor TReadOnlyController<T>.Destroy;
begin
  if Assigned(FReader) then
    FReader.Free;
  inherited Destroy;
end;

function TReadOnlyController<T>.GetReader: TTHttpEntityReader<T>;
begin
  if not Assigned(FReader) then
  begin
    FReader := TTHttpEntityReader<T>.Create(HttpContext, GetFilterParameters);
    FReader.OnAddEntityFilter := AddEntityFilter;
    FReader.OnBeforeSerializeEntity := BeforeSerializeEntity;
  end;
  result := FReader;
end;

function TReadOnlyController<T>.GetFilterParameters: TTHttpFilterParameters;
begin
  result := TTHttpFilterParameters.Defaults;
end;

procedure TReadOnlyController<T>.AddEntityFilter(var AFilter: TTFilter);
begin
end;

procedure TReadOnlyController<T>.BeforeSerializeEntity(const AEntity: T);
begin
end;

procedure TReadOnlyController<T>.Get(const AID: TTPrimaryKey);
begin
  FResponse.Content := Reader.Get(AID);
end;

procedure TReadOnlyController<T>.SelectAll;
begin
  FResponse.Content := Reader.SelectAll;
end;

procedure TReadOnlyController<T>.Select;
begin
  FResponse.Content := Reader.Select(FRequest.JSonContent);
end;

procedure TReadOnlyController<T>.Find(const AID: TTPrimaryKey);
begin
  FResponse.Content := Reader.Find(AID);
end;

procedure TReadOnlyController<T>.Metadata;
begin
  FResponse.Content := Reader.Metadata;
end;

{ TReadWriteController<T> }

constructor TReadWriteController<T>.Create(
  const AContext: TContext;
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
begin
  inherited Create(AContext, ARequest, AResponse);
  FWriter := nil;
end;

destructor TReadWriteController<T>.Destroy;
begin
  if Assigned(FWriter) then
    FWriter.Free;
  inherited Destroy;
end;

function TReadWriteController<T>.GetWriter: TTHttpEntityWriter<T>;
begin
  if not Assigned(FWriter) then
  begin
    FWriter := TTHttpEntityWriter<T>.Create(HttpContext);
    FWriter.OnBeforeInsert := BeforeInsert;
    FWriter.OnAfterInsert := AfterInsert;
    FWriter.OnBeforeUpdate := BeforeUpdate;
    FWriter.OnAfterUpdate := AfterUpdate;
    FWriter.OnBeforeDelete := BeforeDelete;
    FWriter.OnAfterDelete := AfterDelete;
    FWriter.OnApplyDetails := ApplyDetails;
  end;
  result := FWriter;
end;

procedure TReadWriteController<T>.BeforeInsert(const AEntity: T);
begin
end;

procedure TReadWriteController<T>.AfterInsert(const AEntity: T);
begin
end;

procedure TReadWriteController<T>.BeforeUpdate(const AEntity: T);
begin
end;

procedure TReadWriteController<T>.AfterUpdate(const AEntity: T);
begin
end;

procedure TReadWriteController<T>.BeforeDelete(const AEntity: T);
begin
end;

procedure TReadWriteController<T>.AfterDelete(const AEntity: T);
begin
end;

procedure TReadWriteController<T>.ApplyDetails(const AEntity: T);
begin
end;

procedure TReadWriteController<T>.Insert;
begin
  FResponse.Content := Writer.Insert(FRequest.JSonContent);
end;

procedure TReadWriteController<T>.Update;
begin
  FResponse.Content := Writer.Update(FRequest.JSonContent);
end;

procedure TReadWriteController<T>.Delete(
  const AID: TTPrimaryKey; const AVersionID: TTVersion);
begin
  Writer.Delete(AID, AVersionID);
end;

procedure TReadWriteController<T>.CreateNew;
begin
  FResponse.Content := Writer.CreateNew;
end;

end.
