CREATE TABLE [rt].[RoutingGroup] (
    [RoutingGroupId]   INT            IDENTITY (1, 1) NOT NULL,
    [RoutingGroupName] NVARCHAR (100) NULL,
    [DataSourceId]     TINYINT        CONSTRAINT [DF_RoutingGroup_DataSourceId] DEFAULT ((1)) NOT NULL,
    [TierLevelCurrent] TINYINT        CONSTRAINT [DF_RoutingGroup_CurrentTierLevel] DEFAULT ((1)) NOT NULL,
    [CreatedAt]        DATETIME2 (2)  CONSTRAINT [DF_RoutingGroup_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]        DATETIME2 (2)  CONSTRAINT [DF_RoutingGroup_UpdatedAt] DEFAULT (getutcdate()) NOT NULL,
    [Deleted]          BIT            CONSTRAINT [DF_RoutingGroup_Deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RoutingGroup] PRIMARY KEY CLUSTERED ([RoutingGroupId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[RoutingGroup_DataChanged] 
   ON  [rt].[RoutingGroup] 
   AFTER UPDATE
AS 
BEGIN
	UPDATE f
	SET [UpdatedAt] = SYSUTCDATETIME()
	FROM [rt].[RoutingGroup] f
		INNER JOIN inserted AS i ON f.RoutingGroupId = i.RoutingGroupId

	-- update dependencies
	DECLARE @RoutingTiers TABLE (RoutingTierId int)
	
	-- tiers with changes in primary
	INSERT INTO @RoutingTiers (RoutingTierId)
	SELECT DISTINCT rt.RoutingTierId
	FROM inserted i
		-- if TierLevelCurrent changed
		INNER JOIN deleted d ON 
			i.RoutingGroupId = d.RoutingGroupId AND 
			i.TierLevelCurrent <> d.TierLevelCurrent
		INNER JOIN rt.RoutingTier rt ON 
			rt.RoutingGroupId = i.RoutingGroupId AND 
			rt.TierLevel = i.TierLevelCurrent

	-- update dependencies
	-- Looping through table records where looping column has duplicate values
	DECLARE @LoopCounter INT , @MaxCounter INT
	SELECT @LoopCounter = MIN(RoutingTierId), @MaxCounter = MAX(RoutingTierId) 
	FROM @RoutingTiers
	
	WHILE (@LoopCounter IS NOT NULL AND  @LoopCounter <= @MaxCounter)
	BEGIN
		-- update dependencies
		EXEC rt.RoutingTier_UpdateDependencies @RoutingTierId = @LoopCounter
		PRINT dbo.Log_ROWCOUNT ('Update Dependencies of RoutingTierId=' + cast(@LoopCounter as varchar(10)))

		SELECT @LoopCounter = MIN(RoutingTierId)
		FROM @RoutingTiers WHERE RoutingTierId > @LoopCounter
	END
END
