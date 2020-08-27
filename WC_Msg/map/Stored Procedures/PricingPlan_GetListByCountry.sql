-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-03-06
-- =============================================
-- EXEC map.PricingPlan_GetListByCountry @Country = 'PH'
CREATE PROCEDURE [map].[PricingPlan_GetListByCountry]
	@Country char(2)
AS
BEGIN

	SELECT DISTINCT ppc.Country, ppc.OperatorId, pp.PricingPlanId, pp.PricingPlanName, ppc.Price, ppc.MarginRate
	FROM rt.PricingPlan pp
		INNER JOIN rt.PricingPlanCoverage ppc ON pp.PricingPlanId = ppc.PricingPlanId
	WHERE pp.Deleted = 0 AND ppc.Deleted = 0 AND ppc.Country = @Country
END
