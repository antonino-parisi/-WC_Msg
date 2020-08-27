
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2019-10-07
-- Description:	Returns ApiKeys for Voice product
-- =============================================
CREATE PROCEDURE [ms].[AuthApi_LoadApiKeyVoice]
AS
BEGIN
	SELECT apikey.ApiKey, a.AccountUid, sa.SubAccountUid AS SubAccountUid_Filter
	FROM ms.AuthApi apikey
		INNER JOIN cp.Account a ON a.AccountId = apikey.AccountId
		LEFT JOIN ms.SubAccount sa ON apikey.SubAccountId = sa.SubAccountId
	WHERE apikey.Active = 1 AND a.Deleted = 0 AND a.Product_VO = 1
END
