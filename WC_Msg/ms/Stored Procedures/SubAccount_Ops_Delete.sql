
-- =============================================
-- Change History
-- =============================================
-- Date        Author               Description 
-- ----------  -------------------  ------------------------------------
-- 2020-07-10	Anton Shchekalov
--	Sample calls
--	EXEC [ms].[SubAccount_Ops_Delete] @AccountId = 'abcf', @SubAccountId = 'abcdef'
-- =============================================
CREATE PROCEDURE [ms].[SubAccount_Ops_Delete]
	@AccountId VARCHAR(50),
	@SubAccountId VARCHAR(50) = NULL, -- One of values is required
	@SubAccountUid int = NULL		-- One of values is required
AS
BEGIN

	--DECLARE @SubAccountUid INT
	IF @SubAccountUid IS NULL 
		SELECT @SubAccountUid = sa.SubAccountUid FROM ms.SubAccount AS sa WHERE sa.SubAccountId = @SubAccountId

	IF NOT EXISTS (SELECT 1 FROM ms.vwSubAccount WHERE AccountId = @AccountId AND SubAccountUid = @SubAccountUid)
		THROW 51000, 'Subaccount is not found', 1;

	-- set SubAccountId
	SELECT @SubAccountId = sa.SubAccountId FROM ms.SubAccount AS sa WHERE sa.SubAccountUid = @SubAccountUid

	BEGIN TRY
	BEGIN TRANSACTION
		
		-- if there is stats for SubAccount, we don't hard delete record, only mark as deleted.
		IF EXISTS (
			SELECT TOP (1) 1 
			FROM sms.StatSmsLogDaily s
			WHERE s.SubAccountUid = @SubAccountUid
		) OR EXISTS (SELECT 1 FROM dbo.Account AS a WHERE a.Deleted = 0 AND a.SubAccountUid =  @SubAccountUid)
		BEGIN
			
			UPDATE a SET Deleted = 1, UpdatedAt = SYSUTCDATETIME()
			FROM dbo.Account a
			WHERE a.SubAccountUid = @SubAccountUid

			UPDATE sa SET Active = 0, UpdatedAt = SYSUTCDATETIME()
			FROM ms.SubAccount sa 
			WHERE sa.SubAccountUid = @SubAccountUid
			PRINT 'Only soft delete executed. Subaccount was in use already.'

			UPDATE ms.AuthSmpp SET DeletedAt = SYSUTCDATETIME() WHERE SubAccountId = @SubAccountId

			UPDATE optimus.SenderMaskingRules SET DELETED = 1 WHERE SubAccountId = @SubAccountId
			PRINT dbo.Log_ROWCOUNT('Soft delete from optimus.SenderMaskingRules done')

			DELETE optimus.MessageBodyPrefixRules WHERE SubAccountId = @SubAccountId
			PRINT dbo.Log_ROWCOUNT('Hard delete from optimus.MessageBodyPrefixRules done')

			DELETE FROM PlanRouting WHERE SubAccountId = @SubAccountId 

		END
		ELSE
		BEGIN
			
			DELETE FROM dbo.AccountMTConfig WHERE SubAccountId = @SubAccountId
			DELETE FROM a FROM dbo.Account a WHERE a.SubAccountUid = @SubAccountUid AND a.Deleted = 1
			DELETE FROM sa FROM ms.SubAccount sa WHERE sa.SubAccountUid = @SubAccountUid AND sa.Active = 0
			DELETE FROM ms.AuthSmpp WHERE SubAccountId = @SubAccountId
			DELETE FROM optimus.SenderMaskingRules WHERE SubAccountId = @SubAccountId

			PRINT 'Hard delete executed';
		END

	COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
      
		THROW;
	END CATCH
END
