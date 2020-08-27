---
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-09-30
-- Description:	Load SubAccount configuration
-- =============================================
CREATE PROCEDURE [ms].[SubAccount_GetAll]
	@Host varchar(10) = NULL
AS
BEGIN

	DECLARE @ClusterGroupId varchar(50)
	SET @ClusterGroupId = ms.ClusterGroup_GetByHost(@Host)
​
	SELECT 
		a.AccountUid,
		a.AccountId,
		sa.SubAccountUid, 
		sa.SubAccountId,
		sa.Product_SMS AS SmsEnabled,
		sa.Product_CA AS ChatAppsEnabled,
		ISNULL(UPPER(am.CustomerType), 'L') AS CustomerType,
		ISNULL(UPPER(aw.Currency), 'EUR') AS Currency,		
		ISNULL(mtq.MtOutPriority, 10) AS MtOutPriority
	FROM ms.SubAccount sa
		INNER JOIN cp.Account a on sa.AccountUid = a.AccountUid
		LEFT JOIN ms.AccountMeta am ON a.AccountId = am.AccountId
		LEFT JOIN cp.AccountWallet aw ON a.AccountUid = aw.AccountUid
		LEFT JOIN (
			SELECT SubAccountUid, AVG(Priority) AS MtOutPriority
			FROM ms.QueueConfig
			WHERE QueueRole = 'MT' AND SubAccountUid IS NOT NULL 
				AND ClusterGroupId_Consumer IN (@ClusterGroupId, 'ANY')
			GROUP BY SubAccountUid) mtq 
		ON mtq.SubAccountUid = sa.SubAccountUid		
	WHERE sa.Active = 1 AND a.Deleted = 0
​
END
