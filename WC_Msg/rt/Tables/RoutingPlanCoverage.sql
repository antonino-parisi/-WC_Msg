CREATE TABLE [rt].[RoutingPlanCoverage] (
    [RoutingPlanCoverageId] INT             IDENTITY (1, 1) NOT NULL,
    [RoutingPlanId]         INT             NOT NULL,
    [Country]               CHAR (2)        NOT NULL,
    [OperatorId]            INT             NULL,
    [TrafficCategory]       VARCHAR (3)     CONSTRAINT [DF_RoutingPlanCoverage_TrafficCategory] DEFAULT ('DEF') NOT NULL,
    [RoutingGroupId]        INT             NOT NULL,
    [DataSourceId]          TINYINT         CONSTRAINT [DF_RoutingPlanCoverage_NewDataSource] DEFAULT ((1)) NOT NULL,
    [CostCurrency]          CHAR (3)        NULL,
    [CostCalculated]        DECIMAL (12, 6) NULL,
    [CreatedBy]             SMALLINT        NULL,
    [CreatedAt]             DATETIME2 (2)   CONSTRAINT [DF_RoutingPlanCoverage_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedBy]             SMALLINT        NULL,
    [UpdatedAt]             DATETIME2 (2)   CONSTRAINT [DF_RoutingPlanCoverage_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Deleted]               BIT             CONSTRAINT [DF_RoutingPlanCoverage_Deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RoutingPlanCoverage] PRIMARY KEY CLUSTERED ([RoutingPlanCoverageId] ASC),
    CONSTRAINT [FK_RoutingPlanCoverage_RoutingPlan] FOREIGN KEY ([RoutingPlanId]) REFERENCES [rt].[RoutingPlan] ([RoutingPlanId]),
    CONSTRAINT [UIX_RoutingPlanCoverage_Key] UNIQUE NONCLUSTERED ([RoutingPlanId] ASC, [Country] ASC, [OperatorId] ASC, [TrafficCategory] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[RoutingPlanCoverage_DataChanged] 
   ON  [rt].[RoutingPlanCoverage] 
   AFTER UPDATE
AS 
BEGIN
	UPDATE f
	SET [UpdatedAt] = SYSUTCDATETIME()
	FROM [rt].[RoutingPlanCoverage] f
		INNER JOIN inserted AS i ON f.RoutingPlanCoverageId = i.RoutingPlanCoverageId
END
