-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-07-28
-- =============================================
-- EXEC cp.Billing_AddCredits @AccountUid = '639250FE-E2E5-E611-813F-06B9B96CA965', @Amount = 0.1, @Currency = 'EUR'
CREATE PROCEDURE [cp].[Billing_AddCredits]
	@AccountUid UNIQUEIDENTIFIER,
	@Amount decimal(18,6),
	@Currency char(3),
	@Comment NVARCHAR(50) = NULL
AS
BEGIN

	IF @Currency <> 'EUR'
		THROW 51001, 'Only EUR currency is supported now', 1; 

	DECLARE @AccountId varchar(50)
	DECLARE @AmountEUR decimal(18,6)
		
	SELECT @AccountId = AccountId FROM cp.Account WHERE AccountUid = @AccountUid
	IF @AccountId IS NULL
		THROW 51002, 'AccountId does not exists', 1; 

	SET @AmountEUR = mno.CurrencyConverter(@Amount, @Currency, 'EUR', DEFAULT)
	IF @Comment IS NULL
		SET @Comment = '[CARD] Credit Account for EUR ' + CAST(@AmountEUR AS NVARCHAR(50))
	
	EXEC dbo.sp_CreditAccount @AccountId, @AmountEUR, @Comment
END
