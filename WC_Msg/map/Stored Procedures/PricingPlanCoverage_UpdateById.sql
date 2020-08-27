-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-12
-- =============================================
-- EXEC map.PricingPlanCoverage_UpdateById @PricingPlanCoverageId = 2, ...
CREATE PROCEDURE [map].[PricingPlanCoverage_UpdateById]
	@PricingPlanCoverageId int,
	@PriceCurrency char(3),
	@Price decimal(12,6),
	@Margin decimal(8,4),
	@UpdatedBy smallint
AS
BEGIN

	DECLARE @CompanyCurrency char(3) = 'EUR'
	DECLARE @CompanyPrice decimal(12,6)
	SET @CompanyPrice = mno.CurrencyConverter(@Price, @PriceCurrency, @CompanyCurrency, DEFAULT)

	-- update pricing plan coverage
	UPDATE ppc
	SET Price = @Price, 
		MarginRate = @Margin, 
		Currency = @PriceCurrency, 
		CompanyCurrency = @CompanyCurrency,
		CompanyPrice = @CompanyPrice,
		UpdatedBy = @UpdatedBy, 
		UpdatedAt = SYSUTCDATETIME()
	FROM rt.PricingPlanCoverage ppc
	WHERE ppc.PricingPlanCoverageId = @PricingPlanCoverageId

END
