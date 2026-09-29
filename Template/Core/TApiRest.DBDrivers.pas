(*

  Trysil API
  Copyright © David Lastrucci
  All rights reserved

*)
unit TApiRest.DBDrivers;

// Registers the FireDAC drivers via the initialization sections of the units
// below. Comment out the ones you don't use.

interface

uses
  System.SysUtils,
  System.Classes
  , Trysil.Data.FireDAC.FirebirdSQL   // "driver": "FB"
  , Trysil.Data.FireDAC.InterBase     // "driver": "IB"
  , Trysil.Data.FireDAC.MariaDB       // "driver": "MariaDB"
  , Trysil.Data.FireDAC.Oracle        // "driver": "Ora"
  , Trysil.Data.FireDAC.PostgreSQL    // "driver": "PG"
  , Trysil.Data.FireDAC.SQLite        // "driver": "SQLite"
  , Trysil.Data.FireDAC.SqlServer     // "driver": "MSSQL"
  ;

implementation

end.
