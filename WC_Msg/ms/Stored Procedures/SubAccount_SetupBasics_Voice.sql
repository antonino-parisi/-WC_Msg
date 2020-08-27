
-- =============================================
-- Change History
-- =============================================
-- Date        Author               Description 
-- ----------  -------------------  ------------------------------------
-- 2020-07-11	Anton Shchekalov	Created
-- =============================================
--	Sample calls
--	EXEC [ms].[SubAccount_SetupBasics_Voice] @SubAccountUid = 123
-- =============================================
CREATE PROCEDURE [ms].[SubAccount_SetupBasics_Voice]
   @SubAccountUid INT
AS
BEGIN
	
	BEGIN TRANSACTION
	BEGIN TRY

		-- flags that SA supports CA since now
		EXEC ms.SubAccount_SetupBasics_Internal @SubAccountUid = @SubAccountUid, @Product = 'VO'

	COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
      
		THROW;
	END CATCH
END
