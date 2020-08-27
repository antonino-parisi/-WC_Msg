-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-07-07
-- Description:	Get Account pricing. Supports filtering by 1 country or by comma-separated list of SubAccounts

-- Updated:  Nathanael Hinay @ 2018-08-01
-- Changes: Factor in user-management selected sub-accounts

-- Updated:  Anton Shchekalov @ 2018-11-08
-- Changes: Switch to MAP routing data
-- =============================================
-- EXEC cp.Pricing_GetList_v2 @AccountUid = '0FC250D4-6182-E711-8143-02D85F55FCE7', @UserId = '8742E926-B3A8-47DF-A2C7-1B3DE6736915', @Country = 'PH', @SubAccountIds = 'airpay_1,beetalk_1'
-- EXEC cp.Pricing_GetList_v2 @AccountUid = '5C9250FE-E2E5-E611-813F-06B9B96CA965', @UserId = 'E0019C41-831F-4758-B655-473A8CCE7719', @Country = 'US', @SubAccountIds = 'INQUIRER-3dD6D_hq,INQUIRER-3dD6D_sd'
-- EXEC cp.Pricing_GetList_v2 @AccountUid = '5C9250FE-E2E5-E611-813F-06B9B96CA965', @UserId = 'E0019C41-831F-4758-B655-473A8CCE7719', @Country = 'RU', @SubAccountIds = 'PEPSKWIK05-7rRF4_hq4,PEPSKWIK05-7rRF4_lc7'
CREATE PROCEDURE [cp].[Pricing_GetList_v2]
	@AccountUid uniqueidentifier,
    @UserId uniqueidentifier,
	@Country char(2) = NULL,			-- optional filter
	@SubAccountIds varchar(1000) = NULL	-- optional filter, comma-separated list
AS
BEGIN

	-- get scope of permitted Subaccounts
	DECLARE @SubAccountT TABLE (SubAccountUid int UNIQUE)
    INSERT INTO @SubAccountT (SubAccountUid) 
	SELECT su.SubAccountUid
	FROM cp.fnSubAccount_GetByUser (@AccountUid, @UserId, NULL, 1, NULL, NULL, NULL) su 
	WHERE 
		-- filter by SP input list
		(@SubAccountIds IS NULL OR (@SubAccountIds IS NOT NULL AND
			-- convert csv-string @SubAccountIds to table
			su.SubAccountId IN (SELECT Item FROM dbo.SplitString(@SubAccountIds, ','))
		))

	-- exit if no access to subaccounts
	IF (SELECT COUNT(1) FROM @SubAccountT) = 0 RETURN

	-- convert SubAccountUids back to comma-separated string
	DECLARE @SubAccountUids VARCHAR(250) = ''
	SELECT @SubAccountUids = @SubAccountUids + CAST(SubAccountUid AS varchar(10)) + ',' FROM @SubAccountT

	-- final report
	SELECT 
		sa.SubAccountId, 
		d.Country, 
		c.CountryName, 
		d.OperatorId, 
		ISNULL(o.OperatorName, 'Others') AS OperatorName, 
		o.MCC_List AS MCC, 
		o.MNC_List AS MNC, 
		d.PriceOriginalCurrency AS Currency, 
		d.PriceOriginal AS Price
	FROM rt.fnSMSPricingCoverage(@SubAccountUids, @Country, 1) d
		INNER JOIN mno.Country c ON d.Country = c.CountryISO2alpha
		LEFT JOIN mno.Operator o ON d.OperatorId = o.OperatorId
		INNER JOIN ms.SubAccount sa ON sa.SubAccountUid = d.SubAccountUid
	ORDER BY sa.SubAccountId, d.Country, d.OperatorId

END
