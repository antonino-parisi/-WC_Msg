-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-04-04
-- =============================================
-- EXEC rt.CustomerGroupCoverage_LoadAll
CREATE PROCEDURE [rt].[CustomerGroupCoverage_LoadAll]
	@LastSyncTimestamp datetime = NULL
AS
BEGIN
	SELECT cgc.CoverageId, 
		cgc.CustomerGroupId, 
		cgc.SubAccountUid,
		cgc.Country, 
		cgc.OperatorId, 
		cgc.TrafficCategory,
		cgc.RoutingGroupId, 
		cgc.PriceCurrency,		-- must be only EUR
		IIF(cgc.MarginRate IS NOT NULL, 'M', 'F') AS PricingMethod, 
		cgc.Price,				-- PriceEUR
		cgc.MarginRate AS Margin,
		cgc.CostCurrency,		-- must be only EUR
		cgc.CostCalculated,		-- in EUR, used for Margin based prices only
		cgc.CompanyCurrency,	-- deprecated
		cgc.CompanyPrice,		-- deprecated
		-- Price in Contract
		IIF(cgc.PriceOriginalCurrency IS NOT NULL AND cgc.PriceOriginal IS NOT NULL AND cgc.MarginRate IS NULL,
			cgc.PriceOriginalCurrency,
			cgc.PriceCurrency	-- Temp solution: for Margin based prices - we use EUR only
		) AS PriceContractCurrency,
		IIF(cgc.PriceOriginalCurrency IS NOT NULL AND cgc.PriceOriginal IS NOT NULL AND cgc.MarginRate IS NULL,
			cgc.PriceOriginal,
			cgc.Price			-- Temp solution: for Margin based prices - we use EUR only
		) AS PriceContract,
		cgc.Deleted
	FROM rt.CustomerGroupCoverage cgc
	WHERE ((@LastSyncTimestamp IS NULL AND cgc.Deleted = 0) 
		OR (@LastSyncTimestamp IS NOT NULL AND cgc.UpdatedAt >= @LastSyncTimestamp))
END
