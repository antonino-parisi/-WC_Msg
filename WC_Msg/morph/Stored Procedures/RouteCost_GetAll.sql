
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-06-28
-- Description:	Get costs for all active routes and operators
-- =============================================
-- EXEC rt.RouteCost_GetAll
CREATE PROCEDURE [morph].[RouteCost_GetAll]
WITH EXECUTE AS 'dbo'
AS
BEGIN
	SELECT CAST(RouteId as varchar(50)) as RouteId, TRY_PARSE(Operator AS INT) AS OperatorId, 'EUR' as Currency, CAST(Cost as real) AS Cost
	FROM dbo.CPCost
	WHERE /*removed on purpose, cause a problem in COst Provisioning for zero cost => Active = 1 AND */ TRY_PARSE(Operator AS INT) IS NOT NULL
	UNION ALL
	SELECT CAST(RouteId as varchar(50)) as RouteId, 0 AS OperatorId, 'EUR' as Currency, CAST(MAX(Cost) as real) AS Cost
	FROM dbo.CPCost
	WHERE Active = 1
	GROUP BY RouteId

END


