

-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2019-08-20
-- Delete subaccount
-- =============================================
-- EXEC [map].[SubAccount_Delete] @AccountUid='asdasdasd', @SubAccountId = 'abcd_hq'
CREATE PROCEDURE [map].[SubAccount_Delete]
	@AccountUid uniqueidentifier,
	@SubAccountId varchar(50)
AS
BEGIN

	DECLARE @SubAccountUid int
	
	SELECT @SubAccountUid = SubAccountUid
	FROM dbo.Account sa 
		INNER JOIN cp.Account a ON a.AccountId = sa.AccountId
	WHERE a.AccountUid = @AccountUid AND sa.SubAccountId = @SubAccountId
 
	IF @SubAccountUid IS NULL
	BEGIN
		THROW 51000, 'Can not find subaccount', 1;
	END
	
	-- delete subaccounts
	UPDATE sa 
	SET Active = 0, Deleted = 1, UpdatedAt = SYSUTCDATETIME()
	FROM dbo.Account sa 
	WHERE sa.SubAccountUid = @SubAccountUid

	-- remove MAP routing
	UPDATE rt.CustomerGroupSubAccount SET Deleted = 1
	WHERE SubAccountUid = @SubAccountUid AND Deleted = 0

	-- deactivate URL shortening config
	UPDATE ms.UrlShortenDomainSubAccount SET IsActive = 0
	WHERE SubAccountUid = @SubAccountUid AND IsActive = 1
		
END


grant execute on [map].[SubAccount_Delete] to role_team_ops2
