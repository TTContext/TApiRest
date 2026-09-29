{ TFeature:auth }
(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Password;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Hash,

  TApiRest.Config;

type

{ TPassword }

  TPassword = class
  strict private
    const EncodeFormat: String = '%0:s:%1:s[%2:s]';
  public
    class function NewSalt: String;
    class function Encode(
      const APassword: String; const ASalt: String): String;
    class function Verify(
      const APassword: String;
      const ASalt: String;
      const AStored: String): Boolean;
  end;

implementation

{ TPassword }

class function TPassword.NewSalt: String;
begin
  result := TGUID.NewGuid.ToString
    .Replace('{', String.Empty)
    .Replace('}', String.Empty)
    .Replace('-', String.Empty);
end;

class function TPassword.Encode(
  const APassword: String; const ASalt: String): String;
begin
  result := THashSHA2.GetHashString(Format(EncodeFormat, [
    ASalt, APassword, TConfig.Instance.Secrets.Password]));
end;

class function TPassword.Verify(
  const APassword: String;
  const ASalt: String;
  const AStored: String): Boolean;
begin
  if ASalt.IsEmpty then
    result := APassword.Equals(AStored)
  else
    result := Encode(APassword, ASalt).Equals(AStored);
end;

end.
