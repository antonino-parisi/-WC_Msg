-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-28
-- =============================================
-- EXEC map.[RoutingTierCondition_Update @@RoutingTierConditionId = 1, @ConditionTypeId = 1, @ConditionScopeId = 1
CREATE PROCEDURE [map].[RoutingTierCondition_Update]
	@RoutingTierConditionId int,
	@ConditionTypeId tinyint,	-- 1 - BIND, 2 - DR, 3 - MARGIN
	@ConditionScopeId tinyint	-- 1 - each connection, 2 - whole tier
AS
BEGIN
	UPDATE rt.RoutingTierCondition
	SET ConditionScopeId = @ConditionScopeId, ConditionTypeId = @ConditionTypeId
	WHERE RoutingTierConditionId = @RoutingTierConditionId
END
