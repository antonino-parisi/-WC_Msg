
CREATE VIEW cp.vwAccountWallet
AS
	SELECT aw.AccountUid, a.AccountId, aw.Currency, aw.Balance, aw.OverdraftLimit
	FROM cp.AccountWallet aw (NOLOCK)
		INNER JOIN cp.Account a (NOLOCK) ON aw.AccountUid = a.AccountUid
