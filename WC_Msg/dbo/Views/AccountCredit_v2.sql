CREATE VIEW dbo.AccountCredit_v2
--WITH ENCRYPTION, SCHEMABINDING, VIEW_METADATA
AS
	SELECT 
		a.AccountId, 
		mno.CurrencyConverter(aw.Balance, aw.Currency, 'EUR', DEFAULT) AS CreditEuro, 
		CAST(IIF(aw.Balance >= aw.OverdraftLimit, 1, 0) AS bit) AS ValidCredit
	FROM cp.AccountWallet aw (NOLOCK)
		INNER JOIN cp.Account a (NOLOCK) ON aw.AccountUid = a.AccountUid
