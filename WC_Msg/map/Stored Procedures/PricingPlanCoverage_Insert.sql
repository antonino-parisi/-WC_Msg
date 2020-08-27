-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-12
-- =============================================
-- EXEC map.PricingPlanCoverage_Insert @PricingPlanId = 2, ...
CREATE PROCEDURE [map].[PricingPlanCoverage_Insert]
	@PricingPlanId int,
	@Country char(2),
	@OperatorId int = NULL,
	@PriceCurrency char(3),
	@Price decimal(12,6),
	@Margin decimal(8,4),
	@UpdatedBy smallint
AS
BEGIN

	DECLARE @CompanyCurrency char(3) = 'EUR'
	DECLARE @CompanyPrice decimal(12,6)
	SET @CompanyPrice = mno.CurrencyConverter(@Price, @PriceCurrency, @CompanyCurrency, DEFAULT)
	
	DECLARE @Output TABLE (PricingPlanCoverageId int)

	INSERT INTO rt.PricingPlanCoverage (
		PricingPlanId, 
		Country, OperatorId, 
		Currency, Price, MarginRate, 
		CompanyCurrency, CompanyPrice,
		CreatedAt, CreatedBy, UpdatedAt, UpdatedBy)
	OUTPUT inserted.PricingPlanCoverageId INTO @Output (PricingPlanCoverageId)
	VALUES (@PricingPlanId, @Country, @OperatorId, 
		@PriceCurrency, @Price, @Margin, 
		@CompanyCurrency, @CompanyPrice,
		SYSUTCDATETIME(), @UpdatedBy, SYSUTCDATETIME(), @UpdatedBy)

	SELECT PricingPlanCoverageId FROM @Output
END
