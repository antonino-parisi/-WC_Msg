
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-01-10
-- Description:	Auth Api Key - get all keys for account
-- =============================================
-- EXEC cp.AuthApi_GetByAccountId @AccountId='traveloka'
CREATE PROCEDURE [cp].[AuthApi_GetByAccountId]
	@AccountId varchar(50)
AS
BEGIN
	
	-- TODO: Add ApiKey column encryption

	SELECT 
		a.ApiKey, 
		a.Name, 
		a.Active, 
		a.CreatedAt AS CreatedTime, 
		a.LastUsedAt AS LastUsedTime
	FROM ms.AuthApi a
	WHERE a.AccountId = @AccountId
		AND a.DeletedAt IS NULL
END

