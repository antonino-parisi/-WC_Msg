-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-07-07
-- Description:	BillingTransaction - business logic, if human review is needed for transaction
-- =============================================
-- DECLARE @ToReview bit; EXEC cp.BillingTransaction_IsReviewNeeded @AccountUid = '499250FE-E2E5-E611-813F-06B9B96CA965', @TrxId = 123, @ToReview = @ToReview OUTPUT; SELECT @ToReview AS ToReview
CREATE PROC [cp].[BillingTransaction_IsReviewNeeded]
	@AccountUid uniqueidentifier,
	@TrxId int = NULL,
	@ToReview bit OUTPUT
AS
BEGIN
	SET @ToReview = 1

	-- moderation for all customer types with TrafficType IN ('INCONC', 'SCAM')
	IF EXISTS (
		SELECT 1
		FROM ms.AccountMeta am
			INNER JOIN cp.Account a ON am.AccountId = a.AccountId
		WHERE a.AccountUid = @AccountUid AND (
				/*am.CustomerType IN (/*'W',*/ 'E')
				OR (am.CustomerType IN ('L', 'W') AND*/ 
				am.TrafficType IS NULL OR am.TrafficType NOT IN ('INCONC', 'SCAM') /* conclusive traffic type from LONG-TAIL and W customers  */
			)
	) SET @ToReview = 0

	---- for testing purposes
	--IF EXISTS (SELECT 1 FROM cp.BillingTransaction WHERE TrxId = @TrxId AND Amount = 777) SET @ToReview = 0
		
END
