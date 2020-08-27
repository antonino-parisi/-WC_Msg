-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-06-30
-- =============================================
CREATE PROCEDURE [cp].[AccountBilling_AttachPayment]
	@UserId uniqueidentifier,	--filter
	@AccountId varchar(50),		--filter
	@BillingProvider varchar(10),		-- 'STRIPE' or 'PAYPAL'
	@BillingProviderToken varchar(100)
AS
BEGIN

	IF @BillingProvider = 'STRIPE'
	BEGIN
		UPDATE a
		SET Billing_StripeId = @BillingProviderToken,
			UpdatedAt = GETUTCDATE()
		FROM cp.Account a
		WHERE a.AccountId = @AccountId AND EXISTS(SELECT 1 FROM cp.[User] WHERE UserId = @UserId AND AccountId = @AccountId)
	END
	ELSE IF @BillingProvider = 'PAYPAL'
	BEGIN
		UPDATE a
		SET Billing_PaypalId = @BillingProviderToken,
			UpdatedAt = GETUTCDATE()
		FROM cp.Account a
		WHERE a.AccountId = @AccountId AND EXISTS(SELECT 1 FROM cp.[User] WHERE UserId = @UserId AND AccountId = @AccountId)
	END
END
