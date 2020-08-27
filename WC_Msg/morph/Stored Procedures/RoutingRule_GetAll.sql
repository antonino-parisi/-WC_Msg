-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016/08/08
-- Description:	Get routing sub rules for Routing service
-- =============================================
CREATE PROCEDURE morph.[RoutingRule_GetAll]
AS
BEGIN
	SELECT SubRuleId,RuleId
		  ,StartTime
		  ,EndTime
		  ,Weight
		  ,RouteId
	FROM morph.RoutingRule
END

