-- TFeature:log
CREATE SEQUENCE Log_ActionsID
  AS int
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE Log_Actions(
  ID int NOT NULL,
  TaskID nvarchar(50) NOT NULL,
  Date datetime NOT NULL,
  Action nvarchar(max) NOT NULL,
  VersionID int NOT NULL,
  CONSTRAINT PK_Log_Actions PRIMARY KEY CLUSTERED (ID ASC)
);

CREATE SEQUENCE Log_RequestsID
  AS int
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE Log_Requests(
  ID int NOT NULL,
  TaskID nvarchar(50) NOT NULL,
  Host nvarchar(255) NOT NULL,
  Date datetime NOT NULL,
  Uri nvarchar(255) NOT NULL,
  Params nvarchar(max) NULL,
  MethodType nvarchar(255) NOT NULL,
  Content nvarchar(max) NULL,
  Headers nvarchar(max) NULL,
  RemoteIP nvarchar(255) NOT NULL,
  ClientIP nvarchar(255) NOT NULL,
  VersionID int NOT NULL,
  CONSTRAINT PK_Log_Requests PRIMARY KEY CLUSTERED (ID ASC)
);

CREATE SEQUENCE Log_ResponsesID
  AS int
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE Log_Responses(
  ID int NOT NULL,
  TaskID nvarchar(50) NOT NULL,
  Date datetime NOT NULL,
  Username nvarchar(255) NULL DEFAULT '',
  UserAreas nvarchar(max) NULL,
  StatusCode int NOT NULL,
  ContentType nvarchar(255) NOT NULL,
  ContentEncoding nvarchar(255) NOT NULL,
  Content nvarchar(max) NULL,
  BinaryContent nvarchar(max) NULL,
  VersionID int NOT NULL,
  CONSTRAINT PK_Log_Responses PRIMARY KEY CLUSTERED (ID ASC)
);

