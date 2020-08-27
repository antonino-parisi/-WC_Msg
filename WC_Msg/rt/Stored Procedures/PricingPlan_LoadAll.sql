-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-03
-- =============================================
-- EXEC rt.RoutingPlan_LoadAll
CREATE PROCEDURE rt.PricingPlan_LoadAll
	@LastSyncTimestamp datetime = NULL
AS
BEGIN
	SELECT pp.PricingPlanId, pp.PricingPlanName, pp.Deleted
	FROM rt.PricingPlan pp
	WHERE ((@LastSyncTimestamp IS NULL AND pp.Deleted = 0) 
		OR (@LastSyncTimestamp IS NOT NULL AND pp.UpdatedAt >= @LastSyncTimestamp))
END

