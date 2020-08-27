-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-07-07
-- Description:	Get Account pricing. Supports filtering by 1 country or by comma-separated list of SubAccounts

-- Updated:  Nathanael Hinay @ 2018-08-01
-- Changes: Factor in user-management selected sub-accounts

-- Updated:  Anton Shchekalov @ 2018-11-08
-- Changes: Switch to MAP routing data
-- =============================================
-- EXEC cp.Pricing_GetList @AccountUid = '0FC250D4-6182-E711-8143-02D85F55FCE7', @UserId = '8742E926-B3A8-47DF-A2C7-1B3DE6736915', @Country = 'PH', @SubAccountIds = 'airpay_1,beetalk_1'
-- EXEC cp.Pricing_GetList @AccountUid = '5C9250FE-E2E5-E611-813F-06B9B96CA965', @UserId = 'E0019C41-831F-4758-B655-473A8CCE7719', @Country = 'US', @SubAccountIds = 'INQUIRER-3dD6D_hq,INQUIRER-3dD6D_sd'
-- EXEC cp.Pricing_GetList @AccountUid = '5C9250FE-E2E5-E611-813F-06B9B96CA965', @UserId = 'E0019C41-831F-4758-B655-473A8CCE7719', @Country = 'RU', @SubAccountIds = null
CREATE PROCEDURE [cp].[Pricing_GetList]
	@AccountUid uniqueidentifier,
    @UserId uniqueidentifier,
	@Country char(2) = NULL,			-- optional filter
	@SubAccountIds varchar(1000) = NULL	-- optional filter, comma-separated list
