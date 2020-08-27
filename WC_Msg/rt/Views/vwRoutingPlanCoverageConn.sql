



CREATE VIEW [rt].[vwRoutingPlanCoverageConn]
AS
	SELECT 
		rpc.RoutingPlanCoverageId, rpc.Deleted, 
		rpc.RoutingPlanId, rp.RoutingPlanName, 
		rpc.Country, 
		rpc.OperatorId, 
		IIF(rpc.OperatorId IS NOT NULL, ISNULL(o.OperatorName, '<DELETED>'), '<ANY>') AS OperatorName, 
		rpc.RoutingGroupId, --rg.RoutingGroupName,
		rg.TierLevelCurrent, 
		rt.RoutingTierName AS CurrentRoutingTierName,
		rpc.CostCalculated, rpc.CostCurrency,
		rpc.CreatedBy, rpc.CreatedAt, rpc.UpdatedBy, rpc.UpdatedAt,
		rtc.ConnUid, 
		ISNULL(cc.RouteId, '<DELETED>') AS ConnId, 
		rtc.Active AS ConnStatus, 
		rtc.Weight as ConnWeight
	FROM rt.RoutingPlanCoverage rpc
		INNER JOIN rt.RoutingPlan rp ON rpc.RoutingPlanId = rp.RoutingPlanId AND rp.Deleted = 0
		INNER JOIN rt.RoutingGroup rg ON rg.RoutingGroupId = rpc.RoutingGroupId AND rg.Deleted = 0
		--LEFT JOIN rt.RoutingGroupTier rgt ON rg.RoutingGroupId = rgt.RoutingGroupId AND rg.TierLevelCurrent = rgt.Level
		LEFT JOIN rt.RoutingTier rt ON rt.RoutingGroupId = rg.RoutingGroupId AND rt.Deleted = 0 AND rg.TierLevelCurrent = rt.TierLevel
		LEFT JOIN rt.RoutingTierConn rtc ON rt.RoutingTierId = rtc.RoutingTierId AND rtc.Deleted = 0
		LEFT JOIN dbo.CarrierConnections cc ON rtc.ConnUid = cc.RouteUid
		LEFT JOIN mno.Operator o ON rpc.OperatorId = o.OperatorId AND rpc.OperatorId IS NOT NULL
	--WHERE rpc.Deleted = 0
