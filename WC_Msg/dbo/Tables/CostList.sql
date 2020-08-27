CREATE TABLE [dbo].[CostList] (
    [Operator] NVARCHAR (50)   NOT NULL,
    [RouteId]  NVARCHAR (50)   NOT NULL,
    [Cost]     DECIMAL (18, 5) NOT NULL,
    CONSTRAINT [PK_CostList] PRIMARY KEY CLUSTERED ([Operator] ASC, [RouteId] ASC)
);

