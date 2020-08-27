
-- =============================================
-- Author:		<Raju>
-- Create date: ><17-04-2012>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckBalanceorOverdraftAlert]
	@AccountId VARCHAR(50)
		
	-- OUTPUT alerttype value
	-- 0 no alers
	-- 1 first balance alert
	-- 2 final balnce alert
	-- 3 first overdraft alert
	-- 4 final overdraft alert
	-- 5 Balance Topup process
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CreditBalanceEUR as decimal(19,7)
	DECLARE @FirstBalanceThreshold as decimal(14,6)
	DECLARE @FirstOverdraftThreshold as decimal(14,6)
	DECLARE @AlertType smallint	
	DECLARE @IsFirstBalanceAlert as bit
	DECLARE @IsFinalBalanceAlert as bit
	DECLARE @IsFirstOverdraftAlert as bit
	DECLARE @IsFinalOverdraftAlert as bit
	DECLARE @IsBalanceOrOverdraftAlert as bit
	DECLARE @WalletBalance decimal(19,7)
	DECLARE @WalletCurrency char(3)

	SELECT
		@CreditBalanceEUR = mno.CurrencyConverter(aw.Balance, aw.Currency, 'EUR', DEFAULT),
		@WalletBalance = aw.Balance,
		@WalletCurrency = aw.Currency
	FROM cp.AccountWallet aw (NOLOCK)
		INNER JOIN cp.Account a (NOLOCK) ON aw.AccountUid = a.AccountUid
	WHERE a.AccountId = @AccountId
   
	SELECT 
		@FirstBalanceThreshold		= FirstBalanceAlert,	-- in EUR yet
		@FirstOverdraftThreshold	= FirstOverDraftAlert,	-- in EUR yet
		@IsFirstBalanceAlert		= IsFirstBalanceAlerted,
		@IsFinalBalanceAlert		= IsBalanceZeroAlerted,
		@IsFirstOverdraftAlert		= IsFirstOverdraftalerted,
		@IsFinalOverdraftAlert		= IsOverdraftZeroalerted
	FROM dbo.AccountBalanceAlert
	WHERE AccountId = @AccountId
   
	SELECT TOP 1
		@IsBalanceOrOverdraftAlert = IsBalanceOrOverdraftAlert
	FROM dbo.Account
	WHERE AccountId = @AccountId
       
	SET @AlertType = -1;
 
	-- TOP UP triggering logic

	--IF EXISTS (
	--	-- check if balance topup conditions matched
	--	SELECT 1
	--	FROM cp.BillingAutoTopup b
	--		INNER JOIN cp.Account a ON a.AccountUid = b.AccountUid
	--	WHERE a.AccountId = @AccountId
	--		AND (b.SuspendCheckUntil IS NULL OR b.SuspendCheckUntil < GETUTCDATE())
	--		AND b.FailedAttempts < 3
	--		AND @CreditBalanceEUR <= b.ThresholdAmount
	--		AND b.Currency = 'EUR' --	only EUR is supported for now
	--)
	--BEGIN
	--	-- entering critical section to avoid collisions in multi-node enviropment 
	--	BEGIN TRY
	--		BEGIN TRANSACTION
				UPDATE b
				SET 
					SuspendCheckUntil = DATEADD(DAY, 1, GETUTCDATE()) /* 1 day from now */,
					LastPaymentStartedAt = GETUTCDATE()
				FROM cp.BillingAutoTopup b
					INNER JOIN cp.Account a ON a.AccountUid = b.AccountUid
				-- NOTE: same conditions exists in SP ms.BillingAutoTopup_Check
				WHERE a.AccountId = @AccountId
					AND (b.SuspendCheckUntil IS NULL OR b.SuspendCheckUntil < GETUTCDATE())
					-- it's ideal condition, but SP is called too frequent to have a luxery to convert so often
					--AND @CreditBalanceEUR <= mno.CurrencyConverter(b.ThresholdAmount, b.Currency, 'EUR', DEFAULT)
					-- simpler comparison with small limitation
					AND @WalletBalance <= b.ThresholdAmount AND b.Currency = @WalletCurrency
					-- we do 3 business retry attempts max
					AND b.FailedAttempts < 3
					-- if exists at least 1 active subaccount 
					AND EXISTS (SELECT TOP (1) 1 FROM ms.SubAccount sa WHERE sa.AccountUid = a.AccountUid AND sa.Active = 1)
					-- exclude Longtale & INCONC traffic type
					AND NOT EXISTS (SELECT TOP (1) 1 FROM ms.AccountMeta am WHERE am.AccountId = a.AccountId AND am.TrafficType = 'INCONC' and am.CustomerType = 'L')
					-- if not exists any Stripe payment in REVIEW state
					AND NOT EXISTS (SELECT TOP 1 1 FROM cp.BillingTransaction tr (NOLOCK) WHERE tr.AccountUid = a.AccountUid AND tr.TrxIntStatus = 'REVIEW' AND tr.PaymentProvider = 'stripe')
					
				IF @@ROWCOUNT > 0
				BEGIN
					SET @AlertType = 5
					GOTO STEP_FINAL
				END
	--		COMMIT TRANSACTION
	--	END TRY
	--	BEGIN CATCH
	--		ROLLBACK TRANSACTION
	--	END CATCH
	--END

---------------------------------------------------------------------------------------------------------------------------------------      
	IF (@IsBalanceOrOverdraftAlert = 1)
	BEGIN
		if(@FirstOverdraftThreshold is not null) --if null no need to check and send overdraft alert
		begin
			-- print 'Alert activated'
			--final overdraft alert
			IF (@CreditBalanceEUR < @FirstOverdraftThreshold)
			BEGIN
				SET @AlertType = IIF(@IsFinalOverdraftAlert = 0, 4 /* 'final overdraft alert' */, 0)
				
				GOTO STEP_FINAL
   
			END
			--------------------------------------------------------------------------------------------------------------------------------------------  
			--first overdraft alert
			else if(@CreditBalanceEUR = @FirstOverdraftThreshold)		  
			begin
   
				SET @AlertType = IIF(@IsFirstOverdraftAlert = 0, 3 /* 'first overdraft alert' */, 0)     
				GOTO STEP_FINAL
         
			END
		END		--not null check


		------------------------------------------------------------------------------------------------------------------------------------------------
		--final balance alert
		-- else  if(@CreditBalanceEUR=0 OR @CreditBalanceEUR<0)
		--else  if(@CreditBalanceEUR<=0)
		IF (@CreditBalanceEUR <= 0)
		BEGIN
   
			SET @AlertType = IIF(@IsFinalBalanceAlert = 0, 2 /* 'final balance alert' */, 0)
			GOTO STEP_FINAL
      
		END
   
		-------------------------------------------------------------------------------------------------------------------------------------------  
		--first balance alert
		--else  if(@CreditBalanceEUR=@FirstBalanceThreshold)
		else if(@CreditBalanceEUR <= @FirstBalanceThreshold)
		BEGIN
			SET @AlertType = IIF(@IsFirstBalanceAlert = 0, 1 /* 'first balance alert' */, 0)
			GOTO STEP_FINAL
		END
	END

	SET @AlertType = 0

STEP_FINAL:
	SELECT
		@CreditBalanceEUR AS CurrentBalance,
		@FirstBalanceThreshold AS BalanceThreshold,
		@FirstOverdraftThreshold AS OverdraftThreshold,
		@AlertType AS AlertType

	RETURN @AlertType
END
