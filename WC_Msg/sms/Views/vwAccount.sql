
CREATE VIEW [sms].[vwAccount] AS
	SELECT 
		a.AccountUid, a.AccountId, a.AccountName, 
		ISNULL(UPPER(am.CustomerType), 'L') AS CustomerType,
		am.BillingMode, 
		m.BU,
		ISNULL(m.Name, am.Manager) AS Manager,
		a.Country AS CompanyLocation,
		am.CompanyEntity,
		aw.Balance AS CreditBalance,		-- rename if no app dependency
		aw.OverdraftLimit AS CreditLimit	-- rename if no app dependency
	FROM cp.Account a (NOLOCK) 
		LEFT JOIN ms.AccountMeta am (NOLOCK) ON am.AccountId = a.AccountId
		LEFT JOIN ms.AccountManager m (NOLOCK) ON am.ManagerId = m.ManagerId
		LEFT JOIN cp.AccountWallet aw (NOLOCK) ON a.AccountUid = aw.AccountUid
