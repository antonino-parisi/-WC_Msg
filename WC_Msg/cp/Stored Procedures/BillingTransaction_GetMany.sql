-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-07-07
-- Description:	BillingTransaction - get list
-- =============================================
-- EXEC cp.BillingTransaction_GetMany ....
CREATE PROCEDURE [cp].[BillingTransaction_GetMany]
	@AccountUid uniqueidentifier,
	@Offset int = 0,
	@Limit int = 200,
	@OutputTotals bit = 0
AS
BEGIN

	SELECT 
		TrxId, 
		CreatedAt, 
		TrxIntStatus, 
		InvoiceNumber, 
		Currency, 
		Amount, 
		PaymentProvider, 
		PaymentRef, 
		PaymentError
	FROM [cp].[BillingTransaction] t
	WHERE t.AccountUid = @AccountUid AND Type = 'CARD'
	ORDER BY t.TrxId DESC
	OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY

	-- Get totals
	IF @OutputTotals = 1
		SELECT COUNT(1) AS TotalRecords
		FROM [cp].[BillingTransaction] t
		WHERE t.AccountUid = @AccountUid AND Type = 'CARD'

END
