CREATE TABLE [rt].[RoutingCoverageConditionStatus] (
    [SubAccountUid]  INT           NOT NULL,
    [TierEntryId]    INT           NOT NULL,
    [Country]        CHAR (2)      NULL,
    [OperatorId]     INT           NULL,
    [FlagBindUptime] BIT           CONSTRAINT [DF_RoutingPlanCoverageStatus_BindUptime] DEFAULT ((1)) NOT NULL,
    [FlagBindQueue]  BIT           CONSTRAINT [DF_RoutingPlanCoverageStatus_BindQueue] DEFAULT ((1)) NOT NULL,
    [FlagDlr]        BIT           CONSTRAINT [DF_RoutingPlanCoverageStatus_Dlr] DEFAULT ((1)) NOT NULL,
    [FlagLatency]    BIT           CONSTRAINT [DF_RoutingPlanCoverageStatus_Latency] DEFAULT ((1)) NOT NULL,
    [FlagMargin]     BIT           CONSTRAINT [DF_RoutingPlanCoverageStatus_Margin] DEFAULT ((1)) NOT NULL,
    [DlrRate]        TINYINT       NULL,
    [Latency]        INT           NULL,
    [MarginRate]     TINYINT       NULL,
    [LastUpdatedAt]  DATETIME2 (0) CONSTRAINT [DF_RoutingPlanCoverageStatus_LastUpdatedAt] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_RoutingPlanCoverageStatus] PRIMARY KEY CLUSTERED ([SubAccountUid] ASC, [TierEntryId] ASC),
    CONSTRAINT [FK_RoutingPlanCoverageStatus_RoutingPlanCoverage] FOREIGN KEY ([SubAccountUid]) REFERENCES [rt].[RoutingPlanCoverage] ([RoutingPlanCoverageId]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[RoutingCoverageConditionStatus_DataChanged] 
   ON  rt.RoutingCoverageConditionStatus 
   AFTER UPDATE
AS 
BEGIN
	UPDATE f
	SET [LastUpdatedAt] = SYSUTCDATETIME()
	FROM [rt].[RoutingCoverageConditionStatus] f
		INNER JOIN inserted AS i ON f.SubAccountUid = i.SubAccountUid AND f.TierEntryId = i.TierEntryId
END
