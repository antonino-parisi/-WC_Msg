-- =============================================
-- Author:		Nathanael Hinay
-- Create date: 2018-10-17
-- Description:	AutoPayment set details for account
-- =============================================
-- EXEC cp.AutoPayment_Add @AccountUd = 'AcmeCorp-0aA4C'
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 12/11/2018  Rebecca  Added CustomerStripeId column
-- 27/11/2018  Nathanael Added UpdatedBy to columns
CREATE PROCEDURE [cp].[BillingAutoTopup_Add]
	@AccountUid UNIQUEIDENTIFIER,
    @UpdatedBy UNIQUEIDENTIFIER,
    @Currency CHAR(3) = 'EUR',
    @ChargeAmount DECIMAL(14, 5) = 0,
    @ThresholdAmount DECIMAL(14, 5) = 0,
    @StripeSourceId VARCHAR(50) = NULL,
	@CustomerStripeId VARCHAR(50) = NULL
AS
BEGIN

    INSERT INTO cp.[BillingAutoTopup]
            (AccountUid,
            Currency,
            ChargeAmount,
            ThresholdAmount,
            StripeSourceId,
			CustomerStripeId,
			CreatedAt,
            UpdatedBy)
    VALUES
        (@AccountUid, @Currency, @ChargeAmount, @ThresholdAmount, @StripeSourceId, @CustomerStripeId, SYSUTCDATETIME(), @UpdatedBy) ;

END
