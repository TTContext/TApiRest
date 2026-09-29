(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Config.JSon;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  System.JSon,
  Trysil.Consts,

  TApiRest.Consts;

type

{ TJSonConfig }

  TJSonConfig = class
  public
    class function Load(const AFileName: String): TJSonValue;
  end;

implementation

type

{ TJSonConfigEx }

  TJSonConfigEx = class
  strict private
    const ExtendsName: String = 'extends';
  strict private
    FChain: TStringList;
    FPathNames: TArray<String>;

    function IsPathName(const AName: String): Boolean;
    function AbsolutePath(
      const APath: String; const AFolder: String): String;
    procedure ResolvePaths(
      const AJSon: TJSonValue; const AFolder: String);
    procedure Merge(
      const ATarget: TJSonObject; const ASource: TJSonObject);
    function ParseFile(const AFileName: String): TJSonObject;
  public
    constructor Create;
    destructor Destroy; override;

    function Load(const AFileName: String): TJSonObject;
  end;

{ TJSonConfigEx }

constructor TJSonConfigEx.Create;
begin
  inherited Create;
  FChain := TStringList.Create;
  FPathNames := [ExtendsName, 'signingKey', 'publicKey'];
end;

destructor TJSonConfigEx.Destroy;
begin
  FChain.Free;
  inherited Destroy;
end;

function TJSonConfigEx.IsPathName(const AName: String): Boolean;
var
  LName: String;
begin
  result := False;
  for LName in FPathNames do
    if SameText(LName, AName) then
      result := True;
end;

function TJSonConfigEx.AbsolutePath(
  const APath: String; const AFolder: String): String;
begin
  result := APath;
  if not result.IsEmpty then
  begin
    if not TPath.IsPathRooted(result) then
      result := TPath.Combine(AFolder, result);

    result := TPath.GetFullPath(result);
  end;
end;

procedure TJSonConfigEx.ResolvePaths(
  const AJSon: TJSonValue; const AFolder: String);
var
  LObject: TJSonObject;
  LArray: TJSonArray;
  LNames: TArray<String>;
  LIndex: Integer;
  LName: String;
  LValue: TJSonValue;
  LPair: TJSonPair;
begin
  if AJSon is TJSonObject then
  begin
    LObject := TJSonObject(AJSon);
    SetLength(LNames, LObject.Count);
    for LIndex := 0 to LObject.Count - 1 do
      LNames[LIndex] := LObject.Pairs[LIndex].JsonString.Value;

    for LName in LNames do
    begin
      LValue := LObject.Values[LName];
      if IsPathName(LName) and (LValue is TJSonString) then
      begin
        LPair := LObject.RemovePair(LName);
        try
          LObject.AddPair(LName, TJSonString.Create(
            AbsolutePath(TJSonString(LValue).Value, AFolder)));
        finally
          LPair.Free;
        end;
      end
      else
        ResolvePaths(LValue, AFolder);
    end;
  end
  else if AJSon is TJSonArray then
  begin
    LArray := TJSonArray(AJSon);
    for LIndex := 0 to LArray.Count - 1 do
      ResolvePaths(LArray.Items[LIndex], AFolder);
  end;
end;

procedure TJSonConfigEx.Merge(
  const ATarget: TJSonObject; const ASource: TJSonObject);
var
  LIndex: Integer;
  LPair: TJSonPair;
  LName: String;
  LValue: TJSonValue;
begin
  for LIndex := 0 to ASource.Count - 1 do
  begin
    LPair := ASource.Pairs[LIndex];
    LName := LPair.JsonString.Value;
    LValue := ATarget.Values[LName];
    if not Assigned(LValue) then
      ATarget.AddPair(LName, LPair.JsonValue.Clone as TJSonValue)
    else if (LValue is TJSonObject) and (LPair.JsonValue is TJSonObject) then
      Merge(TJSonObject(LValue), TJSonObject(LPair.JsonValue));
  end;
end;

function TJSonConfigEx.ParseFile(const AFileName: String): TJSonObject;
var
  LJSon: TJSonValue;
begin
  if not TFile.Exists(AFileName) then
    raise EFileNotFoundException.CreateFmt(
      TTLanguage.Instance.Translate(SConfigNotFound), [AFileName]);

  LJSon := TJSonObject.ParseJSonValue(TFile.ReadAllText(AFileName));
  if not (LJSon is TJSonObject) then
  begin
    LJSon.Free;
    raise EJSonException.CreateFmt(
      TTLanguage.Instance.Translate(SConfigNotValid), [AFileName]);
  end;

  result := TJSonObject(LJSon);
end;

function TJSonConfigEx.Load(const AFileName: String): TJSonObject;
var
  LExtends: String;
  LBase: TJSonObject;
begin
  if FChain.IndexOf(AFileName) >= 0 then
    raise EJSonException.CreateFmt(
      TTLanguage.Instance.Translate(SConfigExtendsCycle), [AFileName]);

  FChain.Add(AFileName);
  result := ParseFile(AFileName);
  try
    ResolvePaths(result, TPath.GetDirectoryName(AFileName));

    LExtends := result.GetValue<String>(ExtendsName, String.Empty);
    if not LExtends.IsEmpty then
    begin
      LBase := Load(LExtends);
      try
        Merge(result, LBase);
      finally
        LBase.Free;
      end;
    end;
  except
    result.Free;
    raise;
  end;
end;

{ TJSonConfig }

class function TJSonConfig.Load(const AFileName: String): TJSonValue;
var
  LConfig: TJSonConfigEx;
begin
  LConfig := TJSonConfigEx.Create;
  try
    result := LConfig.Load(TPath.GetFullPath(AFileName));
  finally
    LConfig.Free;
  end;
end;

end.
