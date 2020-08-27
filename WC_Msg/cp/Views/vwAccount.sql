
CREATE VIEW cp.vwAccount 
AS
	SELECT 
		a.AccountId, 
		a.AccountUid, 
		a.AccountName, 
		UPPER(am.CustomerType) AS CustomerType,
		UPPER(am.BillingMode) AS BillingMode,
		am.Currency,
		ISNULL(m.Name, am.Manager) AS Manager,
		am.CompanyEntity AS CompanyEntity,
		m.BU,
		a.CompanyName,
		a.Country,
		a.CompanyAddress,
		a.CreatedAt,
		a.UpdatedAt,
		a.Product_SMS,
		a.Product_CA,
		a.Product_VO,
		a.Product_VI,
		a.Deleted,
		a.DeletedAt
	FROM 
		cp.Account a (NOLOCK)
		LEFT JOIN ms.AccountMeta am (NOLOCK) ON am.AccountId = a.AccountId
		LEFT JOIN ms.AccountManager m (NOLOCK) ON am.ManagerId = m.ManagerId
		LEFT JOIN cp.AccountWallet AS aw (NOLOCK) ON a.AccountUid = aw.AccountUid
