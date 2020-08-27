CREATE TABLE [dbo].[PlanRoutingHistory] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [ChangedBy]    [sysname]      NOT NULL,
    [Action]       VARCHAR (50)   NOT NULL,
    [ChangedDate]  DATETIME       NOT NULL,
    [AccountId]    NVARCHAR (50)  NOT NULL,
    [SubAccountId] NVARCHAR (50)  NOT NULL,
    [Prefix]       NVARCHAR (50)  NOT NULL,
    [RouteId]      NVARCHAR (50)  NOT NULL,
    [Price]        FLOAT (53)     NOT NULL,
    [Priority]     INT            NOT NULL,
    [Active]       BIT            NOT NULL,
    [Operator]     NVARCHAR (200) NOT NULL,
    [TariffRoute]  BIT            NOT NULL,
    [Cost]         FLOAT (53)     NULL,
    [RoutingMode]  INT            NULL,
    CONSTRAINT [PK_PlanRoutingHistory] PRIMARY KEY CLUSTERED ([Id] ASC)
);

