CREATE TABLE [rt].[RoutingGroupTier] (
    [RoutingGroupTierId] INT           IDENTITY (1, 1) NOT NULL,
    [RoutingGroupId]     INT           NOT NULL,
    [Level]              TINYINT       NOT NULL,
    [RoutingTierId]      INT           NOT NULL,
    [UpdatedAt]          DATETIME2 (2) CONSTRAINT [DF_RoutingGroupTier_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Deleted]            BIT           CONSTRAINT [DF_RoutingGroupTier_Deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RoutingGroupTier] PRIMARY KEY CLUSTERED ([RoutingGroupId] ASC, [Level] ASC),
    CONSTRAINT [UIX_RoutingCoverageTier_Key] UNIQUE NONCLUSTERED ([RoutingGroupTierId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[RoutingGroupTier_DataChanged] 
   ON  [rt].[RoutingGroupTier] 
   AFTER UPDATE
AS 
BEGIN
	UPDATE f
	SET [UpdatedAt] = SYSUTCDATETIME()
	FROM [rt].[RoutingGroupTier] f
		INNER JOIN inserted AS i ON f.RoutingGroupTierId = i.RoutingGroupTierId
END
