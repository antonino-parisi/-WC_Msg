-- =============================================
-- Change History
-- =============================================
-- Date        Author               Description 
-- ----------  -------------------  ------------------------------------
-- 2020-03-02	Igor Valyansky		Create new SubAccount from Config API
-- 2020-03-11	Anton Shchekalov	Added to use TemplateId on subaccount
-- =============================================
--	Sample calls
--	EXEC [ms].[SubAccount_Add] @AccountUid = '80B13B5F-2AC8-E911-814A-02D85F55FCE7', @SubAccountName = 'test1', @SubAccountTemplateId = '8x8-VCC-CA'
-- =============================================
CREATE PROCEDURE [ms].[SubAccount_Add]
   @AccountUid UNIQUEIDENTIFIER,
   @SubAccountName VARCHAR(25),
   @SubAccountTemplateId varchar(50) 
AS
BEGIN

	DECLARE @ProductSMS bit, @ProductCA bit
	DECLARE @SMS_CustomerGroupId int, @CA_PricingPlanId smallint

	SELECT 
		@ProductSMS = Product_SMS, 
		@ProductCA = Product_CA, 
		@SMS_CustomerGroupId = SMS_CustomerGroupId, 
		@CA_PricingPlanId = CA_PricingPlanId
	FROM ms.SubAccountTemplate t
	WHERE 
		t.SubAccountTemplateId = @SubAccountTemplateId 
		AND (t.AccountUid IS NULL OR (t.AccountUid IS NOT NULL AND t.AccountUid = @AccountUid))

	IF @ProductSMS IS NULL OR @ProductCA IS NULL
		THROW 51000, 'Non-exisiting template or no access to it', 1;

	-- Generate SubAccountId
	DECLARE @AccountId varchar(50);
	SELECT @AccountId = AccountId FROM cp.Account WHERE AccountUid = @AccountUid;
	DECLARE @SubAccountId varchar(50) = LEFT(@AccountId, 19) + '_' + LEFT(@SubAccountName, 25) + '_' + dbo.fnGenerateRandomString(4);
   
	BEGIN TRANSACTION
	BEGIN TRY

		DECLARE @SubAccountUid INT
		EXEC @SubAccountUid = ms.SubAccount_Create_Internal @AccountUid = @AccountUid, @SubAccountId = @SubAccountId
		
		-- SMS activation
		IF (@ProductSMS = 1)
			EXEC ms.SubAccount_SetupBasics_SMS @SubAccountUid = @SubAccountUid, @CustomerGroupId = @SMS_CustomerGroupId

		-- CA activation
		IF (@ProductCA = 1)
			EXEC ms.SubAccount_SetupBasics_ChatApps @SubAccountUid = @SubAccountUid, @PricingPlanId = @CA_PricingPlanId

		SELECT 
			SubAccountUid,
			SubAccountId, 
			Product_SMS AS SmsEnabled, 
			Product_CA AS ChatAppsEnabled, 
			Product_VO AS VoiceEnabled 
		FROM ms.SubAccount WHERE SubAccountUid = @SubAccountUid

	COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
      
		THROW;
	END CATCH
END
