
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-02
-- Description:	Returns ApiKeys
-- =============================================
CREATE PROCEDURE [smsapi].[AuthApi_GetApiKeys] 
AS
BEGIN
	SELECT a.ApiKey, a.AccountId, a.SubAccountId
	FROM ms.AuthApi_Active a
END
