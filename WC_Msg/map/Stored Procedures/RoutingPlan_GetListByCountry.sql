-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-03-06
-- =============================================
-- EXEC map.[RoutingPlan_GetListByCountry] @Country = 'PH'
CREATE PROCEDURE [map].[RoutingPlan_GetListByCountry]
	@Country char(2)
AS
BEGIN

	SELECT DISTINCT rpc.Country, rpc.OperatorId, rp.RoutingPlanId, rp.RoutingPlanName, rpc.RoutingGroupId, rpc.CostCurrency, rpc.CostCalculated
	FROM rt.RoutingPlan rp
		INNER JOIN rt.RoutingPlanCoverage rpc ON rp.RoutingPlanId = rpc.RoutingPlanId
	WHERE rp.Deleted = 0 AND rpc.Deleted = 0 AND rpc.Country = @Country
END
