-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-06-30
-- =============================================
CREATE PROCEDURE [cp].[AccountBilling_GetTokens]
	@UserId uniqueidentifier,	--filter
	@AccountId varchar(50)		--filter
AS
BEGIN

	SELECT 'STRIPE' AS BillingProvider, a.Billing_StripeId AS BillingProviderToken
	FROM cp.Account a
	WHERE a.AccountId = @AccountId AND a.Billing_StripeId IS NOT NULL
	UNION ALL
	SELECT 'PAYPAL' AS BillingProvider, a.Billing_PaypalId AS BillingProviderToken
	FROM cp.Account a
	WHERE a.AccountId = @AccountId AND a.Billing_PaypalId IS NOT NULL

END
