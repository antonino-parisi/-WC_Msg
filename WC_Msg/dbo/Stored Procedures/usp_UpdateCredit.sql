
-- =============================================
-- Author:		<Raj,Gupta>
-- Create date: <18-04-2011>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateCredit]
	@AccountId VARCHAR(50),
	@value DECIMAL(14,5)	-- in EUR
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @credit DECIMAL(14,5);
	DECLARE @overdraftAuthorized DECIMAL(14,5);
  	
	BEGIN TRY
		UPDATE [dbo].[AccountCredit] 
		SET  ValidCredit = 1, creditEuro = CASE WHEN (CreditEuro>@value) THEN CreditEuro-@value END  
		WHERE ( AccountId= @AccountId); 

	END TRY	
	BEGIN CATCH
		SET  @overdraftAuthorized = (SELECT overdraftAuthorized FROM [dbo].AccountCredentials WHERE (@AccountId = AccountId) );
		SET  @credit = (SELECT CreditEuro FROM [dbo].[AccountCredit] WHERE (@AccountId = AccountId))
		IF ( ( @credit - @value )  > (   @overdraftAuthorized ))
		BEGIN
			UPDATE [dbo].[AccountCredit] SET ValidCredit = 1, creditEuro = creditEuro - @value WHERE (@AccountId = AccountId) ;  
		END
		ELSE
		BEGIN
			UPDATE [dbo].[AccountCredit] SET ValidCredit = 0, creditEuro = creditEuro - @value WHERE (@AccountId = AccountId) ;
		END
	END CATCH


	---- WALLET V2 for Migration phase
	BEGIN TRY

		DECLARE @AccountUid uniqueidentifier
		SELECT TOP 1 @AccountUid = AccountUid FROM cp.Account a (NOLOCK) WHERE a.AccountId = @AccountId

		-- main operation to deduct balance by @Value
		UPDATE cp.AccountWallet
		  SET Balance -= mno.CurrencyConverter(@value, 'EUR', Currency, DEFAULT)
		WHERE AccountUid = @AccountUid;

	END TRY
	BEGIN CATCH
		-- log failed transaction
		INSERT INTO cp.AccountWalletFailedTrx (EventTime, AccountUid, Currency, Amount, Host, Message)
		VALUES(SYSUTCDATETIME(), @AccountUid, 'EUR', @value, HOST_NAME(), 'V1:' + ERROR_MESSAGE());
	END CATCH;
END
