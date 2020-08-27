


CREATE VIEW [rt].[vwRoutingTierConnMap]
AS
	SELECT 
		rtc.TierEntryId, 
		rtc.Deleted, 
		rtc.RoutingTierId, 
		rt.RoutingTierName, 
		rtc.ConnUid, 
		c.ConnId, 
		rtc.Weight, 
		rtc.Active,
		rt.TierLevel, 
		--rgt.RoutingGroupTierId, 
		rt.RoutingGroupId, 
		rt.CostCurrency,
		rt.CostCalculated,
		rt.Deleted AS RT_Deleted,
		rg.RoutingGroupName, 
		rg.DataSourceId,
		rg.TierLevelCurrent
	FROM rt.RoutingTierConn rtc
		INNER JOIN rt.RoutingTier rt ON rt.RoutingTierId = rtc.RoutingTierId AND rt.Deleted = 0
		--INNER JOIN rt.RoutingGroupTier rgt ON rgt.RoutingTierId = rt.RoutingTierId
		INNER JOIN rt.RoutingGroup rg ON rt.RoutingGroupId = rg.RoutingGroupId AND rg.Deleted = 0
		LEFT JOIN rt.SupplierConn c ON c.ConnUid = rtc.ConnUid
	--ORDER BY rg.RoutingGroupId, rgt.Level, rtc.Weight DESC

