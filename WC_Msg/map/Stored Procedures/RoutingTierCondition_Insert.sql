-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-28
-- =============================================
-- EXEC map.[RoutingTierCondition_Insert @RoutingTierId = 1219, @ConditionTypeId = 1, @ConditionScopeId = 1
CREATE PROCEDURE [map].[RoutingTierCondition_Insert]
	@RoutingTierId int,
	@ConditionTypeId tinyint,	-- 1 - BIND, 2 - DR, 3 - MARGIN
	@ConditionScopeId tinyint	-- 1 - each connection, 2 - whole tier
AS
BEGIN
	DECLARE @Output TABLE (RoutingTierConditionId int)

	INSERT INTO rt.RoutingTierCondition (RoutingTierId, ConditionTypeId, ConditionScopeId)
	OUTPUT inserted.RoutingTierConditionId INTO @Output
	VALUES (@RoutingTierId, @ConditionTypeId, @ConditionScopeId)

	IF @ConditionTypeId = 1
		INSERT INTO rt.RoutingTierConditionBind (RoutingTierConditionId) 
		SELECT RoutingTierConditionId FROM @Output
	ELSE IF @ConditionTypeId = 2
		INSERT INTO rt.RoutingTierConditionDR (RoutingTierConditionId) 
		SELECT RoutingTierConditionId FROM @Output
	ELSE IF @ConditionTypeId = 3
		INSERT INTO rt.RoutingTierConditionMargin (RoutingTierConditionId) 
		SELECT RoutingTierConditionId FROM @Output

	SELECT RoutingTierConditionId FROM @Output
END
