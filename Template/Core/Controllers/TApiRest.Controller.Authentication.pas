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
  System.JSon,
  Data.DB,
  Trysil.Consts,
  Trysil.Types,
  Trysil.Generics.Collections,
  Trysil.Filter,
  Trysil.Http.Consts,
  Trysil.Http.Types,
  Trysil.Http.Attributes,
  Trysil.Http.Exceptions,
  Trysil.Http.Classes,
  Trysil.Http.JWT,

  TApiRest.Consts,
  TApiRest.Context,
  TApiRest.Controller,
  TApiRest.Authentication.JWT,
  TApiRest.Model.User,
  TApiRest.Model.UserTypeArea,
  TApiRest.Password;

type

{ TAuthenticationController }

  [TUri('/auth')]
  TAuthenticationController = class(TController)
  strict protected
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
  public
    [TPost('/login')]
    procedure Login;
  end;

{ TChangePasswordController }

  TChangePasswordController = class(TAuthenticationController)
  public
    [TPost('/changepassword')]
    procedure ChangePassword;
  end;

{ TRenewTokenController }

  TRenewTokenController = class(TAuthenticationController)
  public
    [TPost('/renewtoken')]
    procedure RenewToken;
  end;

implementation

{ TAuthenticationController }

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
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('token', CreateToken({ TFeature:multitenant }ATenant, { /TFeature:multitenant }AUser));
    FResponse.Content := LJSon.ToJSon();
  finally
    LJSon.Free;
  end;
end;

{ TLoginController }

procedure TLoginController.Login;
var
  LUsers: TTList<TUser>;
  LPassword: String;
begin
  LUsers := HttpContext.CreateEntityList<TUser>();
  try
    SelectUsers(
      LUsers,
      FRequest.JSonContent.GetValue<String>('email', String.Empty));
    LPassword := FRequest.JSonContent.GetValue<String>(
      'password', String.Empty);
    VerifyPassword(LUsers[0], LPassword);
    VerifyEnabled(LUsers[0]);
    HashPlainPassword(LUsers[0], LPassword);
    ResponseToken({ TFeature:multitenant }TenantName, { /TFeature:multitenant }LUsers[0]);
  finally
    LUsers.Free;
  end;
end;

{ TChangePasswordController }

procedure TChangePasswordController.ChangePassword;
var
  LUsers: TTList<TUser>;
begin
  LUsers := HttpContext.CreateEntityList<TUser>();
  try
    SelectUsers(LUsers, FContext.Payload.Email);
    VerifyPassword(
      LUsers[0],
      FRequest.JSonContent.GetValue<String>('oldPassword', ''));
    VerifyEnabled(LUsers[0]);
    SetPassword(
      LUsers[0],
      FRequest.JSonContent.GetValue<String>('newPassword', ''));
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
