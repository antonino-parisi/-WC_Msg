

-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-05-08
-- Delete account
-- =============================================
-- EXEC [map].[Account_Delete] @AccountUid=
CREATE PROCEDURE [map].[Account_Delete]
	@AccountUid uniqueidentifier
AS
BEGIN

	DECLARE @DeletedUsers TABLE (Login nvarchar(255))

	-- delete account users
	UPDATE cp.[User]
	SET UserStatus = 'D' /* deleted */, UpdatedAt = SYSUTCDATETIME(), DeletedAt = SYSUTCDATETIME()
	OUTPUT inserted.Login INTO @DeletedUsers
	WHERE AccountUid = @AccountUid AND UserStatus IN ('A', 'B')

	UPDATE u SET Active = 0
	FROM dbo.Users u INNER JOIN @DeletedUsers d ON u.Username = d.Login

	-- delete subaccounts
	UPDATE sa 
	SET Deleted = 1, UpdatedAt = SYSUTCDATETIME()
	FROM dbo.Account sa 
		INNER JOIN cp.Account a ON a.AccountId = sa.AccountId
	WHERE a.AccountUid = @AccountUid

	-- delete account
	UPDATE a 
	SET Deleted = 1, DeletedAt = SYSUTCDATETIME()
	FROM cp.Account a
	WHERE a.AccountUid = @AccountUid

END
