
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016/09/13
-- Description:	Get routing fallback subrules for Routing service
-- =============================================
CREATE PROCEDURE morph.[RoutingRuleFallback_GetAll]
AS
BEGIN
	SELECT FallbackRuleId, SubRuleId, FallbackRouteId, Priority
	FROM morph.RoutingRuleFallback
	ORDER BY SubRuleId, Priority DESC
END

