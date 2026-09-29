(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.Consts;

interface

resourcestring
  SConfigNotFound = 'JSON configuration file "%s" not found.';
  SConfigNotValid = 'JSON configuration file "%s" is not valid.';
  SConfigExtendsCycle = 'JSON configuration error: circular "extends" reference in "%s".';
  SConfigSecretsNotFound = 'JSON configuration error: secrets not found.';
  SConfigJWTKeyNotValid = 'JSON configuration error: JWT key "%s" is incomplete.';
  SConfigJWTKeyNotFound = 'JSON configuration error: the current JWT key "%s" is not declared in the "keys" section.';
  SConfigJWTKeyDuplicated = 'JSON configuration error: JWT key "%s" is declared more than once.';
  SConfigDriverNotFound = 'JSON configuration error: driver not found in "%s" section.';
  SInvalidCredentials = 'Invalid credentials.';
  SInvalidToken = 'The access token is not valid.';
  SExpiredToken = 'The access token has expired.';
  SEntityNotFound = 'Unable to find entity %0:s with ID %1:d.';

implementation

end.
