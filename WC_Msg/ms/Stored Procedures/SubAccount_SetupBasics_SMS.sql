

-- =============================================
-- Change History
-- =============================================
-- Date        Author               Description 
-- ----------  -------------------  ------------------------------------
-- 2020-06-10	Anton Shchekalov	Created
-- =============================================
--	Sample calls
--	EXEC ms.SubAccount_SetupBasics_SMS @SubAccountUid = 123, @CustomerGroupId = 3
-- =============================================
CREATE PROCEDURE [ms].[SubAccount_SetupBasics_SMS]
   @SubAccountUid INT,
   @CustomerGroupId INT
AS
BEGIN
	
	BEGIN TRANSACTION
	BEGIN TRY

		-- Add to SMS Customer Group
		EXEC map.CustomerGroup_SubAccount_Add @CustomerGroupId, @SubAccountUid
		
		-- setup basic properties
		EXEC ms.SubAccount_SetupBasics_Internal @SubAccountUid = @SubAccountUid, @Product = 'SM'
        
	COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
      
		THROW;
	END CATCH
END
