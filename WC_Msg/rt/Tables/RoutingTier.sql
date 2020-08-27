CREATE TABLE [rt].[RoutingTier] (
    [RoutingTierId]   INT             IDENTITY (1, 1) NOT NULL,
    [RoutingTierName] NVARCHAR (100)  NULL,
    [TierLevel]       TINYINT         NOT NULL,
    [CostCalculated]  DECIMAL (12, 6) NULL,
    [CostCurrency]    CHAR (3)        CONSTRAINT [DF_RoutingTier_CostCurrency] DEFAULT ('EUR') NOT NULL,
    [ConnSummary]     VARCHAR (300)   NULL,
    [RoutingGroupId]  INT             NOT NULL,
    [UpdatedAt]       DATETIME2 (2)   CONSTRAINT [DF_RoutingTier_UpdatedAt] DEFAULT (getutcdate()) NOT NULL,
    [Deleted]         BIT             CONSTRAINT [DF_RoutingTier_Deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RoutingTier] PRIMARY KEY CLUSTERED ([RoutingTierId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_RoutingTier_RoutingGroupId]
    ON [rt].[RoutingTier]([RoutingGroupId] ASC, [Deleted] ASC)
    INCLUDE([RoutingTierId], [RoutingTierName], [TierLevel]);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER rt.RoutingTier_DataChanged
   ON  [rt].[RoutingTier] 
   AFTER INSERT, UPDATE
AS 
BEGIN

	-- prevent looping
	IF TRIGGER_NESTLEVEL() > 2
	BEGIN
		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'RoutingTier dependency actions stopped. Due to possible looping (high NESTLEVEL)'
		RETURN
	END

	UPDATE f
	SET UpdatedAt = SYSUTCDATETIME()
	FROM rt.RoutingTier f
		INNER JOIN inserted AS i ON f.RoutingTierId = i.RoutingTierId

	-- update dependencies
	-- Looping through table records where looping column has duplicate values
	--DECLARE @RoutingTierId int
	DECLARE @LoopCounter INT, @MaxCounter INT
	SELECT @LoopCounter = MIN(RoutingTierId), @MaxCounter = MAX(RoutingTierId) FROM inserted
	WHILE (@LoopCounter IS NOT NULL AND @LoopCounter <= @MaxCounter)
	BEGIN
		-- update dependencies
		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'RoutingTier_DataChanged: Update Dependencies of RoutingTierId=' + cast(@LoopCounter as varchar(10))
		EXEC rt.RoutingTier_UpdateDependencies @RoutingTierId = @LoopCounter
		
		SELECT @LoopCounter = MIN(RoutingTierId)
		FROM inserted
		WHERE RoutingTierId > @LoopCounter
	END
END
