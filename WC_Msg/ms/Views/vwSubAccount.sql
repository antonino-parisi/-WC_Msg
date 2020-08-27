

CREATE VIEW [ms].[vwSubAccount] AS
	SELECT 
		sa.SubAccountId, 
		sa.SubAccountUid,
		a.AccountId, 
		a.AccountUid, a.AccountName, 
		UPPER(am.CustomerType) AS CustomerType,
		UPPER(am.BillingMode) AS BillingMode,
		am.Currency,
		ISNULL(m.Name, am.Manager) AS Manager,
		am.CompanyEntity AS CompanyEntity,
		m.BU,
		sa.Active,
		sa.CreatedAt,
		sa.Product_SMS,
		sa.Product_CA,
		sa.Product_VO
	FROM ms.SubAccount sa (NOLOCK)
		INNER JOIN cp.Account a (NOLOCK) ON sa.AccountUid = a.AccountUid
		LEFT JOIN ms.AccountMeta am (NOLOCK) ON am.AccountId = a.AccountId
		LEFT JOIN ms.AccountManager m (NOLOCK) ON am.ManagerId = m.ManagerId
	WHERE sa.Active = 1
