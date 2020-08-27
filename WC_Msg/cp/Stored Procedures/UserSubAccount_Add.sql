-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-06-04
-- =============================================
-- EXEC cp.[UserSubAccount_Add] @UserId='...'
CREATE PROCEDURE [cp].[UserSubAccount_Add]
	--@AccountUid uniqueidentifier,
	@UserId uniqueidentifier,
	@SubAccountId varchar(50)
AS
BEGIN

	INSERT INTO cp.UserSubAccount(UserId, SubAccountUid)
	SELECT u.UserId, sa.SubAccountUid
	FROM ms.SubAccount sa
		INNER JOIN cp.Account a ON a.AccountUid = sa.AccountUId
		INNER JOIN cp.[User] u ON u.AccountUid = a.AccountUid
	WHERE 
		u.UserId = @UserId
		AND sa.SubAccountId = @SubAccountId
		--AND a.AccountUid = @AccountUid 
END
