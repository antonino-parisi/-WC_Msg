
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-11-29
-- Description:	Identify accounts who reached low balance level and trigger auto-payment for them.
--				MS executes this check in background every 15-30 mins
--				More frequent check happens in SP [dbo].[usp_CheckBalanceorOverdraftAlert]
-- =============================================
CREATE PROCEDURE [ms].[BillingAutoTopup_Check]
AS
BEGIN

	DECLARE @Accounts TABLE (AccountId varchar(50))

	UPDATE b
	SET 
		SuspendCheckUntil = DATEADD(DAY, 1, GETUTCDATE()) /* 1 day from now */,
		LastPaymentStartedAt = GETUTCDATE()
	OUTPUT a.AccountId INTO @Accounts (AccountId)
	--SELECT *
	FROM cp.BillingAutoTopup b
		INNER JOIN cp.Account a ON a.AccountUid = b.AccountUid AND a.Deleted = 0
		INNER JOIN cp.AccountWallet aw ON aw.AccountUid = a.AccountUid
	WHERE
		-- NOTE: same conditions exists in SP dbo.usp_CheckBalanceorOverdraftAlert
		(b.SuspendCheckUntil IS NULL OR b.SuspendCheckUntil < GETUTCDATE())
		AND aw.Balance <= mno.CurrencyConverter(b.ThresholdAmount, b.Currency, aw.Currency, DEFAULT)
		-- we do 3 business retry attempts max
		AND b.FailedAttempts < 3
		-- if exists at least 1 active subaccount 
		AND EXISTS (SELECT TOP (1) 1 FROM ms.SubAccount sa WHERE sa.AccountUid = a.AccountUid AND sa.Active = 1)
		-- exclude Longtale & INCONC traffic type
		AND NOT EXISTS (SELECT TOP (1) 1 FROM ms.AccountMeta am WHERE am.AccountId = a.AccountId AND am.TrafficType = 'INCONC' and am.CustomerType = 'L')
		-- if not exists any Stripe payment in REVIEW state
		AND NOT EXISTS (SELECT TOP 1 1 FROM cp.BillingTransaction tr (NOLOCK) WHERE tr.AccountUid = a.AccountUid AND tr.TrxIntStatus = 'REVIEW' AND tr.PaymentProvider = 'stripe')
					
	SELECT AccountId FROM @Accounts
END
