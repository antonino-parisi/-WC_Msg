
CREATE VIEW rt.vwPricingPlanCoverage --WITH SCHEMABINDING
AS
	SELECT ppc.PricingPlanCoverageId, ppc.Deleted, ppc.PricingPlanId, pp.PricingPlanName, 
		ppc.Country, ppc.OperatorId, ppc.Currency, ppc.Price,
		ppc.PricingFormulaId, 
		ppc.CreatedBy, ppc.CreatedAt, ppc.UpdatedBy, ppc.UpdatedAt
	FROM rt.PricingPlanCoverage ppc
		INNER JOIN rt.PricingPlan pp ON ppc.PricingPlanId = pp.PricingPlanId
		--LEFT JOIN rt.PricingFormula pf ON pf.PricingFormulaId = ppc.PricingFormulaId
	--WHERE ppc.Deleted = 0

