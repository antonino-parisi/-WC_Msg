-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-11-11
-- Notes: Format of generated @AccountId = "{AccountName}-{random5chars}"
-- =============================================
-- EXEC cp.Account_Create @AccountName='company3'
-- EXEC cp.Account_Create @AccountName='company3', @CompanyName='company1 Lte Ptd', @AccountId='company1'
CREATE PROCEDURE [cp].[Account_Create]
	@AccountName varchar(40),
	@AccountId varchar(50) = NULL, --planned for future, not used yet
	@Currency char(3) = 'EUR'
WITH EXECUTE AS OWNER
AS 
BEGIN

	-- Generate @AccountId based on @AccountName and random string
	IF @AccountId IS NULL
	BEGIN
		SET @AccountId = dbo.fnStripCharacters(@AccountName, '^a-zA-Z0-9_.') + '_' + dbo.fnGenerateRandomString(5)
	END

	-- Check constraints for AccountId
	-- Actually, there is no need for this checks. Transaction will fail and rollback in any case.
	IF EXISTS (SELECT 1 FROM cp.Account WHERE AccountId = @AccountId)
	BEGIN
		DECLARE @msg NVARCHAR(2048)
		SET @msg = 'AccountId already exists: ' + @AccountId;
		THROW 51000, @msg, 1;
	END

	-- Insert new Account
	BEGIN TRY
		BEGIN TRANSACTION

		-- ************************	
		-- *** Account creation ***
		-- ************************	
		INSERT INTO cp.Account (AccountId, AccountName, CompanyName, FreeCreditsOffer, IsV2Allowed) 
			VALUES (@AccountId, @AccountName, @AccountName, 
			mno.CurrencyConverter(1 /* CONST FreeCreditsOffer = 1 EUR */, 'EUR', @Currency, DEFAULT), 1)

		DECLARE @AccountUid uniqueidentifier;
		SELECT @AccountUid = AccountUid FROM cp.Account WHERE AccountId = @AccountId;

		--- Constants
		DECLARE @BalanceInitial DECIMAL(18,6) = 0
		DECLARE @SMS_CustomerGroupId INT = 2 /* CONST: Longtail - cp_curated */

		-- Init Account Wallet
		INSERT INTO cp.AccountWallet (AccountUid, Currency, Balance, OverdraftLimit)
		VALUES (@AccountUid, @Currency, @BalanceInitial, 0);

		-- tag client as Longtail by default
		INSERT INTO ms.AccountMeta (AccountId, CustomerType, Currency, BillingMode, TrafficType)
		VALUES (@AccountId, 'L', @Currency, 'PREPAID', 'INCONC')

		---- in close beta mode ?
		--INSERT INTO cp.AccountFeatureToggle (Feature, AccountId, Enabled)
		--VALUES ('SMS-MCS', @AccountId, 1)

		-- CP v1 / backward compatibility
		DECLARE @AccountPassword varchar(20)
		SET @AccountPassword = dbo.fnGenerateRandomString(10)
		INSERT INTO dbo.AccountCredentials (AccountId, Password, isEncrypted, date, Description, overdraftAuthorized, ValidationTag, IsVerified) 
		VALUES (@AccountId, @AccountPassword, 0, GETUTCDATE(), 'Created by CP', 0, '', 1);

		-- Init deprecated Account Wallet
		INSERT INTO dbo.AccountCredit (AccountId, CreditEuro) 
		VALUES (@AccountId, 0)

		INSERT INTO dbo.AccountBillingInformation (AccountId, AccountInformation, NextBillingDate, SubscriptionDate) 
		VALUES (@AccountId, '', GETUTCDATE(), GETUTCDATE());
	
		INSERT INTO dbo.AccountRecord (AccountId, Date, Record, Value, Currency)
		VALUES (@AccountId, GETUTCDATE(), 'New Account', @BalanceInitial, @Currency)

		INSERT INTO dbo.AccountBalanceAlert
           (AccountId
           ,FirstBalanceAlert
           ,FirstOverDraftAlert
           ,CreatedBy
           ,CreatedDateTime
           ,IsFirstBalanceAlerted
           ,IsBalanceZeroAlerted
           ,IsFirstOverdraftalerted
           ,IsOverdraftZeroalerted)
		VALUES (@AccountId, 0, NULL, 'CP signup', GETUTCDATE(), 1, 1, 0, 0)

		-- *******************************
		-- ***   SubAccount creation with SMS profile   ***
		-- *******************************
		DECLARE @SubAccountId varchar(50) = @AccountId + '_hq'
		DECLARE @SubAccountUid INT
		EXEC @SubAccountUid = ms.SubAccount_Create_Internal @AccountUid = @AccountUid, @SubAccountId = @SubAccountId
		
		-- Setup of 1st SMS profile
		EXEC ms.SubAccount_SetupBasics_SMS @SubAccountUid = @SubAccountUid, @CustomerGroupId = @SMS_CustomerGroupId

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 		

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
		
		THROW;
	END CATCH

	SELECT @AccountId AS AccountId
END
