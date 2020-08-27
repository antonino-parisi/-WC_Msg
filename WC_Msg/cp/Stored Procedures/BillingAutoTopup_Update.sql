CREATE PROCEDURE [cp].[BillingAutoTopup_Update]
	@AccountUid UNIQUEIDENTIFIER,
    @Currency        CHAR(3) = NULL,
    @ChargeAmount    DECIMAL (14, 5) = NULL,
    @ThresholdAmount DECIMAL (14, 5) = NULL,
    @StripeSourceId  VARCHAR(50) = NULL,
	@CustomerStripeId VARCHAR(50) = NULL,
    @UpdatedBy UNIQUEIDENTIFIER = NULL, 
    @FailedAttempts TINYINT = NULL, 
    @SuspendCheckUntil DATETIME2(2) = NULL
AS
BEGIN
-- =============================================
-- Author:		Rebecca
-- Create date: 2018-10-31
-- Description:	Update of cp.BillingAutoTopup
-- =============================================
-- EXEC cp.BillingAutoTopup_Update @AccountUid = 'A0B6E463-BA28-E711-813F-06B9B96CA965',
--				@Currency='EUR', @ChargeAmount=10, @ThresholdAmount=5, @StripeSourceId='0983-9384-3854-9393',
--				@UpdatedBy='Customer Portal', @FailedAttempts=1, @SuspendCheckUntil='2018-11-02 00:00'
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 12/11/2018  Rebecca  Added CustomerStripeId column

	UPDATE cp.BillingAutoTopup
	SET Currency = ISNULL(@Currency, Currency),
		ChargeAmount = ISNULL(@ChargeAmount, ChargeAmount),
		ThresholdAmount = ISNULL(@ThresholdAmount, ThresholdAmount),
		StripeSourceId = ISNULL(@StripeSourceId, StripeSourceId),
		CustomerStripeId = ISNULL(@CustomerStripeId, CustomerStripeId),
		UpdatedBy = ISNULL(@UpdatedBy, UpdatedBy),
		FailedAttempts = ISNULL(@FailedAttempts, FailedAttempts),
		SuspendCheckUntil  = ISNULL(@SuspendCheckUntil, SuspendCheckUntil),
		UpdatedAt = sysutcdatetime()
	WHERE AccountUid = @AccountUid ;

END
