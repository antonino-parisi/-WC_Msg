-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-04
-- =============================================
-- EXEC map.RoutingPlanCoverage_GetById @RoutingPlanId = 26, @Country = 'TH', @OperatorId = 520001, @OutputTiers = 1
CREATE PROCEDURE [map].[RoutingPlanCoverage_GetById]
	@RoutingPlanId int,
	@Country char(2) = NULL,
	@OperatorId int = NULL,
	@OutputTiers bit = 0
AS
BEGIN

	SELECT rpc.RoutingPlanCoverageId, 
		rpc.RoutingPlanId, rp.RoutingPlanName, 
		rpc.Country, c.CountryName, rpc.OperatorId, o.OperatorName,
		--rpc.CostCurrency, rpc.CostCalculated, 
		rtL1.CostCurrency, rtL1.CostCalculated,
		rg.RoutingGroupId, rg.RoutingGroupName, rg.TierLevelCurrent,
		rtL1.RoutingTierId AS L1_RoutingTierId, rtL1.RoutingTierName AS L1_RoutingTierName, rtL1.ConnSummary AS L1_ConnSummary,
		rpc.CreatedAt, rpc.UpdatedAt, rpc.CreatedBy, rpc.UpdatedBy
	FROM rt.RoutingPlanCoverage rpc
		JOIN rt.RoutingPlan rp ON rp.RoutingPlanId = rpc.RoutingPlanId
		LEFT JOIN mno.Operator o ON rpc.OperatorId = o.OperatorId
		LEFT JOIN mno.Country c ON rpc.Country = c.CountryISO2alpha
		LEFT JOIN rt.RoutingGroup rg ON rg.RoutingGroupId = rpc.RoutingGroupId AND rg.Deleted = 0
		--LEFT JOIN rt.RoutingGroupTier rgtL1 ON rgtL1.RoutingGroupId = rpc.RoutingGroupId AND rgtL1.Level = 1 AND rgtL1.Deleted = 0
		LEFT JOIN rt.RoutingTier rtL1 ON rg.RoutingGroupId = rtL1.RoutingGroupId AND rtL1.TierLevel = 1 AND rtL1.Deleted = 0
	WHERE rpc.RoutingPlanId = @RoutingPlanId
		AND rpc.TrafficCategory = 'DEF'
        AND rpc.Deleted = 0 -- Added to filter deleted countries
		AND (@Country IS NULL OR (@Country IS NOT NULL AND rpc.Country = @Country))
		AND (@OperatorId IS NULL OR (@OperatorId IS NOT NULL AND rpc.OperatorId = @OperatorId))

	IF @OutputTiers = 1
	BEGIN
		SELECT rpc.RoutingPlanCoverageId, rg.RoutingGroupId, rg.RoutingGroupName,
			rt.RoutingTierId AS RoutingTierId, rt.RoutingTierName AS RoutingTierName, 
			rt.TierLevel AS RoutingTierLevel, 
			rt.CostCalculated, rt.CostCurrency,
			IIF(SUM(CAST(rtc.Active as tinyint)) OVER (PARTITION BY rt.RoutingTierId) > 0, 1, 0) AS RoutingTierStatus,
			rtc.TierEntryId, rtc.ConnUid, ISNULL(cc.ConnId, '<DELETED>') AS ConnId, rtc.Weight, rtc.Active
		FROM rt.RoutingPlanCoverage rpc
			JOIN rt.RoutingGroup rg ON rg.RoutingGroupId = rpc.RoutingGroupId AND rg.Deleted = 0
			--JOIN rt.RoutingGroupTier rgt ON rgt.RoutingGroupId = rpc.RoutingGroupId AND rgt.Deleted = 0
			JOIN rt.RoutingTier rt ON rg.RoutingGroupId = rt.RoutingGroupId AND rt.Deleted = 0
			JOIN rt.RoutingTierConn rtc ON rtc.RoutingTierId = rt.RoutingTierId AND rtc.Deleted = 0
			LEFT JOIN rt.SupplierConn cc ON rtc.ConnUid = cc.ConnUid
		WHERE rpc.RoutingPlanId = @RoutingPlanId
			AND (@Country IS NULL OR (@Country IS NOT NULL AND rpc.Country = @Country))
			AND (@OperatorId IS NULL OR (@OperatorId IS NOT NULL AND rpc.OperatorId = @OperatorId))
	END
END
