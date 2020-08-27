-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2020-03-04
-- Description:	AccountId renaming by Ops
-- =============================================
-- EXEC [cp].[Account_Rename_Ops] @AccountID_Old = 'kevinidexpress_1bBB7', @AccountID_New = 'idexpress_1bBB7'
CREATE PROCEDURE [cp].[Account_Rename_Ops]
	@AccountID_Old varchar(50),
	@AccountID_New varchar(50)
AS
BEGIN

	BEGIN TRY
	BEGIN TRANSACTION
	
		UPDATE cp.Account				SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE cp.UserActivation		SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE dbo.Account				SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE dbo.AccountBalanceAlert	SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE dbo.AccountBillingInformation SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE dbo.AccountCredentials	SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE dbo.AccountCredit		SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE dbo.AccountCreditSnapshot SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE dbo.AccountRecord		SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE dbo.AccountSMSLogReports	SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE dbo.CustomerRouting		SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE dbo.Invoices				SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE dbo.PlanRouting			SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE dbo.Users				SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE ms.AccountMeta			SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE ms.AccountProductMeta	SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE ms.AccountBlackList		SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE ms.AuthApi				SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE optimus.MessageBodyPrefixRules SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE optimus.SenderMaskingRules SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE ipm.PricingPlanChannel	SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE ipm.PricingPlanSubscription SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old
		UPDATE rt.RoutingView_Customer	SET AccountId = @AccountID_New WHERE AccountId = @AccountID_Old

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 		

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
		
		THROW;
	END CATCH
END
