CREATE TABLE [rt].[RoutingCustom] (
    [Id]               INT             IDENTITY (1, 1) NOT NULL,
    [SubAccountUid]    INT             NOT NULL,
    [Country]          CHAR (2)        NOT NULL,
    [OperatorId]       INT             NULL,
    [TrafficCategory]  VARCHAR (3)     CONSTRAINT [DF_RoutingCustom_TrafficCategory] DEFAULT ('DEF') NOT NULL,
    [RoutingGroupId]   INT             NULL,
    [PriceCurrency]    CHAR (3)        NOT NULL,
    [Price]            DECIMAL (12, 6) NOT NULL,
    [PricingFormulaId] INT             NULL,
    [MarginRate]       DECIMAL (8, 4)  NULL,
    [CompanyCurrency]  CHAR (3)        NOT NULL,
    [CompanyPrice]     DECIMAL (12, 6) NOT NULL,
    [CostCurrency]     CHAR (3)        NULL,
    [CostCalculated]   DECIMAL (12, 6) NULL,
    [CreatedBy]        SMALLINT        NULL,
    [CreatedAt]        DATETIME2 (2)   CONSTRAINT [DF_RoutingCustom_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedBy]        SMALLINT        NULL,
    [UpdatedAt]        DATETIME2 (2)   CONSTRAINT [DF_RoutingCustom_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Deleted]          BIT             CONSTRAINT [DF_RoutingCustom_Deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RoutingCustom] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_RoutingCustom_RoutingGroup] FOREIGN KEY ([RoutingGroupId]) REFERENCES [rt].[RoutingGroup] ([RoutingGroupId]),
    CONSTRAINT [UIX_RoutingCustom_Key] UNIQUE NONCLUSTERED ([SubAccountUid] ASC, [Country] ASC, [OperatorId] ASC, [TrafficCategory] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[RoutingCustom_DataChanged] 
   ON  [rt].[RoutingCustom] 
   AFTER UPDATE
AS 
BEGIN
	UPDATE f
	SET [UpdatedAt] = SYSUTCDATETIME()
	FROM [rt].[RoutingCustom] f
		INNER JOIN inserted AS i ON f.Id = i.Id
END
