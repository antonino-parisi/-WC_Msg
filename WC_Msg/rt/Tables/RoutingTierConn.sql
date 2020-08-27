CREATE TABLE [rt].[RoutingTierConn] (
    [TierEntryId]      INT           IDENTITY (1, 1) NOT NULL,
    [RoutingTierId]    INT           NOT NULL,
    [ConnId]           VARCHAR (50)  NULL,
    [ConnUid]          INT           NOT NULL,
    [Weight]           TINYINT       NOT NULL,
    [Active]           BIT           NOT NULL,
    [ActivateManually] BIT           CONSTRAINT [DF_RoutingTierConn_ActivateManually] DEFAULT ((0)) NOT NULL,
    [UpdatedAt]        DATETIME2 (2) CONSTRAINT [DF_RoutingTierConn_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Deleted]          BIT           CONSTRAINT [DF_RoutingTierConn_Deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RoutingTierConn] PRIMARY KEY CLUSTERED ([TierEntryId] ASC),
    CONSTRAINT [CK_RoutingTierConn_Weight] CHECK ([Weight]>=(1) AND [Weight]<=(100)),
    CONSTRAINT [FK_RoutingTierConn_RoutingTier] FOREIGN KEY ([RoutingTierId]) REFERENCES [rt].[RoutingTier] ([RoutingTierId]),
    CONSTRAINT [UIX_RoutingTierConn_Key] UNIQUE NONCLUSTERED ([RoutingTierId] ASC, [ConnUid] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[RoutingTierConn_DataChanged] 
   ON  [rt].[RoutingTierConn] 
   AFTER INSERT, UPDATE
AS 
BEGIN
	SET NOCOUNT ON

	UPDATE f
	SET [UpdatedAt] = SYSUTCDATETIME()
	FROM [rt].[RoutingTierConn] f
		INNER JOIN inserted AS i ON f.TierEntryId = i.TierEntryId

	-- update dependencies
	-- Looping through table records where looping column has duplicate values
	DECLARE @LoopCounter INT , @MaxCounter INT
	SELECT @LoopCounter = MIN(RoutingTierId), @MaxCounter = MAX(RoutingTierId) 
	FROM inserted
	
	WHILE (@LoopCounter IS NOT NULL AND  @LoopCounter <= @MaxCounter)
	BEGIN
		-- update dependencies
		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'RoutingTierConn_DataChanged: Update Dependencies of RoutingTierId=' + cast(@LoopCounter as varchar(10))

		EXEC rt.RoutingTier_UpdateDependencies @RoutingTierId = @LoopCounter
		--PRINT dbo.Log_ROWCOUNT ('Update Dependencies of RoutingTierId=' + cast(@LoopCounter as varchar(10)))

		SELECT @LoopCounter = MIN(RoutingTierId)
		FROM inserted WHERE RoutingTierId > @LoopCounter
	END

END
