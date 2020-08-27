-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- =============================================
-- EXEC map.RoutingPlan_Delete @RoutingPlanId=123
CREATE PROCEDURE [map].[RoutingPlan_Delete]
	@RoutingPlanId int
AS
BEGIN

	UPDATE rt.RoutingPlan
	SET Deleted = 1, UpdatedAt = SYSUTCDATETIME()
	WHERE RoutingPlanId = @RoutingPlanId

END
