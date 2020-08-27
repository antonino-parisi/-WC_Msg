
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-21
-- Description:	Data for Routing page
-- =============================================
-- Examples:
-- EXEC rt.RouteOperator_GetDataByCountry 'SG'
-- =============================================
CREATE PROCEDURE [rt].[RouteOperator_GetDataByCountry]
	@CountryISO2alpha char(2),
	@WithRankingOnly bit = 0
AS
BEGIN

    SELECT 
		o.OperatorId, 
		o.OperatorName AS OperatorName, 
		scc.ConnId AS RouteId, 
		ro.IsActiveRoute, 
		ro.Ranking, 
		scc.CostLocalCurrency AS Currency,
		scc.CostLocal AS Cost,
		--ro.Currency, 
		--CAST(ro.Cost AS decimal(10,6)) AS Cost, 
		ro.JsonData
	FROM mno.Operator o
		INNER JOIN rt.RoutingView_Operator ro ON ro.OperatorId = o.OperatorId
		INNER JOIN rt.vwSupplierCostCoverage_Active scc ON scc.OperatorId = o.OperatorId AND scc.ConnUid = ro.RouteUid AND scc.SmsTypeId = 1
		INNER JOIN mno.Country c ON o.CountryISO2alpha = c.CountryISO2alpha
	WHERE 
		o.CountryISO2alpha = @CountryISO2alpha 
		AND ro.IsActiveRoute = 1
		AND (@WithRankingOnly = 0 OR (@WithRankingOnly = 1 AND ro.Ranking IS NOT NULL))
	ORDER BY o.OperatorId, ro.Ranking, scc.ConnId, ro.IsActiveRoute DESC
END