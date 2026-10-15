{ TFeature:auth }
(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Controller.Authentication;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  Trysil.Consts,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes,
  Trysil.Generics.Collections,
  Trysil.Filter,
  Trysil.Http.Consts,
  Trysil.Http.Types,
  Trysil.Http.Attributes,
  Trysil.Http.Exceptions,
  Trysil.Http.Classes,
  Trysil.Http.JWT,
  Trysil.JSon.Types,
{ TFeature:openapi }
  Trysil.OpenAPI.Types,
  Trysil.OpenAPI.Attributes,
{ /TFeature:openapi }

  TApiRest.Consts,
  TApiRest.Context,
  TApiRest.Controller,
  TApiRest.Authentication.JWT,
  TApiRest.Model.User,
  TApiRest.Model.UserTypeArea,
  TApiRest.Password;

type

{ TLoginRequest }

  TLoginRequest = class
  strict private
    [TColumn('Email')]
    [TRequired]
    FEmail: String;

    [TColumn('Password')]
    [TRequired]
    FPassword: String;
  public
    property Email: String read FEmail;
    property Password: String read FPassword;
  end;

{ TChangePasswordRequest }

  TChangePasswordRequest = class
  strict private
    [TColumn('OldPassword')]
    [TRequired]
    FOldPassword: String;

    [TColumn('NewPassword')]
    [TRequired]
    FNewPassword: String;
  public
    property OldPassword: String read FOldPassword;
    property NewPassword: String read FNewPassword;
  end;

{ TTokenResponse }

  TTokenResponse = class
  strict private
    [TColumn('Token')]
    FToken: String;
  public
    constructor Create(const AToken: String);

    property Token: String read FToken;
  end;

{ TAuthenticationController }

  [TUri('/auth')]
  TAuthenticationController = class(TController)
  strict protected
    procedure ReadRequest<T: class>(const ARequest: T);
    procedure AddPayloadAreas(
      const AUser: TUser; const AAree: TList<String>);
    procedure SelectUsers(
      const AUsers: TTList<TUser>; const AEmail: String);
    procedure VerifyPassword(
      const AUser: TUser; const APassword: String);
    procedure VerifyEnabled(const AUser: TUser);
    procedure SetPassword(const AUser: TUser; const APassword: String);
    procedure HashPlainPassword(
      const AUser: TUser; const APassword: String);
    function CreateToken(
{ TFeature:multitenant }
      const ATenant: String;
{ /TFeature:multitenant }
      const AUser: TUser): String;
    procedure ResponseToken(
{ TFeature:multitenant }
      const ATenant: String;
{ /TFeature:multitenant }
      const AUser: TUser);
  end;

{ TLoginController }

  [TAuthorizationType(TTHttpAuthorizationType.None)]
  TLoginController = class(TAuthenticationController)
  strict private
    procedure LoginUser(const ARequest: TLoginRequest);
  public
    [TPost('/login')]
{ TFeature:openapi }
    [TSummary('Login')]
    [TRequestBody(TLoginRequest, TTOpenApiShape.Single, 'Credentials')]
    [TResponse(200, TTokenResponse, TTOpenApiShape.Single, 'The token')]
    [TResponse(401, 'Invalid credentials')]
{ /TFeature:openapi }
    procedure Login;
  end;

{ TChangePasswordController }

  TChangePasswordController = class(TAuthenticationController)
  strict private
    procedure ChangeUserPassword(const ARequest: TChangePasswordRequest);
  public
    [TPost('/changepassword')]
{ TFeature:openapi }
    [TSummary('Change the password')]
    [TRequestBody(
      TChangePasswordRequest, TTOpenApiShape.Single, 'Old and new password')]
    [TResponse(200, TTokenResponse, TTOpenApiShape.Single, 'A new token')]
{ /TFeature:openapi }
    procedure ChangePassword;
  end;

{ TRenewTokenController }

  TRenewTokenController = class(TAuthenticationController)
  public
    [TPost('/renewtoken')]
{ TFeature:openapi }
    [TSummary('Renew the token')]
    [TResponse(200, TTokenResponse, TTOpenApiShape.Single, 'A new token')]
{ /TFeature:openapi }
    procedure RenewToken;
  end;

implementation

{ TTokenResponse }

constructor TTokenResponse.Create(const AToken: String);
begin
  inherited Create;
  FToken := AToken;
end;

{ TAuthenticationController }

procedure TAuthenticationController.ReadRequest<T>(const ARequest: T);
begin
  HttpContext.EntityFromJSonObject<T>(FRequest.JSonContent, ARequest);
  HttpContext.Validate<T>(ARequest);
end;

procedure TAuthenticationController.AddPayloadAreas(
  const AUser: TUser; const AAree: TList<String>);
var
  LAree: TTList<TUserTypeArea>;
  LFilter: TTFilter;
  LArea: TUserTypeArea;
begin
  LAree := HttpContext.CreateEntityList<TUserTypeArea>();
  try
    LFilter := TTFilter.Create('UserTypeID = :UserTypeID');
    LFilter.AddParameter('UserTypeID', ftInteger, AUser.UserType.ID);
    HttpContext.Select<TUserTypeArea>(LAree, LFilter);
    for LArea in LAree do
      AAree.Add(LArea.Area.Description);
  finally
    LAree.Free;
  end;
end;

procedure TAuthenticationController.SelectUsers(
  const AUsers: TTList<TUser>; const AEmail: String);
var
  LFilter: TTFilter;
begin
  LFilter := TTFilter.Create('Email = :Email');
  LFilter.AddParameter('Email', ftWideString, 255, AEmail);
  HttpContext.Select<TUser>(AUsers, LFilter);
  if AUsers.Count <> 1 then
    raise ETHttpUnauthorized.Create(
      TTLanguage.Instance.Translate(SInvalidCredentials));
end;

procedure TAuthenticationController.VerifyPassword(
  const AUser: TUser; const APassword: String);
begin
  if not TPassword.Verify(APassword, AUser.Salt, AUser.Password) then
    raise ETHttpUnauthorized.Create(
      TTLanguage.Instance.Translate(SInvalidCredentials));
end;

procedure TAuthenticationController.VerifyEnabled(const AUser: TUser);
begin
  if not AUser.DisabledAt.IsNull then
    raise ETHttpUnauthorized.Create(
      TTLanguage.Instance.Translate(SInvalidCredentials));
end;

procedure TAuthenticationController.SetPassword(
  const AUser: TUser; const APassword: String);
begin
  AUser.Salt := TPassword.NewSalt;
  AUser.Password := TPassword.Encode(APassword, AUser.Salt);
end;

procedure TAuthenticationController.HashPlainPassword(
  const AUser: TUser; const APassword: String);
begin
  if AUser.Salt.IsEmpty then
  begin
    SetPassword(AUser, APassword);
    HttpContext.Update<TUser>(AUser);
  end;
end;

function TAuthenticationController.CreateToken(
{ TFeature:multitenant }
  const ATenant: String;
{ /TFeature:multitenant }
  const AUser: TUser): String;
var
  LPayload: TJWTPayload;
  LJWT: TTHttpJWT<TJWTPayload>;
begin
  LPayload := TJWTPayload.Create;
  try
    LPayload.ID := AUser.ID;
    LPayload.Firstname := AUser.Firstname;
    LPayload.Lastname := AUser.Lastname;
    LPayload.UserTypeID := AUser.UserType.ID;
    LPayload.Email := AUser.Email;
{ TFeature:multitenant }
    LPayload.Tenant := ATenant;
{ /TFeature:multitenant }

    AddPayloadAreas(AUser, LPayload.Areas);

    LJWT := TTHttpJWT<TJWTPayload>.Create(LPayload);
    try
      result := LJWT.ToToken();
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;
end;

procedure TAuthenticationController.ResponseToken(
{ TFeature:multitenant }
  const ATenant: String;
{ /TFeature:multitenant }
  const AUser: TUser);
var
  LResponse: TTokenResponse;
begin
  LResponse := TTokenResponse.Create(
    CreateToken({ TFeature:multitenant }ATenant, { /TFeature:multitenant }AUser));
  try
    FResponse.Content := HttpContext.EntityToJSon<TTokenResponse>(
      LResponse, TTJSonSerializerConfig.Default);
  finally
    LResponse.Free;
  end;
end;

{ TLoginController }

procedure TLoginController.Login;
var
  LRequest: TLoginRequest;
begin
  LRequest := TLoginRequest.Create;
  try
    ReadRequest<TLoginRequest>(LRequest);
    LoginUser(LRequest);
  finally
    LRequest.Free;
  end;
end;

procedure TLoginController.LoginUser(const ARequest: TLoginRequest);
var
  LUsers: TTList<TUser>;
begin
  LUsers := HttpContext.CreateEntityList<TUser>();
  try
    SelectUsers(LUsers, ARequest.Email);
    VerifyPassword(LUsers[0], ARequest.Password);
    VerifyEnabled(LUsers[0]);
    HashPlainPassword(LUsers[0], ARequest.Password);
    ResponseToken({ TFeature:multitenant }TenantName, { /TFeature:multitenant }LUsers[0]);
  finally
    LUsers.Free;
  end;
end;

{ TChangePasswordController }

procedure TChangePasswordController.ChangePassword;
var
  LRequest: TChangePasswordRequest;
begin
  LRequest := TChangePasswordRequest.Create;
  try
    ReadRequest<TChangePasswordRequest>(LRequest);
    ChangeUserPassword(LRequest);
  finally
    LRequest.Free;
  end;
end;

procedure TChangePasswordController.ChangeUserPassword(
  const ARequest: TChangePasswordRequest);
var
  LUsers: TTList<TUser>;
begin
  LUsers := HttpContext.CreateEntityList<TUser>();
  try
    SelectUsers(LUsers, FContext.Payload.Email);
    VerifyPassword(LUsers[0], ARequest.OldPassword);
    VerifyEnabled(LUsers[0]);
    SetPassword(LUsers[0], ARequest.NewPassword);
    HttpContext.Update<TUser>(LUsers[0]);
    ResponseToken({ TFeature:multitenant }FContext.Payload.Tenant, { /TFeature:multitenant }LUsers[0]);
  finally
    LUsers.Free;
  end;
end;

{ TRenewTokenController }

procedure TRenewTokenController.RenewToken;
var
  LUsers: TTList<TUser>;
begin
  LUsers := HttpContext.CreateEntityList<TUser>();
  try
    SelectUsers(LUsers, FContext.Payload.Email);
    VerifyEnabled(LUsers[0]);
    ResponseToken({ TFeature:multitenant }FContext.Payload.Tenant, { /TFeature:multitenant }LUsers[0]);
  finally
    LUsers.Free;
  end;
end;

end.
