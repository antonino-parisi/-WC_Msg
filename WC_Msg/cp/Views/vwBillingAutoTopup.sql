CREATE VIEW [cp].[vwBillingAutoTopup]
AS
	SELECT TOP 100 
		b.*,
		a.AccountId,
		aw.Currency AS WalletCurrency,
		mno.CurrencyConverter(b.ChargeAmount, b.Currency, aw.Currency, DEFAULT) AS ChargeAmountInWalletCurrency,
		mno.CurrencyConverter(b.ThresholdAmount, b.Currency, aw.Currency, DEFAULT) AS ThresholdAmountInWalletCurrency,
		aw.Balance AS WalletBalance, 
		aw.OverdraftLimit AS WalletOverdraftLimit
	FROM cp.BillingAutoTopup b (NOLOCK)
		LEFT JOIN cp.Account a ON b.AccountUid = a.AccountUid
		LEFT JOIN cp.AccountWallet aw ON aw.AccountUid = a.AccountUid
