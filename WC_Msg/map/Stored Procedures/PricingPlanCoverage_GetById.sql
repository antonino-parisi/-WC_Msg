-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-04
-- =============================================
-- EXEC map.PricingPlanCoverage_GetById @PricingPlanId = 2, @Country = 'SG'
CREATE PROCEDURE [map].[PricingPlanCoverage_GetById]
	@PricingPlanId int,
	@Country char(2) = NULL,
	@OperatorId int = NULL
	--@RoutingPlanId int = NULL
AS
BEGIN

	SELECT ppc.PricingPlanCoverageId, 
		ppc.PricingPlanId, pp.PricingPlanName, 
		ppc.Country, c.CountryName, ppc.OperatorId, o.OperatorName, 
		o.MCC_List AS MCC, o.MNC_List AS MNCs,
		ppc.Currency AS PriceCurrency,
		IIF(ppc.Price IS NOT NULL, 'F', 'M') AS PricingMethod,
		IIF(ppc.MarginRate IS NOT NULL, NULL, ppc.Price) AS Price, 
		ppc.MarginRate AS Margin,
		ppc.CompanyCurrency, ppc.CompanyPrice, 
		ppc.CreatedAt, ppc.UpdatedAt, ppc.CreatedBy, ppc.UpdatedBy
	FROM rt.PricingPlanCoverage ppc
		JOIN rt.PricingPlan pp ON ppc.PricingPlanId = pp.PricingPlanId
		LEFT JOIN mno.Operator o ON ppc.OperatorId = o.OperatorId
		LEFT JOIN mno.Country c ON ppc.Country = c.CountryISO2alpha
	WHERE ppc.PricingPlanId = @PricingPlanId AND ppc.Deleted = 0
		AND (@Country IS NULL OR (@Country IS NOT NULL AND ppc.Country = @Country))
		AND (@OperatorId IS NULL OR (@OperatorId IS NOT NULL AND ppc.OperatorId = @OperatorId))
END
