-- TFeature:auth
CREATE SEQUENCE AreasID
  AS int
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE Areas(
  ID int NOT NULL,
  Description nvarchar(100) NOT NULL,
  VersionID int NOT NULL,
  CONSTRAINT PK_Areas PRIMARY KEY CLUSTERED (ID ASC)
);

CREATE SEQUENCE UsersID
  AS int
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE Users(
  ID int NOT NULL,
  Firstname nvarchar(100) NOT NULL,
  Lastname nvarchar(100) NOT NULL,
  UserTypeID int NOT NULL,
  Email nvarchar(255) NOT NULL,
  Salt nvarchar(32) NOT NULL,
  Password nvarchar(64) NOT NULL,
  DisabledAt datetime NULL,
  VersionID int NOT NULL,
  CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (ID ASC)
);

CREATE SEQUENCE UserTypesID
  AS int
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE UserTypes(
  ID int NOT NULL,
  Description nvarchar(100) NOT NULL,
  VersionID int NOT NULL,
  CONSTRAINT PK_UserTypes PRIMARY KEY CLUSTERED (ID ASC)
);

CREATE SEQUENCE UserTypesAreasID
  AS int
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE UserTypesAreas(
  ID int NOT NULL,
  UserTypeID int NOT NULL,
  AreaID int NOT NULL,
  VersionID int NOT NULL,
  CONSTRAINT PK_UserTypesAreas PRIMARY KEY CLUSTERED (ID ASC)
);

CREATE INDEX IDX_UserTypesAreas_UserTypeID ON UserTypesAreas(UserTypeID);