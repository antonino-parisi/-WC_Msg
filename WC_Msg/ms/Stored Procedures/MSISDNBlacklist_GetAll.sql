---
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-11-08
-- Description:	Load all blacklisted MSISDNs
-- =============================================
CREATE PROCEDURE [ms].MSISDNBlacklist_GetAll
AS
BEGIN
	SELECT 
		b.FilterId, 
		b.AccountUid, 
		a.AccountId, 
		b.SubAccountUid, 
		sa.SubAccountId, 
		b.MSISDN
	FROM ms.MSISDNBlacklist b
		LEFT JOIN dbo.Account sa on sa.SubAccountUid = b.SubAccountUid
		LEFT JOIN cp.Account a on a.AccountUid = b.AccountUid
END
