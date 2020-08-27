-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-07-17
-- Description:	Billing - Get current account balance
-- =============================================
-- EXEC cp.BillingBalance_Get @AccountUid = 'A0B6E463-BA28-E711-813F-06B9B96CA965'
CREATE PROCEDURE [cp].[BillingBalance_Get]
	@AccountUid uniqueidentifier
AS
BEGIN

	SELECT 
		aw.AccountUid,
		aw.Currency,
		aw.Balance AS CreditsAmount,
		aw.OverdraftLimit AS OverDraftAuthorized
	FROM cp.AccountWallet aw
	WHERE aw.AccountUid = @AccountUid

	-- old replaced version
	--SELECT 
	--	ca.AccountUid, 
	--	'EUR' as Currency,
	--	ac.CreditEuro AS CreditsAmount, 
	--	ISNULL(acs.overdraftAuthorized, 0) AS OverDraftAuthorized
	--FROM dbo.AccountCredit ac
	--	INNER JOIN cp.Account ca ON ca.AccountId = ac.AccountId
 --       LEFT JOIN dbo.AccountCredentials acs ON ac.AccountId = acs.AccountId
	--WHERE ca.AccountUid = @AccountUid

END
