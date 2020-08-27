-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-23
-- =============================================
-- Updated By:  Nathanael Hinay
-- Date Updated: 2018-06-22
-- add us.UserId in the where condition
-- =============================================
-- EXEC [cp].[SubAccount_GetByUser] @AccountUid = 'EEA85C04-9AB5-E711-8141-06B9B96CA965', @UserId = '83169E71-E09D-429F-938D-0209019FC7A9'
CREATE PROCEDURE [cp].[SubAccount_GetByUser]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier,
	@Product_SMS bit = NULL,	-- NULL means ANY
	@Product_CA bit = NULL,		-- NULL means ANY
	@Product_VO bit = NULL,		-- NULL means ANY
	@Product_VI bit = NULL		-- for future use
AS
BEGIN

	-- read @LimitSubAccounts flag
	DECLARE @LimitSubAccounts bit
	SELECT @LimitSubAccounts = LimitSubAccounts FROM cp.[User] WHERE UserId = @UserId

	-- get list if subaccounts
	--DECLARE @ResultT TABLE (SubAccountUid int, SubAccountId varchar(50), Product_CA bit, [Default] bit, SmsVolume_1M int, UrlShortenerEnabled bit)

	--INSERT INTO @ResultT (SubAccountUid, SubAccountId, Product_CA, [Default], SmsVolume_1M, UrlShortenerEnabled)
	SELECT 
        sa.SubAccountUid,
		sa.SubAccountId,
        sa.Product_SMS,
		sa.Product_CA,
		sa.Product_VO,
		0 AS Product_VI,	-- for future use
		IIF(ROW_NUMBER() OVER(ORDER BY sa.SubAccountUid ASC) = 1, 1, 0) AS [Default], -- First subaccount is default. Some obsolete logic for SMS Sender
		ISNULL(ss.SmsVolume_1M,0) AS SmsVolume_1M, 
		ISNULL(shrt.IsActive, 0) AS UrlShortenerEnabled
	FROM ms.SubAccount sa
		INNER JOIN cp.Account cpa ON cpa.AccountUid = sa.AccountUid
		LEFT JOIN cp.SubAccountStat ss ON sa.SubAccountUid = ss.SubAccountUid
		LEFT JOIN ms.UrlShortenDomainSubAccount shrt ON sa.SubAccountUid = shrt.SubAccountUid
	WHERE 
		cpa.AccountUid = @AccountUid 
		AND sa.Active = 1 --AND a.Deleted = 0
		AND (@LimitSubAccounts = 0 OR 
			(@LimitSubAccounts = 1 AND
				EXISTS (SELECT 1 FROM cp.UserSubAccount us WHERE us.SubAccountUid = sa.SubAccountUid AND us.UserId = @UserId)))
		AND (@Product_SMS IS NULL OR sa.Product_SMS = @Product_SMS)
		AND (@Product_CA IS NULL OR sa.Product_CA = @Product_CA)
		AND (@Product_VO IS NULL OR sa.Product_VO = @Product_VO)
		--AND (@Product_VI IS NULL OR sa.Product_VI = @Product_VI)


	---- Setting one default subaccount for SMS Sender
	--IF NOT EXISTS (SELECT 1 FROM @ResultT WHERE [Default] = 1)
	--	UPDATE TOP (1) @ResultT SET [Default] = 1 WHERE SubAccountId LIKE '%hq'

	--IF NOT EXISTS (SELECT 1 FROM @ResultT WHERE [Default] = 1)
	--	UPDATE TOP (1) @ResultT SET [Default] = 1

	--SELECT SubAccountUid, SubAccountId, Product_CA, [Default], SmsVolume_1M, UrlShortenerEnabled FROM @ResultT
END
