
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2020-05-09
-- Description:	Topup AccountWallet
-- =============================================
CREATE PROCEDURE [cp].[AccountWallet_Change]
	@AccountUid uniqueidentifier,
	@Currency CHAR(3),
	@Amount DECIMAL(19,7),	-- Amount to ADD
	@Comment NVARCHAR(50) = NULL
AS
BEGIN
	
	-- update balance in Wallet v2
	UPDATE aw SET Balance += mno.CurrencyConverter(@Amount, @Currency, aw.Currency, DEFAULT)
	FROM cp.AccountWallet aw
	WHERE aw.AccountUid = @AccountUid

	-- legacy wallet update
	IF (@Comment IS  NULL)
		SET @Comment = '[CARD] Credit Account for ' + @Currency + ' ' + CAST(@Amount AS VARCHAR(50))
	
	DECLARE @AccountId varchar(50);
	SELECT @AccountId = AccountId FROM cp.Account WHERE AccountUid = @AccountUid;
	IF @AccountId IS NULL
		THROW 51002, 'AccountId does not exists', 1; 

	EXEC dbo.sp_CreditAccount @AccountId = @AccountId, @Value = @Amount, @Currency = @Currency, @Comment = @Comment

END
