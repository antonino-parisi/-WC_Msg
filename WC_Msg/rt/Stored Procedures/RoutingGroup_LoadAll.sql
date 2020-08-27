-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-03
-- =============================================
-- EXEC rt.RoutingGroup_LoadAll
CREATE PROCEDURE [rt].[RoutingGroup_LoadAll]
	@LastSyncTimestamp datetime = NULL
AS
BEGIN
	SELECT 
		rg.RoutingGroupId, 
		rg.RoutingGroupName, 
		rg.TierLevelCurrent, 
		rg.Deleted
		--ISNULL(rt.TierTotal, 0) AS TierTotal
	FROM rt.RoutingGroup rg
		--LEFT JOIN (
		--	SELECT rt.RoutingGroupId, COUNT(1) AS TierTotal
		--	FROM rt.RoutingTier rt
		--	WHERE rt.Deleted = 0
		--	GROUP BY rt.RoutingGroupId
		--) rt ON rt.RoutingGroupId = rg.RoutingGroupId
	WHERE ((@LastSyncTimestamp IS NULL AND rg.Deleted = 0) 
		OR (@LastSyncTimestamp IS NOT NULL AND rg.UpdatedAt >= @LastSyncTimestamp))
END
