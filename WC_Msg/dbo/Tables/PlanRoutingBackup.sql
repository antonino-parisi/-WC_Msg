CREATE TABLE [dbo].[PlanRoutingBackup] (
    [AccountId]    NVARCHAR (50)  NOT NULL,
    [SubAccountId] NVARCHAR (50)  NOT NULL,
    [Prefix]       NVARCHAR (50)  NOT NULL,
    [RouteId]      NVARCHAR (50)  NOT NULL,
    [Price]        FLOAT (53)     NOT NULL,
    [Priority]     INT            NOT NULL,
    [Active]       BIT            NOT NULL,
    [Operator]     NVARCHAR (200) CONSTRAINT [DF_PlanRoutingBackup_Operator] DEFAULT (N'none') NOT NULL,
    [TariffRoute]  BIT            CONSTRAINT [DF_PlanRoutingBackup_TariffRoute] DEFAULT ((0)) NOT NULL,
    [Cost]         FLOAT (53)     NULL,
    [RoutingMode]  INT            NULL,
    CONSTRAINT [PK_PlanRoutingBackup] PRIMARY KEY CLUSTERED ([AccountId] ASC, [SubAccountId] ASC, [Prefix] ASC, [Operator] ASC)
);

