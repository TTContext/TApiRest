{ TFeature:auth }
(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Model.UserTypeArea;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes,
  Trysil.Lazy,

  TApiRest.Model.UserType,
  TApiRest.Model.Area;

type

{ TUserTypeArea }

  [TTable('UserTypesAreas')]
  [TSequence('UserTypesAreasID')]
  TUserTypeArea = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
    [TColumn('UserTypeID')]
    FUserType: TTLazy<TUserType>;

    [TRequired]
    [TColumn('AreaID')]
    FArea: TTLazy<TArea>;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;

    function GetUserType: TUserType;
    procedure SetUserType(const AValue: TUserType);
    function GetArea: TArea;
    procedure SetArea(const AValue: TArea);
  public
    property ID: TTPrimaryKey read FID;
    property UserType: TUserType read GetUserType write SetUserType;
    property Area: TArea read GetArea write SetArea;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

{ TUserTypeArea }

function TUserTypeArea.GetUserType: TUserType;
begin
  result := FUserType.Entity;
end;

procedure TUserTypeArea.SetUserType(const AValue: TUserType);
begin
  FUserType.Entity := AValue;
end;

function TUserTypeArea.GetArea: TArea;
begin
  result := FArea.Entity;
end;

procedure TUserTypeArea.SetArea(const AValue: TArea);
begin
  FArea.Entity := AValue;
end;

end.
