-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2020-03-12
-- SELECT * FROM [cp].[fnSubAccount_GetByUser] ('EEA85C04-9AB5-E711-8141-06B9B96CA965', '83169E71-E09D-429F-938D-0209019FC7A9', NULL, 1, NULL, NULL, NULL)
CREATE FUNCTION [cp].[fnSubAccount_GetByUser] (
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier,
	@SubAccountUid int = NULL,
	@Product_SMS bit = NULL,	-- NULL means ANY
	@Product_CA bit = NULL,		-- NULL means ANY
	@Product_VO bit = NULL,		-- NULL means ANY
	@Product_VI bit = NULL		-- for future use
)
RETURNS @SubAccounts TABLE (SubAccountUid int NOT NULL, SubAccountId varchar(50) NOT NULL)
AS
BEGIN

	-- read @LimitSubAccounts flag
	DECLARE @LimitSubAccounts bit = NULL
	SELECT @LimitSubAccounts = LimitSubAccounts 
	FROM cp.[User] WHERE UserId = @UserId AND AccountUid = @AccountUid

	-- security check: if no such user or @UserId is null
	IF @LimitSubAccounts IS NULL RETURN

	-- get list if subaccounts
	--DECLARE @ResultT TABLE (SubAccountUid int, SubAccountId varchar(50), Product_CA bit, [Default] bit, SmsVolume_1M int, UrlShortenerEnabled bit)

	INSERT INTO @SubAccounts (SubAccountUid, SubAccountId)
	SELECT 
        sa.SubAccountUid, sa.SubAccountId
	FROM ms.SubAccount sa
		--INNER JOIN cp.Account a ON a.AccountUid = sa.AccountUid
	WHERE 
		sa.AccountUid = @AccountUid 
		AND sa.Active = 1
		AND (@LimitSubAccounts = 0 OR 
			(@LimitSubAccounts = 1 AND
				EXISTS (SELECT 1 FROM cp.UserSubAccount us WHERE us.SubAccountUid = sa.SubAccountUid AND us.UserId = @UserId)))
		AND (@Product_SMS IS NULL OR sa.Product_SMS = @Product_SMS)
		AND (@Product_CA IS NULL OR sa.Product_CA = @Product_CA)
		AND (@Product_VO IS NULL OR sa.Product_VO = @Product_VO)
		--AND (@Product_VI IS NULL OR sa.Product_VI = @Product_VI)
		AND (sa.SubAccountUid = ISNULL(@SubAccountUid, sa.SubAccountUid))

	RETURN
	
END
