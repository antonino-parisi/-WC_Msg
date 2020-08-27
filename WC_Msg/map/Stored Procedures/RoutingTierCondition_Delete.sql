-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-28
-- =============================================
-- EXEC map.[RoutingTierCondition_Delete @@RoutingTierConditionId = 1
CREATE PROCEDURE [map].[RoutingTierCondition_Delete]
	@RoutingTierConditionId int
AS
BEGIN

	DELETE FROM rt.RoutingTierConditionBind		WHERE RoutingTierConditionId = @RoutingTierConditionId
	DELETE FROM rt.RoutingTierConditionDR		WHERE RoutingTierConditionId = @RoutingTierConditionId
	DELETE FROM rt.RoutingTierConditionMargin	WHERE RoutingTierConditionId = @RoutingTierConditionId
	DELETE FROM rt.RoutingTierCondition			WHERE RoutingTierConditionId = @RoutingTierConditionId
END
