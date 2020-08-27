-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- =============================================
-- EXEC map.RoutingPlan_Update @RoutingPlanId = 123, @RoutingPlanName = 'plan', @Description = 'description', @OwnerId = 123
CREATE PROCEDURE [map].[RoutingPlan_Update]
	@RoutingPlanId int,
	@RoutingPlanName nvarchar(100),
	@Description nvarchar(1000) = NULL,
	@OwnerId smallint
AS
BEGIN

	UPDATE rt.RoutingPlan
	SET RoutingPlanName = @RoutingPlanName, Description = @Description, 
		OwnerId = @OwnerId, UpdatedAt = SYSUTCDATETIME()
	WHERE RoutingPlanId = @RoutingPlanId

END
