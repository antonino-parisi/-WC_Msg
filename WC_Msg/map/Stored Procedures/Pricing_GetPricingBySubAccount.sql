-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-04-23
-- Description:	Pricelist for customer
-- =============================================
-- EXEC map.[Pricing_GetPricingBySubAccount] @SubAccountUid = 5603, @PriceChangedSince = '2018-12-18 9:15:47'
CREATE PROCEDURE [map].[Pricing_GetPricingBySubAccount]
	@SubAccountUid int,
	@PriceChangedSince smalldatetime = NULL	-- optional filter
AS
BEGIN

	-- debug
	--DECLARE @AccountUid uniqueidentifier = '2318BDEB-C250-E711-8141-06B9B96CA965'
	--DECLARE @AccountUid uniqueidentifier = 'C960EFD6-0C7C-E711-8141-06B9B96CA965'
	
	SELECT q.SubAccountUid, sa.SubAccountId,
		q.Country, c.CountryName,
		q.OperatorId, o.OperatorName, o.MCC_List, o.MNC_List,
		q.Currency, q.Price, NULL AS PriceOld,
		q.PriceChangedAt
	FROM (
		SELECT 
			ISNULL(cgc_ex.SubAccountUid, cgc_def.SubAccountUid) AS SubAccountUid,
			ISNULL(cgc_ex.Country, cgc_def.Country) AS Country,
			ISNULL(cgc_ex.OperatorId, cgc_def.OperatorId) AS OperatorId,
			ISNULL(cgc_ex.Currency, cgc_def.Currency) AS Currency,
			ISNULL(cgc_ex.Price, cgc_def.Price) AS Price,
			ISNULL(cgc_ex.PriceChangedAt, cgc_def.PriceChangedAt) AS PriceChangedAt
			--IIF(cgc_ex.Price IS NOT NULL, cgc_ex.PriceChangedAt, cgc_def.PriceChangedAt) AS PriceChangedAt
		FROM 
			-- subaccount level rules
			(
				SELECT 
					sa.SubAccountUid, 
					cgc.Country, cgc.OperatorId,
					ISNULL(cgc.PriceOriginalCurrency, cgc.PriceCurrency) AS Currency, 
					IIF(cgc.PriceOriginalCurrency IS NOT NULL, cgc.PriceOriginal, cgc.Price) AS Price,
					cgc.PriceChangedAt
				FROM ms.SubAccount sa
					INNER JOIN rt.CustomerGroupCoverage cgc
						ON cgc.SubAccountUid = sa.SubAccountUid AND cgc.Deleted = 0 AND cgc.TrafficCategory = 'DEF'
				WHERE sa.SubAccountUid = @SubAccountUid
			) AS cgc_ex
			-- customer group level rules
			FULL JOIN (
				SELECT 
					cgsa.SubAccountUid,
					cgc.Country, cgc.OperatorId,
					ISNULL(cgc.PriceOriginalCurrency, cgc.PriceCurrency) AS Currency, 
					IIF(cgc.PriceOriginalCurrency IS NOT NULL, cgc.PriceOriginal, cgc.Price) AS Price,
					cgc.PriceChangedAt
				FROM ms.SubAccount sa
					INNER JOIN rt.CustomerGroupSubAccount cgsa
						ON cgsa.SubAccountUid = sa.SubAccountUid AND cgsa.Deleted = 0
					INNER JOIN rt.CustomerGroupCoverage cgc
						ON cgsa.CustomerGroupId = cgc.CustomerGroupId AND cgc.SubAccountUid IS NULL AND cgc.Deleted = 0 AND cgc.TrafficCategory = 'DEF'
				WHERE sa.SubAccountUid = @SubAccountUid
			) cgc_def ON cgc_ex.SubAccountUid = cgc_def.SubAccountUid AND cgc_def.Country = cgc_ex.Country AND cgc_def.OperatorId = cgc_ex.OperatorId
		WHERE (cgc_def.Price IS NOT NULL OR cgc_ex.Price IS NOT NULL)
	) q
		INNER JOIN mno.Country c ON q.Country = c.CountryISO2alpha
		INNER JOIN mno.Operator o ON q.OperatorId = o.OperatorId
		INNER JOIN dbo.Account sa ON q.SubAccountUid = sa.SubAccountUid
		--INNER JOIN cp.Account a ON a.AccountId = sa.AccountId
	WHERE 
		q.Price > 0 -- MAP-406: EXCLUDE zero-prices
		--(@SubAccountUid IS NULL OR (@SubAccountUid IS NOT NULL AND q.SubAccountUid = @SubAccountUid)) AND 
		AND (@PriceChangedSince IS NULL OR (@PriceChangedSince IS NOT NULL AND q.PriceChangedAt >= @PriceChangedSince))
	ORDER BY q.SubAccountUid, q.Country, q.OperatorId

END
