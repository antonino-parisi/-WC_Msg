-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-05-07
-- =============================================
-- EXEC rt.RoutingTier_UpdateDependencies @RoutingTierId = 12033
-- SELECT * FROM rt.RoutingTier WHERE RoutingTierId = 12033
CREATE PROCEDURE [rt].[RoutingTier_UpdateDependencies]
	@RoutingTierId int
AS
BEGIN

	IF @RoutingTierId IS NULL RETURN

	-- BUG FIX FOR https://wavecellagile.atlassian.net/browse/MAP-376
	-- prevent looping, but allow execution by another trigger (SupplierCostCoverage_DataChanged)
	IF TRIGGER_NESTLEVEL(OBJECT_ID('rt.RoutingTier_DataChanged')) > 1
	BEGIN
		PRINT 'RoutingTier_UpdateDependencies stopped due to recurrent call (TRIGGER_NESTLEVEL=' + CAST(TRIGGER_NESTLEVEL(OBJECT_ID('rt.RoutingTier_DataChanged')) as varchar(10)) + ')'
		RETURN
	END
	
	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Starting updates for RoutingTierId=' + CAST(@RoutingTierId as varchar(10)) + ' with TRIGGER_NESTLEVEL(rt.RoutingTier_DataChanged)=' + CAST(TRIGGER_NESTLEVEL(OBJECT_ID('rt.RoutingTier_DataChanged')) as varchar(10)) + ', TRIGGER_NESTLEVEL(ALL)=' + CAST(TRIGGER_NESTLEVEL() as varchar(10))
	
	-- BUG FIX and WARNING !!!
	-- all selects from "rt.RoutingTierConn" and "rt.SupplierCostCoverage" must be with NOLOCK hint inside this SP
	-- Reason: this SP is called inside triggers on rt.RoutingTierConn, rt.RoutingTier, rt.SupplierCostCoverage tables.
	-- As result, deadlock happens with default READ COMMITTED transaction level on accessing same resource, that is currently changing.

	/* Tier summary update */
	--DECLARE @RoutingTierId int = 1
	DECLARE @ConnSummary VARCHAR(1000) = ''
    SELECT @ConnSummary = @ConnSummary + cc.ConnId + ' [' + IIF(rtc.Active = 1, CAST(rtc.Weight as varchar(5)) + 'x', 'HOLD') + '] ' 
    FROM rt.RoutingTier (NOLOCK) rt 
		INNER JOIN rt.RoutingTierConn rtc (NOLOCK) ON rtc.RoutingTierId = rt.RoutingTierId AND rtc.Deleted = 0
		INNER JOIN rt.SupplierConn cc (NOLOCK) ON cc.ConnUid = rtc.ConnUid
	WHERE rtc.RoutingTierId = @RoutingTierId
    ORDER BY rtc.Weight DESC
	--SELECT @ConnSummary

	-- update CostCalculated in RoutingTier
	--DECLARE @ChangedCoverage TABLE (RoutingPlanCoverageId int)
	--DECLARE @ChangedGroup TABLE (RoutingGroupId int)

	UPDATE rt SET 
		CostCalculated = rtc.CostCalculated, CostCurrency = rtc.Currency,
		ConnSummary = RTRIM(@ConnSummary)
	--OUTPUT inserted.RoutingGroupId INTO @ChangedGroup (RoutingGroupId)
	--SELECT rtc.CostCalculated, ConnSummary = RTRIM(@ConnSummary)
	--select *
	FROM rt.RoutingTier rt
		INNER JOIN rt.RoutingPlanCoverage rpc ON rpc.RoutingGroupId = rt.RoutingGroupId
		INNER JOIN (
			SELECT rtc.RoutingTierId, 
				scc.Country, scc.OperatorId,
				'EUR' AS Currency,
				SUM(rtc.Weight * scc.CostEUR) / SUM(rtc.Weight) AS CostCalculated
			FROM rt.RoutingTierConn rtc (NOLOCK)
				--INNER JOIN rt.vwSupplierCostCoverage_Active (NOLOCK) scc 
				INNER JOIN rt.SupplierConn sc (NOLOCK) ON sc.ConnUid = rtc.ConnUid
				INNER JOIN rt.SupplierCostCoverage scc (NOLOCK) ON
					scc.RouteUid = sc.ConnUid 
					AND scc.Deleted = 0
					AND scc.SmsTypeId = 1
					AND scc.EffectiveFrom <= SYSUTCDATETIME()
			WHERE rtc.RoutingTierId = @RoutingTierId AND rtc.Deleted = 0
			GROUP BY rtc.RoutingTierId, scc.Country, scc.OperatorId
		) rtc ON rt.RoutingTierId = rtc.RoutingTierId AND 
				rtc.Country = rpc.Country AND
				ISNULL(rtc.OperatorId, 0) = ISNULL(rpc.OperatorId, 0)
	WHERE rt.RoutingTierId = @RoutingTierId 
		AND rt.Deleted = 0
		AND (rt.CostCalculated IS NULL OR rt.CostCalculated <> rtc.CostCalculated)
	PRINT dbo.Log_ROWCOUNT ('RoutingTier - CostCalculated and ConnSummary updated')

	
	--recalculate currently active tier level for group
	UPDATE rg 
	SET TierLevelCurrent = rgc.MinActiveLevel
	FROM rt.RoutingGroup rg
		INNER JOIN (
			SELECT rt.RoutingGroupId, MIN(rt.TierLevel) AS MinActiveLevel
			FROM rt.RoutingTier rt (NOLOCK)
				INNER JOIN rt.RoutingTierConn rtc (NOLOCK) ON 
					rt.RoutingTierId = rtc.RoutingTierId 
					AND rtc.Active = 1 
					AND rtc.Deleted = 0 
					AND rt.Deleted = 0
			WHERE rt.RoutingGroupId IN 
				(SELECT RoutingGroupId FROM rt.RoutingTier (NOLOCK) WHERE RoutingTierId = @RoutingTierId)
			GROUP BY rt.RoutingGroupId
		) rgc ON rg.RoutingGroupId = rgc.RoutingGroupId
	WHERE rg.TierLevelCurrent <> rgc.MinActiveLevel
	PRINT dbo.Log_ROWCOUNT ('RoutingGroup - TierLevelCurrent changed')

	-- update CostCalculated in RoutingPlanCoverage for active tier
	UPDATE rpc SET
		CostCalculated = rt.CostCalculated, 
		CostCurrency = rt.CostCurrency
	FROM rt.RoutingPlanCoverage rpc
		INNER JOIN rt.RoutingGroup (NOLOCK) rg 
			ON rpc.RoutingGroupId = rg.RoutingGroupId AND rg.Deleted = 0
		INNER JOIN rt.RoutingTier (NOLOCK) rt
			ON rg.RoutingGroupId = rt.RoutingGroupId AND rt.TierLevel = 1 AND rt.Deleted = 0
	WHERE rt.RoutingTierId = @RoutingTierId 
		AND rpc.Deleted = 0
		AND (rpc.CostCalculated IS NULL OR rpc.CostCalculated <> rt.CostCalculated)
	
	PRINT dbo.Log_ROWCOUNT ('RoutingPlanCoverage - CostCalculated updated')

	-- update CustomerGroupCoverage
	UPDATE cgc SET 
		CostCalculated = rt.CostCalculated,
		CostCurrency = rt.CostCurrency,
		--recalc Price if it's margin-based
		Price = IIF (cgc.MarginRate IS NULL, cgc.Price, (rt.CostCalculated * 100) / (100 - cgc.MarginRate)),
		CompanyPrice = IIF (cgc.MarginRate IS NULL, cgc.Price, (rt.CostCalculated * 100) / (100 - cgc.MarginRate)) /* copy from Price */
	FROM rt.CustomerGroupCoverage cgc
		INNER JOIN rt.RoutingGroup rg 
			ON rg.RoutingGroupId = cgc.RoutingGroupId AND rg.Deleted = 0
		INNER JOIN rt.RoutingTier (NOLOCK) rt 
			ON rt.RoutingGroupId = rg.RoutingGroupId AND rt.TierLevel = 1 /* primary only */ AND rt.Deleted = 0
	WHERE rt.RoutingTierId = @RoutingTierId 
		AND cgc.Deleted = 0
		AND (cgc.CostCalculated IS NULL OR cgc.CostCalculated <> rt.CostCalculated)
	
	PRINT dbo.Log_ROWCOUNT ('CustomerGroupCoverage - CostCalculated of primary tier updated')
END
