CREATE PROCEDURE [cp].[BillingAutoTopup_Delete]
	@AccountUid UNIQUEIDENTIFIER,
    @StripeSourceId VARCHAR(50)=NULL
AS
BEGIN
-- =============================================
-- Author:		Nathanael Hinay
-- Create date: 2018-10-17
-- Description:	AutoPayment set details for account
-- =============================================
-- EXEC cp.AutoPayment_Add @AccountUid = 'A0B6E463-BA28-E711-813F-06B9B96CA965'

    DELETE FROM cp.BillingAutoTopup
    WHERE AccountUid = @AccountUid
		AND (@StripeSourceId IS NULL OR StripeSourceId = @StripeSourceId );
END
