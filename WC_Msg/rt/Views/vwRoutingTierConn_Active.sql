
CREATE VIEW [rt].[vwRoutingTierConn_Active]
AS
	SELECT rt.RoutingTierId, rt.RoutingTierName, rtc.ConnUid, cc.ConnId, rtc.Weight, rtc.Active
	FROM rt.RoutingTier rt 
		INNER JOIN rt.RoutingTierConn rtc ON rtc.RoutingTierId = rt.RoutingTierId AND rtc.Deleted = 0 AND rtc.Active = 1 AND rt.Deleted = 0
		INNER JOIN rt.SupplierConn cc ON cc.ConnUid = rtc.ConnUid
