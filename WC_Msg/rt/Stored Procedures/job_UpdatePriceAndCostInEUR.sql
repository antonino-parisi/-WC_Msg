-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-05-11
-- =============================================
-- EXEC rt.job_UpdatePriceAndCostInEUR @ForceExchangeRateUpdate = 1
CREATE PROCEDURE [rt].[job_UpdatePriceAndCostInEUR]
	@ForceExchangeRateUpdate bit = 0
AS
BEGIN

	-- CONST
	DECLARE @CostChangeThreshold decimal(4,2) = 0.02
	DECLARE @CONST_EUR char(3) = 'EUR'

	--DEBUG
	--DECLARE @ForceExchangeRateUpdate bit = 1

	-- update costs in not EUR currencies
	UPDATE scc SET CostEUR = ROUND(cr.Rate * scc.CostLocal, 6), UpdatedAt = SYSUTCDATETIME()
	--SELECT *
	FROM rt.SupplierCostCoverage scc
		INNER JOIN mno.CurrencyRate cr 
			ON scc.CostLocalCurrency = cr.CurrencyFrom 
				AND cr.CurrencyTo = @CONST_EUR
				AND cr.IsCurrent = 1
	WHERE scc.Deleted = 0 AND scc.CostLocalCurrency <> @CONST_EUR
		AND scc.CostEUR > 0
		AND scc.CostEUR <> ROUND(cr.Rate * scc.CostLocal, 6) -- exclude identical values
		AND (@ForceExchangeRateUpdate = 1 OR
			 ABS( (scc.CostEUR - cr.Rate * scc.CostLocal) / scc.CostEUR ) > @CostChangeThreshold)
	
	PRINT dbo.Log_ROWCOUNT ('rt.SupplierCostCoverage - update of non-EUR costs')
	
	--DEBUG
	--DECLARE @ForceExchangeRateUpdate bit = 1
	--DECLARE @CostChangeThreshold decimal(4,2) = 0.05

	-- update prices in PlanRouting
	UPDATE pr SET Price = ROUND(cr.Rate * pr.PriceLocal, 6)
	--SELECT *, ROUND(cr.Rate * pr.PriceLocal, 6) AS NewPrice, ABS( (pr.Price - cr.Rate * pr.PriceLocal) / pr.Price )
	FROM dbo.PlanRouting pr
		INNER JOIN mno.CurrencyRate cr ON 
			pr.PriceLocalCurrency = cr.CurrencyFrom 
			AND cr.CurrencyTo = @CONST_EUR
			AND cr.IsCurrent = 1
	WHERE (pr.PriceLocalCurrency IS NOT NULL AND pr.PriceLocalCurrency <> @CONST_EUR)
		AND pr.Price <> 0
		AND pr.Price <> ROUND(cr.Rate * pr.PriceLocal, 6) -- exclude identical values
		AND (@ForceExchangeRateUpdate = 1 OR
			 ABS( (pr.Price - cr.Rate * pr.PriceLocal) / pr.Price ) > @CostChangeThreshold)

	PRINT dbo.Log_ROWCOUNT ('dbo.PlanRouting - update of non-EUR prices')

	-- update prices in PricingPlanCoverage
	UPDATE ppc SET CompanyPrice = ROUND(cr.Rate * ppc.Price, 6)
	--SELECT *, ROUND(cr.Rate * ppc.Price, 6)  AS NewPrice, ABS( (ppc.CompanyPrice - cr.Rate * ppc.Price) / ppc.CompanyPrice  )
	FROM rt.PricingPlanCoverage ppc
		INNER JOIN mno.CurrencyRate cr ON 
			cr.CurrencyFrom = ppc.Currency
			AND cr.CurrencyTo = ppc.CompanyCurrency
			AND cr.IsCurrent = 1
	WHERE (ppc.Currency <> ppc.CompanyCurrency)
		AND ppc.Price <> 0
		AND ppc.CompanyPrice <> ROUND(cr.Rate * ppc.Price, 6) -- exclude identical values
		AND (@ForceExchangeRateUpdate = 1 OR
			 ABS( (ppc.CompanyPrice - cr.Rate * ppc.Price) / ppc.CompanyPrice  ) > @CostChangeThreshold)

	PRINT dbo.Log_ROWCOUNT ('rt.PricingPlanCoverage - update of non-EUR prices')

	-- update prices in CustomerGroupCoverage
	UPDATE cgc SET Price = ROUND(cr.Rate * cgc.PriceOriginal, 6)
	--SELECT *, ROUND(cr.Rate * cgc.PriceOriginal, 6)  AS NewPrice, ABS( (cgc.Price - cr.Rate * cgc.PriceOriginal) / cgc.Price)
	FROM rt.CustomerGroupCoverage cgc
		INNER JOIN mno.CurrencyRate cr ON 
			cr.CurrencyFrom = cgc.PriceOriginalCurrency
			AND cr.CurrencyTo = cgc.PriceCurrency
			AND cr.IsCurrent = 1
	WHERE (cgc.PriceOriginalCurrency IS NOT NULL AND cgc.PriceOriginalCurrency <> cgc.PriceCurrency)
		AND cgc.PriceCurrency = @CONST_EUR
		AND cgc.Price <> 0
		AND cgc.Price <> ROUND(cr.Rate * cgc.PriceOriginal, 6) -- exclude identical values
		AND (@ForceExchangeRateUpdate = 1 OR
			 ABS( (cgc.Price - cr.Rate * cgc.PriceOriginal) / cgc.Price  ) > @CostChangeThreshold)

	PRINT dbo.Log_ROWCOUNT ('rt.CustomerGroupCoverage - update of non-EUR prices')

	-- update CompanyPrice in CustomerGroupCoverage based on Price
	UPDATE cgc SET CompanyPrice = ROUND(cr.Rate * cgc.Price, 6)
	--SELECT *, ROUND(cr.Rate * cgc.Price, 6)  AS NewPrice, ABS( (cgc.CompanyPrice - cr.Rate * cgc.Price) / cgc.CompanyPrice)
	FROM rt.CustomerGroupCoverage cgc
		INNER JOIN mno.CurrencyRate cr ON 
			cr.CurrencyFrom = cgc.PriceCurrency
			AND cr.CurrencyTo = cgc.CompanyCurrency
			AND cr.IsCurrent = 1
	WHERE --(cgc.CompanyCurrency <> cgc.PriceCurrency)
		--AND cgc.PriceCurrency <> 'EUR'
		cgc.CompanyPrice <> 0
		AND cgc.CompanyPrice <> ROUND(cr.Rate * cgc.Price, 6) -- exclude identical values

	PRINT dbo.Log_ROWCOUNT ('rt.CustomerGroupCoverage - update of EUR CompanyPrice')

END
