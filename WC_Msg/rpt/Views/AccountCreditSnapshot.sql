CREATE VIEW rpt.AccountCreditSnapshot
AS
	SELECT 
		CAST(acs.EventTime as date) EventTime, 
		acs.AccountId, 
		acs.CreditEuro,
		ac.OverdraftAuthorized, 
		mng.Name AS Manager, 
		am.CustomerType,
		mno.CurrencyConverter(1, 'EUR', 'SGD', acs.EventTime) [EUR to SGD]
	FROM 
		dbo.AccountCreditSnapshot acs WITH (NOLOCK)
		INNER JOIN dbo.AccountCredentials ac WITH (NOLOCK)
			ON acs.AccountId = ac.AccountId
		INNER JOIN ms.AccountMeta am
			ON acs.AccountId = am.AccountId
		INNER JOIN ms.AccountManager mng
			ON am.ManagerId = mng.ManagerId
	WHERE 
		acs.EventTime >= CAST(SYSUTCDATETIME() AS DATE)