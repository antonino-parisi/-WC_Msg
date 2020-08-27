CREATE VIEW rt.RoutingTierConn_Active
AS
	SELECT rt.RoutingTierId, rt.RoutingTierName, rtc.ConnUid, cc.RouteId AS ConnId, rtc.Weight, rtc.Active
	FROM rt.RoutingTier rt 
		INNER JOIN rt.RoutingTierConn rtc ON rtc.RoutingTierId = rt.RoutingTierId AND rtc.Deleted = 0 AND rtc.Active = 1
		INNER JOIN dbo.CarrierConnections cc ON cc.RouteUid = rtc.ConnUid
