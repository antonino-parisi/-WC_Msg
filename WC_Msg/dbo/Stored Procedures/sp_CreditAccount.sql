-- =============================================
-- Author:		Raju
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreditAccount] 
	@AccountId NVARCHAR(50),
	@Value DECIMAL(14,5),	-- Amount to ADD
	@Currency char(3) = 'EUR',
	@Comment NVARCHAR(50) = NULL
AS
BEGIN
	
	IF (@Comment IS  NULL)
	BEGIN
		SET @Comment = 'Credit Account of ' + @Currency + ' ' + CAST(@Value AS NVARCHAR(50) )
	END

	-- update balance in deprecated Wallet v1
	DECLARE @AmountEUR decimal(14, 5) = mno.CurrencyConverter(@Value, @Currency, 'EUR', DEFAULT);

	IF EXISTS (SELECT 1 FROM dbo.AccountCredit WHERE @AccountId=AccountId )
    BEGIN
		UPDATE dbo.AccountCredit SET creditEuro = creditEuro + @AmountEUR, ValidCredit = 1 WHERE @AccountId = AccountId;
	END
	ELSE
	BEGIN
		-- i don't believe that this path is ever possible
		INSERT dbo.AccountCredit (AccountId, CreditEuro, ValidCredit) VALUES (@AccountId , @AmountEUR, 1);
	END

	UPDATE dbo.AccountCredentials SET OutOfCredit = 0  WHERE @AccountId = AccountId;
	
	INSERT dbo.AccountRecord ("Date", AccountId, Record, Value, Currency)  
	VALUES (SYSUTCDATETIME(), @AccountId , @Comment, @Value, @Currency);

END
