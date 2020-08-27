CREATE TABLE [costprov].[RouteLookup] (
    [ParserId]     VARCHAR (50) NOT NULL,
    [RouteKeyword] VARCHAR (50) NOT NULL,
    [RouteId]      VARCHAR (50) NULL,
    CONSTRAINT [PK_RouteLookup] PRIMARY KEY CLUSTERED ([ParserId] ASC, [RouteKeyword] ASC)
);

