-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-03
-- =============================================
-- EXEC rt.RoutingTierConn_LoadAll
CREATE PROCEDURE [rt].[RoutingTierConn_LoadAll]
	@LastSyncTimestamp datetime = NULL
AS
BEGIN
	SELECT rtc.TierEntryId, rtc.RoutingTierId, rtc.ConnUid, rtc.ConnId, rtc.Weight, rtc.Active, rtc.Deleted
	FROM rt.RoutingTierConn rtc
	WHERE ((@LastSyncTimestamp IS NULL AND rtc.Deleted = 0) 
			OR (@LastSyncTimestamp IS NOT NULL AND rtc.UpdatedAt >= @LastSyncTimestamp))
END
