-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-04-23
-- Description:	Pricelist for customer
-- =============================================
-- EXEC map.[Pricing_GetPricingBySubAccount_v3] @SubAccountUid = 18363, @PriceChangedSince = '2020-06-16'
-- SELECT TOP 10 * FROM dbo.Account AS a ORDER BY a.PriceNotifiedAt DESC
CREATE PROCEDURE [map].[Pricing_GetPricingBySubAccount_v3]
	@SubAccountUid int,
	@PriceChangedSince smalldatetime = NULL	-- optional filter
AS
BEGIN

	-- debug
	--DECLARE @SubAccountUid int = 6801
	DECLARE @SubAccountUids varchar(100)
	SELECT @SubAccountUids = CAST(@SubAccountUid as varchar(100)) 

	SELECT 
		q.SubAccountUid, 
		sa.SubAccountId,
		q.Country, c.CountryName,
		q.OperatorId, 
		ISNULL(o.OperatorName, 'Others') AS OperatorName, 
		ISNULL(o.MCC_List, c.MCCDefault) AS MCC_List, o.MNC_List,
		q.PriceOriginalCurrency AS Currency,	-- new currency
		q.PriceOriginal AS Price,				-- new price
		hs.PriceCurrency AS CurrencyOld,		-- old currency
		hs.Price AS PriceOld,					-- old price
		CASE
			WHEN q.PriceOriginalCurrency <> hs.PriceCurrency THEN 'Currency change'
			WHEN q.PriceOriginal < hs.Price THEN 'Decrease'
			WHEN q.PriceOriginal > hs.Price THEN 'Increase'
			WHEN hs.Price IS NULL THEN 'New coverage'
			ELSE ''
		END AS Notes,
		q.PriceOriginalChangedAt AS PriceChangedAt
	FROM rt.fnSMSPricingCoverage(@SubAccountUids, NULL, 1) q
		INNER JOIN ms.SubAccount AS sa ON q.SubAccountUid = sa.SubAccountUid
		INNER JOIN mno.Country c ON q.Country = c.CountryISO2alpha
		LEFT JOIN mno.Operator o ON q.OperatorId = o.OperatorId
		OUTER APPLY (
			SELECT TOP 1 * 
			FROM rt.CustomerCoverageHistory AS h
			WHERE 
				q.SubAccountUid = h.SubAccountUid 
				AND q.Country = h.Country 
				AND ISNULL(q.OperatorId, 0) = ISNULL(h.OperatorId, 0)
			ORDER BY Id DESC) hs
	WHERE
		sa.Active = 1
		AND q.PriceOriginal > 0 -- MAP-406: EXCLUDE zero-prices
		AND (@PriceChangedSince IS NULL OR (@PriceChangedSince IS NOT NULL AND q.PriceOriginalChangedAt >= @PriceChangedSince))
	ORDER BY q.SubAccountUid, q.Country, q.OperatorId

END
