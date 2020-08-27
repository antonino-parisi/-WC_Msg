---
-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2019-01-16
-- Description:	Load all whitelisted MSISDNs
-- =============================================
CREATE PROCEDURE [ms].[MSISDNWhitelist_GetAll]
AS
BEGIN
	SELECT 
		w.SubAccountUid, 
		w.Msisdn
	FROM ms.MsisdnWhitelist w
	WHERE w.SubAccountUid IS NOT NULL
	UNION ALL
	SELECT 
		sa.SubAccountUid, 
		w.MSISDN
	FROM ms.MsisdnWhitelist w
		JOIN cp.Account a on a.AccountUid = w.AccountUid AND w.SubAccountUid IS NULL
		JOIN dbo.Account sa on sa.Accountid = a.Accountid
END
