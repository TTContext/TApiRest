{ TFeature:auth }
(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Model.UserType;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes;

type

{ TUserType }

  [TTable('UserTypes')]
  [TSequence('UserTypesID')]
  [TRelation('Users', 'UserTypeID', False)]
  [TRelation('UserTypesAreas', 'UserTypeID', False)]
  TUserType = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
    [TMaxLength(100)]
    [TColumn('Description')]
    FDescription: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    const Administrator: Integer = 1;
    const Manager: Integer = 2;
    const Teacher: Integer = 3;
    const Student: Integer = 4;
  public
    property ID: TTPrimaryKey read FID;
    property Description: String read FDescription write FDescription;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

end.
