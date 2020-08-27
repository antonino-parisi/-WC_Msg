
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-07-07
-- Description:	BillingTransaction - update Status and AmountWithoutFee
-- =============================================
-- EXEC cp.BillingTransaction_UpdateExtStatus @TrxId = 1, @AccountUid = '47E0E533-14F0-E611-813F-06B9B96CA965', @TrxExtStatus = 'FAILED', @AmountWithoutFee = NULL
CREATE PROCEDURE [cp].[BillingTransaction_UpdateExtStatus]
	@TrxId int,
	@AccountUid uniqueidentifier,
	@TrxExtStatus varchar(7),
	@AmountWithoutFee real = NULL, -- deprecated, do not set
	@PaymentRef varchar(50) = NULL, -- column will not be updated if value is null
	@Description nvarchar(500) = NULL -- column will not be updated if value is null
AS
BEGIN

	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE @TrxIntStatus varchar(7)
		DECLARE @Amount decimal(18,6)
		DECLARE @Currency char(3)

		-- read current values
		SELECT @TrxIntStatus = TrxExtStatus, @Amount = Amount, @Currency = Currency
		FROM [cp].[BillingTransaction]
		WHERE TrxId = @TrxId AND AccountUid = @AccountUid AND Type = 'CARD'

		-- Validation step
		DECLARE @msg NVARCHAR(2048)
		
		IF (@TrxIntStatus <> 'UNDEF')
		BEGIN
			SET @msg = 'Operation is not allowed for TrxIntStatus=' + ISNULL(@TrxIntStatus, '<NULL>') + '. Allowed to modify only ''UNDEF''';
			THROW 51000, @msg, 1; 
		END

		IF (@Amount IS NULL OR @AmountWithoutFee > @Amount)
		BEGIN
			SET @msg = 'Operation is not allowed. AmountWithoutFee=' + cast(@AmountWithoutFee as varchar(20))+ ' is higher than Amount=' + cast(@Amount as varchar(20));
			THROW 51001, @msg, 1;
		END

		-- For successful payment
		IF (@TrxExtStatus = 'SUCCESS')
		BEGIN
			--remove FreeCreditsOffer (even if it was't used)
			UPDATE cp.Account SET FreeCreditsOffer = 0 WHERE AccountUid = @AccountUid AND FreeCreditsOffer > 0

			-- Identify, if payment should go for human review or not
			DECLARE @ToReview bit; 
			EXEC cp.BillingTransaction_IsReviewNeeded @AccountUid = @AccountUid, @TrxId = @TrxId, @ToReview = @ToReview OUTPUT
	
			IF (@ToReview = 1)
			BEGIN
				-- payment needs review
				SET @TrxIntStatus = 'REVIEW'

				--suspend auto re-charges for N=1 month while waiting for manual review of transaction
				UPDATE cp.BillingAutoTopup
				SET FailedAttempts = 0,
					SuspendCheckUntil = DATEADD(DAY, 30, SYSUTCDATETIME()),
					UpdatedAt = SYSUTCDATETIME()
				WHERE AccountUid = @AccountUid ;

			END
			ELSE IF (@ToReview = 0)
			BEGIN
				SET @TrxIntStatus = 'SUCCESS'

				-- resume auto re-charge feature
				UPDATE cp.BillingAutoTopup
				SET FailedAttempts = 0,
					SuspendCheckUntil = NULL,
					UpdatedAt = SYSUTCDATETIME()
				WHERE AccountUid = @AccountUid;

				-- remove trial limit
				DELETE FROM ms.MsisdnWhitelist
				WHERE AccountUid = @AccountUid -- AND SubAccountUid IS NULL ???

				-- Execute credit topup
				DECLARE @Comment VARCHAR(50)
				SET @Comment = '[CP] Credit Account for ' + @Currency + ' ' + CAST(@Amount AS VARCHAR(50) )
				
				EXEC cp.AccountWallet_Change @AccountUid = @AccountUid, @Amount = @Amount, @Currency = @Currency, @Comment = @Comment
				
				UPDATE dbo.Invoices SET Status = 'PAID', DatePaid = GETUTCDATE(), ExtraInfo = @PaymentRef  
				WHERE refCode = 'CP:' + CAST(@TrxId AS VARCHAR(10))
				
				PRINT dbo.CURRENT_TIMESTAMP_STR() + @Comment
			END
		END
		ELSE IF (@TrxExtStatus = 'FAILED')
			SET @TrxIntStatus = 'FAILED'
		-- for unknown status types
		ELSE
		BEGIN
			SET @msg = 'Operation is not allowed for TrxExtStatus=' + @TrxExtStatus;
			THROW 51002, @msg, 1; 
		END

		UPDATE [cp].[BillingTransaction]
		SET TrxExtStatus = @TrxExtStatus, TrxIntStatus = @TrxIntStatus,
			--AmountWithoutFee = ISNULL(@AmountWithoutFee, AmountWithoutFee),
			PaymentRef = ISNULL(@PaymentRef, PaymentRef),
			Description = ISNULL(@Description, Description),
			UpdatedAt = GETUTCDATE()
		WHERE TrxId = @TrxId

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction status updated to ' + @TrxIntStatus

		-- result set
		SELECT @TrxId as TrxId, @TrxIntStatus AS TrxIntStatus

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 		

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
		
		THROW;
	END CATCH

END
