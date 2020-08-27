-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-03
-- =============================================
-- EXEC rt.RoutingPlan_LoadAll
CREATE PROCEDURE rt.RoutingPlan_LoadAll
	@LastSyncTimestamp datetime = NULL
AS
BEGIN
	SELECT rp.RoutingPlanId, rp.RoutingPlanName, rp.Deleted
	FROM rt.RoutingPlan rp
	WHERE ((@LastSyncTimestamp IS NULL AND rp.Deleted = 0) OR (@LastSyncTimestamp IS NOT NULL AND rp.UpdatedAt >= @LastSyncTimestamp))
END

