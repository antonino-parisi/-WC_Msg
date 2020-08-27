-- =============================================
-- Author: Anton Shchekalov
-- Description:	
-- Changes: 
--	2020-08-27 - Created
-- EXEC cp.AccountWallet_Ops_AlignCurrency @AccountId = 'praksmol31_5fFCD'
-- =============================================
CREATE PROCEDURE cp.AccountWallet_Ops_AlignCurrency
	@AccountId VARCHAR(50)
AS BEGIN

	DECLARE @CurrencyChange AS TABLE (
			AccountUid uniqueidentifier NOT NULL, 
			AccountId varchar(50) NOT NULL, 
			CurrencyNew char(3) NOT NULL
		)

	INSERT INTO @CurrencyChange (AccountUid, AccountId, CurrencyNew)
	SELECT a.AccountUid, a.AccountId, a.Currency
	FROM cp.vwAccount a
		INNER JOIN cp.AccountWallet AS aw ON a.AccountUid = aw.AccountUid
	WHERE a.AccountId = @AccountId AND a.Currency IS NOT NULL AND a.Currency <> aw.Currency;

	IF @@rowcount = 0
	BEGIN
		PRINT 'Exit. Account not found or currency in Wallet is identical.'
		RETURN -2
	END

	--SELECT *
	--FROM cp.vwAccountWallet AS aw
	--	INNER JOIN @CurrencyChange t ON aw.AccountUid = t.AccountUid

	BEGIN TRY
    	BEGIN TRANSACTION
    		
		-- update account info
		UPDATE a SET AccountCurrency = t.CurrencyNew
		FROM cp.Account a
			INNER JOIN @CurrencyChange t ON a.AccountUid = t.AccountUid
		WHERE t.CurrencyNew <> a.AccountCurrency

		-- update wallet
		DECLARE @AccountWalletNew AS TABLE (
			AccountId varchar(50),
			BalanceOld decimal(19,7),
			BalanceNew decimal(19,7),
			CurrencyOld char(3),
			CurrencyNew char(3)
		);

		INSERT INTO cp.AccountWalletSnapshot (EventTime, AccountUid, Currency, Balance, OverdraftLimit)
		SELECT SYSUTCDATETIME() AS EventTime, aw.AccountUid, Currency, Balance, OverdraftLimit
		FROM cp.AccountWallet aw (NOLOCK)
			INNER JOIN @CurrencyChange t ON aw.AccountUid = t.AccountUid
		
		-- update wallet
		UPDATE aw SET
			Currency = t.CurrencyNew,
			Balance = mno.CurrencyConverter(aw.Balance, aw.Currency, t.CurrencyNew, DEFAULT),
			OverdraftLimit = mno.CurrencyConverter(aw.OverdraftLimit, aw.Currency, t.CurrencyNew, DEFAULT)
		OUTPUT t.AccountId, DELETED.Balance, DELETED.Currency, INSERTED.Balance, INSERTED.Currency
		INTO @AccountWalletNew (AccountId, BalanceOld, CurrencyOld, BalanceNew, CurrencyNew)
		FROM cp.AccountWallet aw
			INNER JOIN @CurrencyChange t ON aw.AccountUid = t.AccountUid
		WHERE t.CurrencyNew <> aw.Currency

		-- log wallet currency change
		INSERT INTO dbo.AccountRecord (Date, AccountId, Record, Currency, Value, UpdatedBy, UpdatedAt)
		SELECT 
			SYSUTCDATETIME(), 
			awt.AccountId,
			'Currency changed. Prev wallet balance = ' + awt.CurrencyOld + CAST(awt.BalanceOld AS varchar(20)), 
			awt.CurrencyNew, awt.BalanceNew, 
			NULL /* it can't be a CP user */, SYSUTCDATETIME()
		FROM @AccountWalletNew awt

		-- update auto topups
		UPDATE bat SET
			Currency = t.CurrencyNew,
			ChargeAmount = mno.CurrencyConverter(bat.ChargeAmount, bat.Currency, t.CurrencyNew, DEFAULT),
			ThresholdAmount = mno.CurrencyConverter(bat.ThresholdAmount, bat.Currency, t.CurrencyNew, DEFAULT)
		FROM cp.BillingAutoTopup bat
			INNER JOIN @CurrencyChange t ON bat.AccountUid = t.AccountUid
		WHERE t.CurrencyNew <> bat.Currency

		SELECT *
		FROM cp.vwAccountWallet AS aw
			INNER JOIN @CurrencyChange t ON aw.AccountUid = t.AccountUid

    	COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    	PRINT 
    		'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
      		', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
      		', State ' + CONVERT(varchar(5), ERROR_STATE()) +
      		', Line ' + CONVERT(varchar(5), ERROR_LINE())
      
    	PRINT ERROR_MESSAGE();
      
      	IF XACT_STATE() <> 0 BEGIN
    		ROLLBACK TRANSACTION
      	END

		RETURN -1;
    END CATCH;

	RETURN 0;
END
