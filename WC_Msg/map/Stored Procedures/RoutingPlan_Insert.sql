-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- =============================================
-- EXEC map.RoutingPlan_Insert @RoutingPlanName = 'routing plan #1', @Description = 'description', @OwnerId = 123
CREATE PROCEDURE [map].[RoutingPlan_Insert]
	@RoutingPlanName nvarchar(100),
	@Description nvarchar(1000) = NULL,
	@OwnerId smallint
AS
BEGIN

	DECLARE @Output TABLE (RoutingPlanId int)

	INSERT INTO rt.RoutingPlan (RoutingPlanName, Description, OwnerId, CreatedAt, UpdatedAt)
	OUTPUT inserted.RoutingPlanId INTO @Output (RoutingPlanId)
	VALUES (@RoutingPlanName, @Description, @OwnerId, SYSUTCDATETIME(), SYSUTCDATETIME())

	SELECT RoutingPlanId FROM @Output
END
