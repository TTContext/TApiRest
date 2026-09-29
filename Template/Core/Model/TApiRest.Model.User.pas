{ TFeature:auth }
(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Model.User;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes,
  Trysil.JSon.Attributes,
  Trysil.Lazy,

  TApiRest.Model.UserType;

type

{ TUser }

  [TTable('Users')]
  [TSequence('UsersID')]
  TUser = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
    [TMaxLength(100)]
    [TColumn('Firstname')]
    FFirstname: String;

    [TRequired]
    [TMaxLength(100)]
    [TColumn('Lastname')]
    FLastname: String;

    [TRequired]
    [TColumn('UserTypeID')]
    FUserType: TTLazy<TUserType>;

    [TRequired]
    [TMaxLength(255)]
    [TColumn('Email')]
    FEmail: String;

    [TRequired]
    [TMaxLength(32)]
    [TJSonIgnore]
    [TColumn('Salt')]
    FSalt: String;

    [TRequired]
    [TMaxLength(64)]
    [TJSonIgnore]
    [TColumn('Password')]
    FPassword: String;

    [TColumn('DisabledAt')]
    FDisabledAt: TTNullable<TDateTime>;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;

    function GetUserType: TUserType;
    procedure SetUserType(const AValue: TUserType);
  public
    property ID: TTPrimaryKey read FID;
    property Firstname: String read FFirstname write FFirstname;
    property Lastname: String read FLastname write FLastname;
    property UserType: TUserType read GetUserType write SetUserType;
    property Email: String read FEmail write FEmail;
    property Salt: String read FSalt write FSalt;
    property Password: String read FPassword write FPassword;
    property DisabledAt: TTNullable<TDateTime> read FDisabledAt write FDisabledAt;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

{ TUser }

function TUser.GetUserType: TUserType;
begin
  result := FUserType.Entity;
end;

procedure TUser.SetUserType(const AValue: TUserType);
begin
  FUserType.Entity := AValue;
end;

end.
