
-- =============================================
-- Change History
-- =============================================
-- Date        Author               Description 
-- ----------  -------------------  ------------------------------------
-- 2020-06-10	Anton Shchekalov	Created
-- =============================================
--	Sample calls
--	EXEC [ms].[SubAccount_SetupBasics_ChatApps] @SubAccountUid = 123, @PricingPlanId = 19
-- =============================================
CREATE PROCEDURE [ms].[SubAccount_SetupBasics_ChatApps]
   @SubAccountUid INT,
   @PricingPlanId INT = NULL	-- in case of NULL, default Plan will be set
AS
BEGIN
	
	DECLARE @PricingPlanId_Current INT = NULL

	BEGIN TRANSACTION
	BEGIN TRY

		SELECT TOP 1 @PricingPlanId_Current = PricingPlanId 
		FROM ipm.PricingPlanSubAccount 
		WHERE SubAccountUid = @SubAccountUid 
			AND PeriodEnd > SYSUTCDATETIME()
			AND PeriodStart <= SYSUTCDATETIME()

		-- if request want to keep default, what ever it is
		IF @PricingPlanId IS NULL
			-- and if no pre-existing plan
			AND @PricingPlanId_Current IS NULL

			INSERT INTO ipm.PricingPlanSubAccount (SubAccountUid, PeriodStart, PeriodEnd, PricingPlanId)
			VALUES (@SubAccountUid, SYSUTCDATETIME(), '9999-12-31', 19 /* CONST: default PricingPlanId - "Standard USD" TODO: move to config */)
			-- tiny bug exists if somehow there is record for future only

		ELSE IF @PricingPlanId IS NOT NULL
		-- if PricingPlanId is set - just activate since today. If previous plan exists, close it too
		BEGIN
			-- close previous plan, if exist
			UPDATE ipm.PricingPlanSubAccount
			SET PeriodEnd = SYSUTCDATETIME()
			WHERE SubAccountUid = @SubAccountUid AND PeriodEnd > SYSUTCDATETIME() AND PeriodStart <= SYSUTCDATETIME()

			-- add new plan since today
			INSERT INTO ipm.PricingPlanSubAccount (SubAccountUid, PeriodStart, PeriodEnd, PricingPlanId)
			VALUES (@SubAccountUid, SYSUTCDATETIME(), '9999-12-31', @PricingPlanId)
		END

		-- flags that SA supports CA since now
		EXEC ms.SubAccount_SetupBasics_Internal @SubAccountUid = @SubAccountUid, @Product = 'CA'

	COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
      
		THROW;
	END CATCH
END


SELECT *				FROM ipm.PricingPlanSubAccount 
				WHERE SubAccountUid = @SubAccountUid AND PeriodEnd > SYSUTCDATETIME()