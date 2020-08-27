CREATE TABLE [rt].[Route] (
    [RouteId]   VARCHAR (50)   NOT NULL,
    [RouteName] VARCHAR (100)  NULL,
    [JsonData]  NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Routes] PRIMARY KEY CLUSTERED ([RouteId] ASC)
);

