


CREATE VIEW [rt].[vwRoutingPlanCoverage]
AS
	SELECT 
		rpc.RoutingPlanCoverageId, 
		rpc.Deleted, 
		rpc.RoutingPlanId, rp.RoutingPlanName, 
		rpc.Country, rpc.OperatorId, 
		rpc.RoutingGroupId, rg.RoutingGroupName,
		rg.TierLevelCurrent,
		rt.RoutingTierId AS CurrentRoutingTierId, rt.RoutingTierName AS CurrentRoutingTierName,
		rpc.CostCalculated, rpc.CostCurrency,
		rpc.CreatedBy, rpc.CreatedAt, 
		rpc.UpdatedBy, rpc.UpdatedAt
	FROM rt.RoutingPlanCoverage rpc
		INNER JOIN rt.RoutingPlan rp ON rpc.RoutingPlanId = rp.RoutingPlanId AND rp.Deleted = 0
		INNER JOIN rt.RoutingGroup rg ON rg.RoutingGroupId = rpc.RoutingGroupId
		--LEFT JOIN rt.RoutingGroupTier rgt ON rg.RoutingGroupId = rgt.RoutingGroupId AND rg.TierLevelCurrent = rgt.Level
		LEFT JOIN rt.RoutingTier rt ON rg.RoutingGroupId = rt.RoutingGroupId AND rg.TierLevelCurrent = rt.TierLevel AND rt.Deleted = 0
	--WHERE rpc.Deleted = 0

