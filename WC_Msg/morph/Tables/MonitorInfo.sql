CREATE TABLE [morph].[MonitorInfo] (
    [Name]                 VARCHAR (50)   NOT NULL,
    [ExecutionMethod]      INT            NOT NULL,
    [MonitorClass]         VARCHAR (150)  NOT NULL,
    [Type]                 VARCHAR (50)   NOT NULL,
    [PropertiesJson]       NVARCHAR (500) NULL,
    [NotificationInfoJson] NVARCHAR (500) NULL,
    CONSTRAINT [PK_MonitorInfo] PRIMARY KEY CLUSTERED ([Name] ASC)
);

