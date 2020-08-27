
-- SELECT TOP 100 * FROM [rt].[vwRoutingPlanCoverageAllConn]
CREATE VIEW [rt].[vwRoutingPlanCoverageAllConn]
AS
	SELECT 
		rpc.RoutingPlanCoverageId, rpc.Deleted, 
		rpc.RoutingPlanId, rp.RoutingPlanName, rp.Deleted AS RP_Deleted,
		rpc.Country, 
		rpc.OperatorId, 
		IIF(rpc.OperatorId IS NOT NULL, ISNULL(o.OperatorName, '<MISSING>'), '<ANY>') AS OperatorName, 
		rpc.RoutingGroupId, 
		--rg.RoutingGroupName,
		rg.TierLevelCurrent, rg.Deleted AS RG_Deleted, 
		rt.TierLevel AS TierLevel,
		rt.RoutingTierId,
		--rgt.Deleted AS RGT_Deleted, 
		--rt.RoutingTierName AS RoutingTierName, 
		rt.Deleted AS RT_Deleted,
		rt.CostCalculated, rt.CostCurrency,
		rpc.CreatedBy, rpc.CreatedAt, rpc.UpdatedBy, rpc.UpdatedAt,
		rtc.TierEntryId, rtc.ConnUid, ISNULL(cc.ConnId, '<MISSING>') AS ConnId, 
		rtc.Active AS ConnStatus, rtc.Weight as ConnWeight, rtc.Deleted AS RTC_Deleted,
		scc.CostEUR, scc.CostLocal, scc.CostLocalCurrency
	FROM rt.RoutingPlanCoverage rpc
		INNER JOIN rt.RoutingPlan rp ON rpc.RoutingPlanId = rp.RoutingPlanId
		INNER JOIN rt.RoutingGroup rg ON rg.RoutingGroupId = rpc.RoutingGroupId
		--LEFT JOIN rt.RoutingGroupTier rgt ON rg.RoutingGroupId = rgt.RoutingGroupId --AND rg.TierLevelCurrent = rgt.Level
		LEFT JOIN rt.RoutingTier rt ON rt.RoutingGroupId = rg.RoutingGroupId -- rgt.RoutingTierId = rt.RoutingTierId
		LEFT JOIN rt.RoutingTierConn rtc ON rt.RoutingTierId = rtc.RoutingTierId
		LEFT JOIN rt.SupplierConn cc ON rtc.ConnUid = cc.ConnUid
		LEFT JOIN mno.Operator o ON rpc.OperatorId = o.OperatorId AND rpc.OperatorId IS NOT NULL
		LEFT JOIN rt.SupplierCostCoverage scc ON scc.RouteUid = rtc.ConnUid AND scc.OperatorId = rpc.OperatorId AND scc.SmsTypeId = 1 AND scc.Deleted = 0
	--WHERE rpc.Deleted = 0
