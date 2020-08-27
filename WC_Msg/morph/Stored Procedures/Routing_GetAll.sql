

-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016/08/08
-- Description:	Get routing rules for Routing service
-- =============================================
CREATE PROCEDURE [morph].[Routing_GetAll]
AS
BEGIN
	SELECT RuleId
		  ,SubAccountId
		  ,Country
		  ,OperatorId
		  ,IsActiveRoute
		  ,RouteStrategy
		  ,Currency
		  ,Price
		  ,UseCheapestRoute
	FROM morph.Routing

END


