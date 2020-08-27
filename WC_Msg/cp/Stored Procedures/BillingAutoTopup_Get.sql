-- =============================================
-- Author:		Nathanael Hinay
-- Create date: 2018-10-17
-- Description:	AutoPayment get details for account.
--				SP used by both CP API and CP auto-payment function
-- =============================================
-- Modify:      Alexjander Bacalso
-- Modify Date: 2018-11-30
-- Description: Get all details for check-card-expiry service
-- =============================================
-- EXEC cp.AutoPayment_Get @AccountUid = 'A0B6E463-BA28-E711-813F-06B9B96CA965'
CREATE PROCEDURE [cp].[BillingAutoTopup_Get]
	@AccountUid uniqueidentifier = NULL,	-- main way to specify Account
	@AccountId varchar(50) = NULL			-- alternative way to specify Account
AS
BEGIN
	
	IF (@AccountUid IS NULL)
		SELECT @AccountUid = AccountUid FROM cp.Account WHERE AccountId = @AccountId

    SELECT 
        b.AccountUid,
        b.Currency,
        b.ChargeAmount,
        b.ThresholdAmount,
        b.StripeSourceId,
        b.CustomerStripeId,
        b.CreatedAt,
        b.UpdatedBy,
        b.FailedAttempts,
        b.LastPaymentStartedAt,
        b.SuspendCheckUntil
    FROM cp.BillingAutoTopup b
    WHERE AccountUid = @AccountUid;
END
