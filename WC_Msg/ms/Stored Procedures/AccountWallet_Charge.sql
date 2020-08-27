-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2020-05-09
-- Description:	Charge (decrease) Account Wallet from MSG Core
-- =============================================
-- EXEC ms.AccountWallet_Charge @AccountUid = 'xxxx', @Currency = 'USD', @Amount = 1 -- deduct 1 USD
CREATE PROCEDURE [ms].[AccountWallet_Charge]
	@AccountUid uniqueidentifier, 
	@Currency char(3), 
	@Amount decimal(19, 7)	-- Value to DEDUCT
AS
BEGIN

	BEGIN TRY

		-- main operation to deduct balance by @Value
		UPDATE cp.AccountWallet
		  SET Balance -= mno.CurrencyConverter(@Amount, @Currency, Currency, DEFAULT)
		WHERE AccountUid = @AccountUid;

		-- Edge case / Double protection in case if Account wasn't initialized properly
		IF @@rowcount = 0
		BEGIN

			INSERT INTO cp.AccountWalletFailedTrx (EventTime, AccountUid, Currency, Amount, Host, Message)
			VALUES(SYSUTCDATETIME(), @AccountUid, @Currency, @Amount, HOST_NAME(), 'V2: Missing record');

		END;

	END TRY
	BEGIN CATCH
		-- log failed transaction
		INSERT INTO cp.AccountWalletFailedTrx (EventTime, AccountUid, Currency, Amount, Host, Message)
		VALUES(SYSUTCDATETIME(), @AccountUid, @Currency, @Amount, HOST_NAME(), 'V2: ' + ERROR_MESSAGE());
	END CATCH;


	---- TODO: remove after migration phase end
	-- legacy wallet update
	DECLARE @AmountEUR decimal(14, 5) = mno.CurrencyConverter(@Amount, @Currency, 'EUR', DEFAULT);
	DECLARE @AccountId varchar(50);
	SELECT @AccountId = AccountId FROM cp.Account WHERE AccountUid = @AccountUid;

	BEGIN TRY
		UPDATE [dbo].[AccountCredit] 
		SET  ValidCredit = 1, creditEuro = CASE WHEN (CreditEuro>@AmountEUR) THEN CreditEuro-@AmountEUR END  /* missing ELSE condition -> attempt to write NULL -> trigger constraint exception */
		WHERE ( AccountId = @AccountId);
		
	END TRY	
	BEGIN CATCH
		
		DECLARE @ValidCredit bit
		SELECT @ValidCredit = aw.ValidBalance FROM cp.AccountWallet aw (NOLOCK) WHERE aw.AccountUid = @AccountUid

		UPDATE [dbo].[AccountCredit] 
		SET 
			ValidCredit = @ValidCredit,
			creditEuro = creditEuro - @AmountEUR 
		WHERE (@AccountId = AccountId);
		
	END CATCH

	-- legacy balance alert checks
	DECLARE @AlertType smallint
	EXEC @AlertType = dbo.usp_CheckBalanceorOverdraftAlert @AccountId = @AccountId
	RETURN @AlertType
END;
