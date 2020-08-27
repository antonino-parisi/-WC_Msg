
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-03-23
-- Description:	Create snapshot of account balances
-- =============================================
CREATE PROCEDURE [dbo].[job_AccountCredit_DoSnapshot]
AS
BEGIN
	SET NOCOUNT ON;

	-- Legacy table
	INSERT INTO dbo.AccountCreditSnapshot (AccountId, CreditEuro, EventTime)
	SELECT AccountId, CreditEuro, SYSUTCDATETIME() AS EventTime 
	FROM dbo.AccountCredit (NOLOCK)
	WHERE CreditEuro <> 0

	DELETE FROM dbo.AccountCreditSnapshot 
	WHERE EventTime < DATEADD(MONTH, -24, SYSUTCDATETIME())

	-- new table
	INSERT INTO cp.AccountWalletSnapshot (EventTime, AccountUid, Currency, Balance, OverdraftLimit)
	SELECT SYSUTCDATETIME() AS EventTime, AccountUid, Currency, Balance, OverdraftLimit
	FROM cp.AccountWallet aw (NOLOCK)
	WHERE aw.Balance <> 0 OR aw.OverdraftLimit <> 0

	DELETE FROM cp.AccountWalletSnapshot
	WHERE EventTime < DATEADD(MONTH, -24, SYSUTCDATETIME())
END
