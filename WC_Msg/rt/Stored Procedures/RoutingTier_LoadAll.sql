-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-03
-- =============================================
-- EXEC rt.RoutingTier_LoadAll
CREATE PROCEDURE [rt].[RoutingTier_LoadAll]
	@LastSyncTimestamp datetime = NULL
AS
BEGIN
	SELECT rt.RoutingTierId, rt.RoutingTierName, ISNULL(rtc.TotalConnections, 0) AS TotalConnections, rt.Deleted
	FROM rt.RoutingTier rt
		LEFT JOIN (
			SELECT RoutingTierId, COUNT(1) AS TotalConnections 
			FROM rt.RoutingTierConn 
			WHERE Deleted = 0 
			GROUP BY RoutingTierId ) rtc ON rt.RoutingTierId = rtc.RoutingTierId
	WHERE ((@LastSyncTimestamp IS NULL AND rt.Deleted = 0) 
		OR (@LastSyncTimestamp IS NOT NULL AND rt.UpdatedAt >= @LastSyncTimestamp))
END

