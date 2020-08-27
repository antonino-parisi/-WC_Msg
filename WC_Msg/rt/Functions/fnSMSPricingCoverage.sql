-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2019-12-27
-- =============================================
-- SELECT * FROM rt.fnSMSPricingCoverage('3798', NULL, 1)
-- SELECT * FROM rt.fnSMSPricingCoverage('3798', 'SG,ID,PH', 0)
CREATE FUNCTION [rt].[fnSMSPricingCoverage] (
	@SubAccountUids VARCHAR(1000),		-- comma-separated list, NULL means nobody
	@Countries VARCHAR(100) = NULL,		-- comma-separated list, NULL means ANY
	@FinalPrice bit = 1
)
RETURNS @PricingCoverage TABLE   
(
	SubAccountUid INT NOT NULL,
	Country CHAR(2) NOT NULL,
	OperatorId INT NULL,
	PriceOriginalCurrency CHAR(3) NOT NULL,
	PriceOriginal DECIMAL(19,7) NOT NULL,
	PriceContractCurrency CHAR(3) NOT NULL,
	PriceContract DECIMAL(19,7) NOT NULL,
	PriceOriginalChangedAt datetime2(2) NOT NULL,
	RuleSrc VARCHAR(10) NOT NULL,
	RulePriority TINYINT NOT NULL,
	RowNum TINYINT NOT NULL,
	UNIQUE (SubAccountUid, Country, OperatorId, RulePriority)
)
AS
BEGIN
	-- debug
	--DECLARE @SubAccountUids varchar(100) = '3798'
	--DECLARE @Countries varchar(100) = NULL
	--DECLARE @Countries varchar(100) = 'RU, SG, ID'

	-- convert csv-string @Countries to table
	DECLARE @CountriesT TABLE (Country CHAR(2) UNIQUE)
	INSERT INTO @CountriesT (Country)
	SELECT RTRIM(LTRIM(Item)) FROM dbo.SplitString(@Countries, ',')
	UNION
	SELECT NULL WHERE @Countries IS NULL

	-- convert csv-string @SubAccountUids to table
	DECLARE @SubAccountT TABLE (SubAccountUid int PRIMARY KEY);
    INSERT INTO @SubAccountT (SubAccountUid)
	SELECT Item FROM dbo.SplitString_Int(@SubAccountUids, ',')

	-- main query
	-- RowPriority: 10 - highest, 0 - lowest
	INSERT INTO @PricingCoverage (
		SubAccountUid, Country, OperatorId, 
		PriceOriginalCurrency, PriceOriginal,
		PriceContractCurrency, PriceContract,
		PriceOriginalChangedAt, 
		RuleSrc, RulePriority, RowNum)
	SELECT 
		q.SubAccountUid, 
		q.Country, q.OperatorId, 
		q.PriceOriginalCurrency, q.PriceOriginal, 
		sa.Currency AS PriceContractCurrency,
		mno.CurrencyConverter(q.PriceOriginal, q.PriceOriginalCurrency, sa.Currency, DEFAULT) AS PriceContract,
		q.PriceOriginalChangedAt, 
		q.RuleSrc, q.RulePriority, q.RowNum
	FROM (
	SELECT 
		*,
		ROW_NUMBER () OVER (PARTITION BY SubAccountUid, Country, OperatorId ORDER BY RulePriority DESC) as RowNum
	FROM (
		SELECT 
			cgsa.SubAccountUid,
			cgc.Country, 
			cgc.OperatorId,
			ISNULL(cgc.PriceOriginalCurrency, cgc.PriceCurrency) AS PriceOriginalCurrency, 
			IIF(cgc.PriceOriginalCurrency IS NOT NULL, cgc.PriceOriginal, cgc.Price) AS PriceOriginal,
			cgc.PriceChangedAt AS PriceOriginalChangedAt,
			IIF(cgc.SubAccountUid IS NULL, 'G', 'M') AS RuleSrc,
			IIF(cgc.SubAccountUid IS NULL, 6, 10) AS RulePriority
		FROM @SubAccountT t -- filter subaccounts
			INNER JOIN rt.CustomerGroupSubAccount cgsa
				ON t.SubAccountUid = cgsa.SubAccountUid AND cgsa.Deleted = 0
			INNER JOIN rt.CustomerGroupCoverage cgc
				ON cgsa.CustomerGroupId = cgc.CustomerGroupId 
					AND (cgc.SubAccountUid IS NULL OR cgc.SubAccountUid = t.SubAccountUid)
					AND cgc.Deleted = 0 
					AND cgc.TrafficCategory = 'DEF'
			INNER JOIN @CountriesT c -- filter countries
				ON cgc.Country = c.Country OR c.Country IS NULL
			LEFT JOIN mno.Operator o
				ON cgc.Country = o.CountryISO2alpha
					AND cgc.OperatorId = o.OperatorId
		WHERE 
			-- remove inactive operators
			ISNULL(o.Active, 1) = 1
			
		-- Member or group plan, unwrap ANY Operator
		UNION ALL
		SELECT 
			cgsa.SubAccountUid,
			cgc.Country, 
			o.OperatorId,
			ISNULL(cgc.PriceOriginalCurrency, cgc.PriceCurrency) AS PriceOriginalCurrency, 
			IIF(cgc.PriceOriginalCurrency IS NOT NULL, cgc.PriceOriginal, cgc.Price) AS PriceOriginal,
			cgc.PriceChangedAt AS PriceOriginalChangedAt,
			IIF(cgc.SubAccountUid IS NULL, 'G-ANY', 'M-ANY') AS RuleSrc,
			IIF(cgc.SubAccountUid IS NULL, 4, 8) AS RulePriority
		FROM @SubAccountT t -- filter subaccounts 
			INNER JOIN rt.CustomerGroupSubAccount cgsa
				ON t.SubAccountUid = cgsa.SubAccountUid AND cgsa.Deleted = 0
			INNER JOIN rt.CustomerGroupCoverage cgc
				ON cgsa.CustomerGroupId = cgc.CustomerGroupId 
					AND (cgc.SubAccountUid IS NULL OR cgc.SubAccountUid = t.SubAccountUid)
					AND cgc.Deleted = 0 
					AND cgc.TrafficCategory = 'DEF'
			INNER JOIN mno.Operator o 
				ON cgc.Country = o.CountryISO2alpha
					AND cgc.OperatorId IS NULL -- only for operator ANY
					AND o.Active = 1
			INNER JOIN @CountriesT c -- filter countries
				ON cgc.Country = c.Country OR c.Country IS NULL

		-- Default pricing plan of subaccount (later must be moved as defaul plan of Customer Group)
		UNION ALL
		SELECT 
			sa.SubAccountUid,
			ppc.Country,
			o.OperatorId,
			ppc.Currency AS PriceOriginalCurrency,
			IIF(ppc.MarginRate IS NULL, ppc.Price, mno.CurrencyConverter(rpc.CostCalculated, rpc.CostCurrency, ppc.Currency, DEFAULT) * 100 / (100 - ppc.MarginRate)) AS PriceOriginal,
			ppc.UpdatedAt AS PriceOriginalChangedAt, -- simplified
			'D' AS RuleSrc,
			IIF(ppc.OperatorId IS NULL, 0, 2) AS RulePriority
		FROM @SubAccountT t -- filter subaccounts
			INNER JOIN rt.SubAccount_Default sa ON
				t.SubAccountUid = sa.SubAccountUid AND sa.Deleted = 0
			INNER JOIN rt.PricingPlanCoverage ppc ON 
				ppc.PricingPlanId = sa.PricingPlanId_Default AND
				ppc.Deleted = 0
			INNER JOIN @CountriesT c -- filter countries
				ON ppc.Country = c.Country OR c.Country IS NULL
			INNER JOIN mno.Operator o 
				ON ppc.Country = o.CountryISO2alpha
					AND (ppc.OperatorId = o.OperatorId OR ppc.OperatorId IS NULL /* for ANY Opearator */)
					AND o.Active = 1
			INNER JOIN rt.RoutingPlanCoverage rpc ON
					rpc.RoutingPlanId = sa.RoutingPlanId_Default AND
					rpc.Country = ppc.Country AND
					ISNULL(rpc.OperatorId,0) = ISNULL(ppc.OperatorId,0) AND
					rpc.Deleted = 0 AND
					rpc.TrafficCategory = 'DEF'
		) t
	) q
		--INNER JOIN mno.Country c ON q.Country = c.CountryISO2alpha
		--LEFT JOIN mno.Operator o ON q.OperatorId = o.OperatorId
		INNER JOIN (
			SELECT sa.SubAccountUid, ISNULL(am.Currency, 'EUR') AS Currency
			FROM ms.SubAccount sa
				INNER JOIN cp.Account a ON sa.AccountUid = a.AccountUid
				LEFT JOIN ms.AccountMeta am ON a.AccountId = am.AccountId
		) sa ON q.SubAccountUid = sa.SubAccountUid
	WHERE
		q.PriceOriginal > 0 AND
		((@FinalPrice = 1 AND q.RowNum = 1) -- price rule with highest priority
		OR (@FinalPrice = 0))

	RETURN
END
