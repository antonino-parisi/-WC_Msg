CREATE TABLE [rt].[CustomerGroup] (
    [CustomerGroupId]       INT             IDENTITY (1, 1) NOT NULL,
    [CustomerGroupName]     NVARCHAR (100)  NOT NULL,
    [Description]           NVARCHAR (1000) NULL,
    [Deleted]               BIT             CONSTRAINT [DF_CustomerGroup_Deleted] DEFAULT ((0)) NOT NULL,
    [UpdatedAt]             DATETIME2 (2)   CONSTRAINT [DF_CustomerGroup_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [OwnerId]               SMALLINT        NOT NULL,
    [RoutingPlanId_Default] INT             NULL,
    [PricingPlanId_Default] INT             NULL,
    CONSTRAINT [PK_CustomerGroup] PRIMARY KEY CLUSTERED ([CustomerGroupId] ASC)
);

