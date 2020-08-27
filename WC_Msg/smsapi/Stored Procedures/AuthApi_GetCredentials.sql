​
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-04-30
-- Description:	Returns account passwords
-- =============================================
--	EXEC [smsapi].[AuthApi_GetCredentials]
CREATE PROCEDURE [smsapi].[AuthApi_GetCredentials] 
AS
BEGIN
	SELECT ac.AccountId, ac.[Password]
	FROM dbo.AccountCredentials ac
END
