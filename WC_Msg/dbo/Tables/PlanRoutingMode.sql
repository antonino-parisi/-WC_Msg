CREATE TABLE [dbo].[PlanRoutingMode] (
    [RoutingMode] INT            NOT NULL,
    [Description] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_PlanRoutingType] PRIMARY KEY CLUSTERED ([RoutingMode] ASC)
);

