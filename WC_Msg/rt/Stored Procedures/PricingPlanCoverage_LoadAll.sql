-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-03
-- =============================================
-- EXEC rt.PricingPlanCoverage_LoadAll @LastSyncTimestamp = '2017-08-01'
CREATE PROCEDURE [rt].[PricingPlanCoverage_LoadAll]
	@LastSyncTimestamp datetime = NULL
AS
BEGIN
	SELECT 
		ppc.PricingPlanCoverageId, 
		ppc.PricingPlanId, 
		ppc.Country, 
		ppc.OperatorId, 
		ppc.Currency,	-- EUR only
		IIF(ppc.Price IS NOT NULL, 'F', 'M') AS PricingMethod, 
		ppc.Price,		-- PriceEUR
		ppc.MarginRate AS Margin,
		ppc.CompanyCurrency,	-- deprecated
		ppc.CompanyPrice,		-- deprecated
		-- Price in Contract - not supported for this table yet
		ppc.Currency AS PriceContractCurrency,
		ppc.Price AS PriceContract,
		--IIF(ppc.PriceOriginalCurrency IS NOT NULL AND ppc.PriceOriginal IS NOT NULL AND ppc.MarginRate IS NULL,
		--	ppc.PriceOriginalCurrency,
		--	ppc.PriceCurrency	-- Temp solution: for Margin based prices - we use EUR only
		--) AS PriceContractCurrency,
		--IIF(ppc.PriceOriginalCurrency IS NOT NULL AND ppc.PriceOriginal IS NOT NULL AND ppc.MarginRate IS NULL,
		--	ppc.PriceOriginal,
		--	ppc.Price			-- Temp solution: for Margin based prices - we use EUR only
		--) AS PriceContract,
		--- 
		ppc.PricingFormulaId,
		ppc.Deleted
	FROM rt.PricingPlanCoverage ppc
	WHERE ((@LastSyncTimestamp IS NULL AND ppc.Deleted = 0) 
		OR (@LastSyncTimestamp IS NOT NULL AND ppc.UpdatedAt >= @LastSyncTimestamp))
END
