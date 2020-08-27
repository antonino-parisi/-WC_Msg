


-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-09-25
-- Description:	List of allowed IP ranges to access API
-- =============================================
CREATE PROCEDURE [smsapi].[AuthApi_IPWhitelist]
AS
BEGIN
	SELECT sa.SubAccountUid, sa.SubAccountId, aip.CIDR
	FROM ms.AuthIP aip
		INNER JOIN cp.Account a ON aip.AccountUid = a.AccountUid
		INNER JOIN dbo.Account sa ON sa.AccountId = a.AccountId
	WHERE aip.SubAccountUid IS NULL
	UNION
	SELECT sa.SubAccountUid, sa.SubAccountId, aip.CIDR
	FROM ms.AuthIP aip
		--INNER JOIN cp.Account a ON aip.AccountUid = a.AccountUid
		INNER JOIN dbo.Account sa ON sa.SubAccountUid = aip.SubAccountUid
	WHERE aip.SubAccountUid IS NOT NULL
END
