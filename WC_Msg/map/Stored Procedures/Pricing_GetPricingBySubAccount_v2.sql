-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-04-23
-- Description:	Pricelist for customer
-- =============================================
-- EXEC map.[Pricing_GetPricingBySubAccount_v2] @SubAccountUid = 9598, @PriceChangedSince = '2020-03-01 9:15:47'
CREATE PROCEDURE [map].[Pricing_GetPricingBySubAccount_v2]
	@SubAccountUid int,
	@PriceChangedSince smalldatetime = NULL	-- optional filter
AS
BEGIN

	-- debug
	--DECLARE @SubAccountUid int = 6801
		
	SELECT 
		q.SubAccountUid, sa.SubAccountId,
		q.Country, c.CountryName,
		q.OperatorId, 
		ISNULL(o.OperatorName, 'Others') AS OperatorName, 
		ISNULL(o.MCC_List, c.MCCDefault) AS MCC_List, o.MNC_List,
		q.Currency, q.Price, 
		NULL AS PriceOld,
		q.PriceChangedAt
		--q.RowPriority
	FROM (
		
		--DECLARE @SubAccountUid int = 6801
		SELECT *, 
			ROW_NUMBER () OVER (PARTITION BY SubAccountUid, Country, OperatorId ORDER BY RowPriority DESC) as RowNum
		FROM (
			SELECT 
				cgc.SubAccountUid, 
				cgc.Country, 
				cgc.OperatorId,
				ISNULL(cgc.PriceOriginalCurrency, cgc.PriceCurrency) AS Currency, 
				IIF(cgc.PriceOriginalCurrency IS NOT NULL, cgc.PriceOriginal, cgc.Price) AS Price,
				cgc.PriceChangedAt,
				10 AS RowPriority
			FROM rt.CustomerGroupCoverage cgc
			WHERE 
				cgc.SubAccountUid = @SubAccountUid
				AND cgc.Deleted = 0 AND cgc.TrafficCategory = 'DEF'
			UNION ALL
			-- Member plan, Operator ANY (cloning of 1 ANY record for each OperatorId within Country)
			SELECT 
				cgc.SubAccountUid, 
				cgc.Country, 
				o.OperatorId, -- it's cloning in case of cgc.OperatorId = ANY (NULL)
				ISNULL(cgc.PriceOriginalCurrency, cgc.PriceCurrency) AS Currency, 
				IIF(cgc.PriceOriginalCurrency IS NOT NULL, cgc.PriceOriginal, cgc.Price) AS Price,
				cgc.PriceChangedAt,
				8 as RowPriority
			FROM rt.CustomerGroupCoverage cgc
				INNER JOIN mno.Operator o 
					ON cgc.Country = o.CountryISO2alpha
						AND cgc.OperatorId IS NULL -- rule only for ANY record
			WHERE 
				cgc.SubAccountUid = @SubAccountUid
				AND cgc.Deleted = 0 AND cgc.TrafficCategory = 'DEF'
			UNION ALL
			-- Group plan, individual OperatorId
			SELECT 
				cgsa.SubAccountUid,
				cgc.Country, 
				cgc.OperatorId,
				ISNULL(cgc.PriceOriginalCurrency, cgc.PriceCurrency) AS Currency, 
				IIF(cgc.PriceOriginalCurrency IS NOT NULL, cgc.PriceOriginal, cgc.Price) AS Price,
				cgc.PriceChangedAt,
				6 as RowPriority
			FROM rt.CustomerGroupSubAccount cgsa
				INNER JOIN rt.CustomerGroupCoverage cgc
					ON cgsa.CustomerGroupId = cgc.CustomerGroupId 
						AND cgc.SubAccountUid IS NULL 
						AND cgc.Deleted = 0 
						AND cgc.TrafficCategory = 'DEF'
			WHERE 
				cgsa.SubAccountUid = @SubAccountUid AND cgsa.Deleted = 0
			UNION ALL
			-- Group plan, OperatorId = ANY (NULL), cloning for each Operator
			SELECT 
				cgsa.SubAccountUid,
				cgc.Country, 
				o.OperatorId,  -- it's cloning in case of cgc.OperatorId = ANY (NULL)
				ISNULL(cgc.PriceOriginalCurrency, cgc.PriceCurrency) AS Currency, 
				IIF(cgc.PriceOriginalCurrency IS NOT NULL, cgc.PriceOriginal, cgc.Price) AS Price,
				cgc.PriceChangedAt,
				4 as RowPriority
			FROM rt.CustomerGroupSubAccount cgsa
				INNER JOIN rt.CustomerGroupCoverage cgc
					ON cgsa.CustomerGroupId = cgc.CustomerGroupId 
						AND cgc.SubAccountUid IS NULL 
						AND cgc.Deleted = 0 
						AND cgc.TrafficCategory = 'DEF'
				INNER JOIN mno.Operator o 
					ON cgc.Country = o.CountryISO2alpha
						AND cgc.OperatorId IS NULL -- rule only for ANY record
			WHERE 
				cgsa.SubAccountUid = @SubAccountUid 
				AND cgsa.Deleted = 0
		) t ) q
		INNER JOIN mno.Country c ON q.Country = c.CountryISO2alpha
		LEFT JOIN mno.Operator o ON q.OperatorId = o.OperatorId
		INNER JOIN ms.SubAccount sa ON q.SubAccountUid = sa.SubAccountUid
	WHERE
		q.RowNum = 1 -- price rule with highest priority
		AND sa.Active = 1
		AND q.Price > 0 -- MAP-406: EXCLUDE zero-prices
		AND (@PriceChangedSince IS NULL OR (@PriceChangedSince IS NOT NULL AND q.PriceChangedAt >= @PriceChangedSince))
	ORDER BY q.SubAccountUid, q.Country, q.OperatorId

END
