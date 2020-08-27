-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-12
-- =============================================
-- EXEC map.PricingPlanCoverage_DeleteById @PricingPlanCoverageId = 2
CREATE PROCEDURE [map].[PricingPlanCoverage_DeleteById]
	@PricingPlanCoverageId int,
	@UpdatedBy smallint
AS
BEGIN

	-- update pricing plan coverage
	UPDATE ppc
	SET Deleted = 1, UpdatedBy = @UpdatedBy, UpdatedAt = SYSUTCDATETIME()
	FROM rt.PricingPlanCoverage ppc
	WHERE ppc.PricingPlanCoverageId = @PricingPlanCoverageId

	-- update price in CustomerGroup coverages
	UPDATE cgc 
	SET Deleted = 1, UpdatedBy = @UpdatedBy, UpdatedAt = SYSUTCDATETIME()
	FROM rt.PricingPlanCoverage ppc
		INNER JOIN rt.CustomerGroupCoverage cgc 
			ON cgc.PricingPlanId = ppc.PricingPlanId
				AND cgc.Country = ppc.Country 
				AND ISNULL(cgc.OperatorId, 0) = ISNULL(ppc.OperatorId, 0)
	WHERE ppc.PricingPlanCoverageId = @PricingPlanCoverageId 
		AND ppc.Deleted = 1
END
