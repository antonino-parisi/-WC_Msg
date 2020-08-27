CREATE TABLE [rt].[SupplierCostCoverage] (
    [CostCoverageId]    INT             IDENTITY (1, 1) NOT NULL,
    [RouteId]           VARCHAR (50)    NULL,
    [RouteUid]          INT             NOT NULL,
    [Country]           CHAR (2)        NOT NULL,
    [OperatorId]        INT             NULL,
    [SmsTypeId]         TINYINT         CONSTRAINT [DF_SupplierCostCoverage_SmsTypeId] DEFAULT ((1)) NOT NULL,
    [CostLocal]         DECIMAL (12, 6) NOT NULL,
    [CostLocalCurrency] CHAR (3)        NOT NULL,
    [CostEUR]           DECIMAL (12, 6) NOT NULL,
    [EffectiveFrom]     DATETIME2 (2)   NOT NULL,
    [CreatedAt]         DATETIME2 (2)   CONSTRAINT [DF_rtSupplierCostCoverage_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    [UpdatedAt]         DATETIME2 (2)   CONSTRAINT [DF_rtSupplierCostCoverage_UpdatedAt] DEFAULT (getutcdate()) NOT NULL,
    [Deleted]           BIT             CONSTRAINT [DF_rtSupplierCostCoverage_Deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_rtSupplierCostCoverage] PRIMARY KEY CLUSTERED ([CostCoverageId] ASC),
    CONSTRAINT [CK_SupplierCostCoverage_SmsTypeId] CHECK ([SmsTypeId]=(1) OR [SmsTypeId]=(0)),
    CONSTRAINT [UIX_rtSupplierCostCoverage] UNIQUE NONCLUSTERED ([RouteUid] ASC, [Country] ASC, [OperatorId] ASC, [SmsTypeId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[SupplierCostCoverage_DataChanged] 
   ON  rt.SupplierCostCoverage 
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON

	IF NOT UPDATE(UpdatedAt)
		UPDATE f
		SET UpdatedAt = SYSUTCDATETIME()
		FROM rt.SupplierCostCoverage f
			INNER JOIN inserted AS i ON f.CostCoverageId = i.CostCoverageId

	---- update dependancies
	--DECLARE @ChangedCostCoverage TABLE (
	--	CostCoverageId int NOT NULL,
	--	ConnUid int NOT NULL,
	--	Country char(2) NOT NULL,
	--	OperatorId int NULL,
	--	CostEUR decimal(12,6) NOT NULL
	--)

	-- update dependancies
	DECLARE @AffectedTiers TABLE (
		RoutingTierId int PRIMARY KEY
	)

	-- debug
	--INSERT INTO @ChangedCostCoverage (CostCoverageId, ConnUid, Country, OperatorId, CostEUR)
	--SELECT TOP 50 i.CostCoverageId, i.RouteUid, i.Country, i.OperatorId, i.CostEUR
	--FROM rt.SupplierCostCoverage i

	--INSERT INTO @ChangedCostCoverage (CostCoverageId, ConnUid, Country, OperatorId, CostEUR)
	--SELECT DISTINCT i.CostCoverageId, i.RouteUid, i.Country, i.OperatorId, i.CostEUR
	--FROM inserted AS i
	--UNION
	--SELECT DISTINCT d.CostCoverageId, d.RouteUid, d.Country, d.OperatorId, d.CostEUR
	--FROM deleted AS d
	INSERT INTO @AffectedTiers (RoutingTierId)
	SELECT DISTINCT rpc.RoutingTierId
	FROM rt.vwRoutingPlanCoverageAllConn rpc
		INNER JOIN (
			-- changed rows
			SELECT DISTINCT i.RouteUid, i.Country, i.OperatorId
			FROM inserted AS i
			UNION
			SELECT DISTINCT d.RouteUid, d.Country, d.OperatorId
			FROM deleted AS d
		) scc 
		ON scc.RouteUid = rpc.ConnUid AND 
			scc.Country = rpc.Country AND
			ISNULL(scc.OperatorId, 0) = ISNULL(rpc.OperatorId, 0)
	

	-- update dependencies
	-- Looping through table records where looping column has duplicate values
	DECLARE @LoopCounter INT , @MaxCounter INT
	
	-- Get affected tiers
	SELECT @LoopCounter = MIN(RoutingTierId), @MaxCounter = MAX(RoutingTierId) 
	FROM @AffectedTiers

	WHILE (@LoopCounter IS NOT NULL AND  @LoopCounter <= @MaxCounter)
	BEGIN
		-- update dependencies
		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'SupplierCostCoverage_DataChanged: Update Dependencies of RoutingTierId=' + cast(@LoopCounter as varchar(10))

		EXEC rt.RoutingTier_UpdateDependencies @RoutingTierId = @LoopCounter
		--PRINT dbo.Log_ROWCOUNT ('Update Dependencies of RoutingTierId=' + cast(@LoopCounter as varchar(10)))

		SELECT @LoopCounter = MIN(RoutingTierId)
		FROM @AffectedTiers 
		WHERE RoutingTierId > @LoopCounter
	END
		
	--UPDATE rt SET CostCalculated = calc.CostCalculated
	--FROM rt.RoutingTier rt 
	--	INNER JOIN (
	--		SELECT rt.RoutingTierId, 
	--			--rpc.Country, rpc.OperatorId,
	--			SUM(rtc.Weight * cost.CostEUR) / SUM(rtc.Weight) AS CostCalculated
	--		FROM 
	--			rt.RoutingPlanCoverage rpc
	--			INNER JOIN rt.RoutingGroup rg ON rg.RoutingGroupId = rpc.RoutingGroupId AND rg.Deleted = 0
	--			INNER JOIN rt.RoutingTier rt ON rt.RoutingGroupId = rpc.RoutingGroupId AND rt.Deleted = 0
	--			INNER JOIN rt.RoutingTierConn rtc ON rt.RoutingTierId = rtc.RoutingTierId AND rtc.Deleted = 0
	--			INNER JOIN (
	--				-- Get affected tiers
	--				SELECT rpc.RoutingTierId
	--				FROM rt.vwRoutingPlanCoverageAllConn rpc
	--					INNER JOIN @ChangedCostCoverage scc 
	--					ON scc.ConnUid = rpc.ConnUid AND 
	--						scc.Country = rpc.Country AND
	--						ISNULL(scc.OperatorId, 0) = ISNULL(rpc.OperatorId, 0)
	--			) cng 
	--				ON cng.RoutingTierId = rt.RoutingTierId
	--			-- cost of suppliers
	--			INNER JOIN rt.vwSupplierCostCoverage_Active cost 
	--				ON rtc.ConnUid = cost.ConnUid AND 
	--					cost.Country = rpc.Country AND 
	--					ISNULL(cost.OperatorId, 0) = ISNULL(rpc.OperatorId, 0)
	--		--WHERE rpc.RTC_Deleted = 0 AND rpc.RT_Deleted = 0 AND rpc.RGT_Deleted = 0 AND rpc.RG_Deleted = 0
	--		GROUP BY rpc.RoutingPlanCoverageId, rt.RoutingTierId
	--			--rpc.Country, rpc.OperatorId
	--	) calc ON rt.RoutingTierId = calc.RoutingTierId

	--PRINT dbo.Log_ROWCOUNT ('RoutingTier - CostCalculated updated for affected cost change')

END

GO
CREATE TRIGGER [rt].[SupplierCostCoverage_LogHistory] ON rt.SupplierCostCoverage
FOR INSERT, UPDATE, DELETE
AS

	SET NOCOUNT ON
	IF EXISTS (SELECT 1 FROM inserted)
	BEGIN
		IF EXISTS (SELECT 1 FROM deleted)
		BEGIN

			-- UPDATE operation
			INSERT INTO rt.[SupplierCostCoverageHistory] (
				[ChangedBy]
				,[ChangedAt]
				,[Action]
				,CostCoverageId
				,[RouteUid]
				,[Country]
				,[OperatorId]
				,[CostLocal]
				,[CostLocalCurrency]
				,[CostEUR]
				,[EffectiveFrom]
				,[CreatedAt]
				,[UpdatedAt]
				,[SmsTypeId]
				,Deleted)
			SELECT SUSER_SNAME()
				,SYSUTCDATETIME()
				,'update-deleted'
				,CostCoverageId
				,[RouteUid]
				,[Country]
				,[OperatorId]
				,[CostLocal]
				,[CostLocalCurrency]
				,[CostEUR]
				,[EffectiveFrom]
				,[CreatedAt]
				,[UpdatedAt]
				,[SmsTypeId]
				,Deleted
			FROM deleted
		END
		ELSE
		BEGIN
			-- INSERT operation
			INSERT INTO rt.[SupplierCostCoverageHistory] (
				[ChangedBy]
				,[ChangedAt]
				,[Action]
				,CostCoverageId
				,[RouteUid]
				,[Country]
				,[OperatorId]
				,[CostLocal]
				,[CostLocalCurrency]
				,[CostEUR]
				,[EffectiveFrom]
				,[CreatedAt]
				,[UpdatedAt]
				,[SmsTypeId]
				,Deleted)
			SELECT SUSER_SNAME()
				,SYSUTCDATETIME()
				,'insert'
				,CostCoverageId
				,[RouteUid]
				,[Country]
				,[OperatorId]
				,[CostLocal]
				,[CostLocalCurrency]
				,[CostEUR]
				,[EffectiveFrom]
				,[CreatedAt]
				,[UpdatedAt]
				,[SmsTypeId]
				,Deleted
			FROM inserted
		END
	END
	ELSE
	BEGIN
		-- DELETE operation
		INSERT INTO rt.[SupplierCostCoverageHistory] (
				[ChangedBy]
				,[ChangedAt]
				,[Action]
				,CostCoverageId
				,[RouteUid]
				,[Country]
				,[OperatorId]
				,[CostLocal]
				,[CostLocalCurrency]
				,[CostEUR]
				,[EffectiveFrom]
				,[CreatedAt]
				,[UpdatedAt]
				,[SmsTypeId]
				,Deleted)
			SELECT SUSER_SNAME(), SYSUTCDATETIME(), 'delete'
				,CostCoverageId
				,[RouteUid]
				,[Country]
				,[OperatorId]
				,[CostLocal]
				,[CostLocalCurrency]
				,[CostEUR]
				,[EffectiveFrom]
				,[CreatedAt]
				,[UpdatedAt]
				,[SmsTypeId]
				,Deleted
			FROM deleted
	END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 - MO, 1 - MT', @level0type = N'SCHEMA', @level0name = N'rt', @level1type = N'TABLE', @level1name = N'SupplierCostCoverage', @level2type = N'COLUMN', @level2name = N'SmsTypeId';

