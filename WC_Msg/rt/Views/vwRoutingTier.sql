


CREATE VIEW [rt].[vwRoutingTier]
AS
	SELECT 
		rt.RoutingTierId, rt.TierLevel, rt.RoutingGroupId, 
		rt.CostCurrency, rt.CostCalculated, rt.ConnSummary, rt.Deleted,
		rpc.Country, rpc.OperatorId, rpc.RoutingPlanId, rpc.TrafficCategory
	FROM rt.RoutingTier rt
		INNER JOIN rt.RoutingPlanCoverage rpc ON rpc.RoutingGroupId = rt.RoutingGroupId AND rpc.Deleted = 0

