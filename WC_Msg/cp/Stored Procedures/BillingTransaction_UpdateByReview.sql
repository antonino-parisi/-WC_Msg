-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-07-07
-- Description:	BillingTransaction - Result of manual operation review by Ops team
-- possible values: @Status = 'APPROVE' | 'REJECT'
-- =============================================
--	UPDATE cp.BillingTransaction SET TrxIntStatus = 'REVIEW' WHERE TrxId = 1
-- EXEC cp.BillingTransaction_UpdateByReview @TrxId = 1, @Status = 'APPROVE'
CREATE PROCEDURE [cp].[BillingTransaction_UpdateByReview]
	@TrxId int,
	--@AccountUid uniqueidentifier,
	@Status varchar(7)
AS
BEGIN

	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE @TrxIntStatus varchar(7)
		DECLARE @AccountUid uniqueidentifier
		DECLARE @Amount decimal(18,6)
		DECLARE @Currency char(3)

		-- read current values
		SELECT @TrxIntStatus = TrxIntStatus, @Amount = Amount, @Currency = Currency, @AccountUid = AccountUid
		FROM cp.BillingTransaction
		WHERE TrxId = @TrxId --AND AccountUid = @AccountUid

		-- Validation step
		DECLARE @msg NVARCHAR(2048)
		
		IF (@TrxIntStatus <> 'REVIEW')
		BEGIN
			SET @msg = 'Operation is not allowed for TrxIntStatus=' + @TrxIntStatus + '. Allowed to modify only ''REVIEW''';
			THROW 51000, @msg, 1; 
		END

		--SET @TrxIntStatus = 'SUCCESS'

		IF @STATUS = 'APPROVE'
		BEGIN
			SET @TrxIntStatus = 'SUCCESS'

			-- remove trial limit
			DELETE FROM ms.MsisdnWhitelist
			WHERE AccountUid = @AccountUid -- AND SubAccountUid IS NULL ???

			-- resume auto re-charge feature if it exists
			UPDATE cp.BillingAutoTopup
			SET FailedAttempts = 0,
				SuspendCheckUntil = sysutcdatetime(),
				UpdatedAt = sysutcdatetime()
			WHERE AccountUid = @AccountUid;

			PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Auto-topup feature resumed (if it configured)'

			-- Execute credit topup
			DECLARE @Comment VARCHAR(50)
			SET @Comment = '[CPv2] Credit Account for ' + @Currency + ' ' + CAST(@Amount AS VARCHAR(50))
				
			EXEC cp.AccountWallet_Change @AccountUid = @AccountUid, @Amount = @Amount, @Currency = @Currency, @Comment = @Comment
				
			UPDATE dbo.Invoices SET Status = 'PAID', DatePaid = GETUTCDATE() 
			WHERE refCode = 'CPv2:' + CAST(@TrxId AS VARCHAR(10))
			
			PRINT dbo.CURRENT_TIMESTAMP_STR() + @Comment

		END
		ELSE IF (@Status = 'REJECT')
		BEGIN
			SET @TrxIntStatus = 'FAILED'

			UPDATE dbo.Invoices SET Status = 'REJECTED' WHERE refCode = 'CPv2:' + CAST(@TrxId AS VARCHAR(10))
		END
		ELSE
		-- for unknown status types
		BEGIN
			SET @msg = 'Operation is not supported for Status=' + @Status;
			THROW 51002, @msg, 1; 
		END

		-- change internal status of transaction
		UPDATE cp.BillingTransaction 
		SET 
			TrxIntStatus = @TrxIntStatus, 
			UpdatedAt = GETUTCDATE()
		WHERE TrxId = @TrxId AND AccountUid = @AccountUid

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