WITH EXECUTE AS OWNER
AS
BEGIN
	
	---- get old AccountId
	--DECLARE @AccountId varchar(50)
	--SELECT @AccountId = a.AccountId FROM cp.Account a WHERE a.AccountUid = @AccountUid

	---- exit if @AccountId is not found
	--IF @AccountId IS NULL RETURN

	-- get flag of SubAccounts filtering by User
    DECLARE @LimitSubAccounts bit = 1
	SELECT @LimitSubAccounts = u.LimitSubAccounts
	FROM cp.[User] u
	WHERE u.AccountUid = @AccountUid AND u.UserId = @UserId

	-- get pricing
	DECLARE @Data AS TABLE (
		SubAccountUid int NOT NULL,
		Country char(2) NOT NULL,
		OperatorId int NULL,
		Currency char(3) NOT NULL,
		Price decimal(12,6) NOT NULL,
		RuleSrc CHAR(1) NOT NULL,
		MarginRate decimal(5,2) NULL,
		Cost decimal(12,6) NULL,
		UNIQUE CLUSTERED (SubAccountUid, Country, OperatorId)
	);

	-- convert csv-string @SubAccountIds to table
	DECLARE @SubAccountT TABLE (SubAccountUid int UNIQUE)
    INSERT INTO @SubAccountT (SubAccountUid) 
	SELECT sa.SubAccountUid
	FROM ms.SubAccount sa
	WHERE sa.AccountUid = @AccountUid
		AND sa.Active = 1 --AND sa.Deleted = 0
		-- filter by allowed subaccounts for user
		AND (@LimitSubAccounts = 0 OR (@LimitSubAccounts = 1 AND
			sa.SubAccountUid IN (SELECT SubAccountUid FROM cp.UserSubAccount usa WHERE usa.UserId = @UserId)
		))
		-- filter by SP input list
		AND (@SubAccountIds IS NULL OR (@SubAccountIds IS NOT NULL AND
			sa.SubAccountId IN (SELECT Item FROM dbo.SplitString(@SubAccountIds, ','))
		))

	-- exit if no access to subaccounts
	IF (SELECT COUNT(1) FROM @SubAccountT) = 0 RETURN

	-- Step 1: Insert price from Member rules
	INSERT INTO @Data (SubAccountUid, Country, OperatorId, Currency, Price, RuleSrc)
	SELECT 
		t.SubAccountUid, 
		cgcS.Country, 
		cgcS.OperatorId, 
		ISNULL(cgcS.PriceOriginalCurrency, cgcS.PriceCurrency) PriceCurrency,
		IIF(cgcS.PriceOriginalCurrency IS NULL, cgcS.Price, cgcS.PriceOriginal) Price,
		'M' AS RuleSrc
	FROM rt.CustomerGroupSubAccount cgs 
		INNER JOIN @SubAccountT t ON t.SubAccountUid = cgs.SubAccountUid AND cgs.Deleted = 0 -- filter subaccounts
		INNER JOIN rt.CustomerGroupCoverage cgcS ON 
			cgcS.CustomerGroupId = cgs.CustomerGroupId AND 
			cgcS.SubAccountUid = t.SubAccountUid AND
			cgcS.Deleted = 0 AND
			cgcS.TrafficCategory = 'DEF'
	WHERE ISNULL(@Country, cgcS.Country) = cgcS.Country

	-- Step 2: Insert price from Group rules
	INSERT INTO @Data (SubAccountUid, Country, OperatorId, Currency, Price, RuleSrc)
	SELECT 
		t.SubAccountUid, 
		cgcD.Country, 
		cgcD.OperatorId, 
		ISNULL(cgcD.PriceOriginalCurrency, cgcD.PriceCurrency) PriceCurrency,
		IIF(cgcD.PriceOriginalCurrency IS NULL, cgcD.Price, cgcD.PriceOriginal) Price,
		'G' AS RuleSrc
	FROM rt.CustomerGroupSubAccount cgs 
		INNER JOIN @SubAccountT t ON -- filter subaccounts
			t.SubAccountUid = cgs.SubAccountUid AND 
			cgs.Deleted = 0
		INNER JOIN rt.CustomerGroupCoverage cgcD ON 
			cgcD.CustomerGroupId = cgs.CustomerGroupId AND 
			cgcD.SubAccountUid IS NULL AND
			cgcD.Deleted = 0 AND 
			cgcD.TrafficCategory = 'DEF'
		LEFT JOIN @Data d ON 
			d.SubAccountUid = t.SubAccountUid AND 
			d.Country = cgcD.Country AND 
			ISNULL(d.OperatorId, 0) = ISNULL(cgcD.OperatorId, 0)
	WHERE 
		d.SubAccountUid IS NULL AND -- ignore existing key
		ISNULL(@Country, cgcD.Country) = cgcD.Country

	-- Step 3: Insert price from default pricing plan
	INSERT INTO @Data (SubAccountUid, Country, OperatorId, Currency, Price, MarginRate, Cost, RuleSrc)
	SELECT 
		t.SubAccountUid, 
		ppc.Country, 
		ppc.OperatorId, 
		ppc.Currency, 
		IIF(ppc.MarginRate IS NULL, ppc.Price, mno.CurrencyConverter(rpc.CostCalculated, rpc.CostCurrency, ppc.Currency, DEFAULT) * 100 / (100 - ppc.MarginRate)) Price,
		ppc.MarginRate,
		rpc.CostCalculated,
		'D' AS RuleSrc
	FROM rt.SubAccount_Default sa
		INNER JOIN @SubAccountT t ON -- filter subaccounts
			t.SubAccountUid = sa.SubAccountUid AND 
			sa.Deleted = 0
		INNER JOIN rt.PricingPlanCoverage ppc ON 
			ppc.PricingPlanId = sa.PricingPlanId_Default AND
			ppc.Deleted = 0
		INNER JOIN rt.RoutingPlanCoverage rpc ON	-- extra filtering by existing routing
			rpc.RoutingPlanId = sa.RoutingPlanId_Default AND
			rpc.Country = ppc.Country AND
			ISNULL(rpc.OperatorId, 0) = ISNULL(ppc.OperatorId, 0) AND	-- TODO: not all combinations covered here
			rpc.Deleted = 0 AND
			rpc.TrafficCategory = 'DEF'
		LEFT JOIN @Data d ON 
			d.SubAccountUid = t.SubAccountUid AND 
			d.Country = ppc.Country AND 
			ISNULL(d.OperatorId, 0) = ISNULL(ppc.OperatorId, 0)
	WHERE 
		d.SubAccountUid IS NULL AND -- ignore existing key	
		ISNULL(@Country, ppc.Country) = ppc.Country

	-- final report
	SELECT 
		sa.SubAccountId, 
		d.Country, 
		c.CountryName, 
		d.OperatorId, 
		ISNULL(o.OperatorName, 'Others') AS OperatorName, 
		o.MCC_List AS MCC, 
		o.MNC_List AS MNC, 
		d.Currency, 
		d.Price
		--, d.MarginRate, d.Cost, d.RuleSrc -- All troubleshooting columns
	FROM @Data d
		INNER JOIN mno.Country c ON d.Country = c.CountryISO2alpha
		LEFT JOIN mno.Operator o ON d.OperatorId = o.OperatorId
		INNER JOIN ms.SubAccount sa ON sa.SubAccountUid = d.SubAccountUid
	ORDER BY sa.SubAccountId, d.Country, d.OperatorId

END
