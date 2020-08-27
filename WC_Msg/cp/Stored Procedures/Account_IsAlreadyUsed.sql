
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-11-11
-- =============================================
-- EXEC cp.Account_IsAlreadyUsed @AccountName='asdfasdf'
CREATE PROCEDURE cp.Account_IsAlreadyUsed
	@AccountName varchar(40)
AS
BEGIN

	SELECT COUNT(AccountName) AS AlreadyUsed 
	FROM cp.Account
	WHERE (AccountName = @AccountName OR AccountId = @AccountName)
END

