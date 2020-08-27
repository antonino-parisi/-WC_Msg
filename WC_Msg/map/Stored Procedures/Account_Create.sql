-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2019-11-25
-- Remarks : Mostly using cp.Account_Create
-- =============================================
-- EXEC map.Account_Create

CREATE PROCEDURE [map].[Account_Create]
	@AccountName varchar(40),
	@AccountId varchar(50),
	@CustomerType char(1),
	@CompanySize char(1), -- E, M, S
	@MainContact nvarchar(100),
	@MainContactEmail varchar(100),
	@TechContactEmail varchar(100) = NULL,
	@OpsContactEmail varchar(100) = NULL,
	@ManagerId smallint = NULL,
	@CompanyEntity varchar(10) = NULL,
	@BillingMode varchar(10) = NULL, -- PREPAID, POSTPAID, NOPAY
	@Currency char(3) = NULL,
	@UpdatedBy smallint = NULL,
	@ApiKey varchar(100) = NULL
WITH EXECUTE AS OWNER
AS 
BEGIN
	DECLARE @Manager varchar(50) ;
	DECLARE @msg NVARCHAR(2048) ;
	DECLARE @AccountUid uniqueidentifier ;

	-- Generate @AccountId based on @AccountName and random string
	-- SET @AccountId = @AccountId + '_' + dbo.fnGenerateRandomString(5)

	-- Check if AccountId already exists
	IF EXISTS (SELECT 1 FROM ms.AccountMeta WHERE AccountId = @AccountId) OR
		EXISTS (SELECT 1 FROM cp.Account WHERE AccountId = @AccountId)
		BEGIN
			SET @msg = 'AccountId already exists: ' + @AccountId;
			THROW 51000, @msg, 1;
		END

	IF @ManagerId IS NOT NULL -- get the manager name
		BEGIN
			SELECT @Manager = [Name] FROM ms.AccountManager
			WHERE ManagerId = @ManagerId ;

			IF @Manager IS NULL
				BEGIN
					SET @msg = 'Manager does not exist where ManagerId = ' + CAST(@ManagerId AS VARCHAR(10)) ;
					THROW 51000, @msg, 1;
				END
		END ;

	-- Insert new Account
	BEGIN TRY
		BEGIN TRANSACTION

		-- defaults
		SET @CompanyEntity = ISNULL(@CompanyEntity, 'WSG') ;
		SET @BillingMode = ISNULL(@BillingMode, 'PREPAID') ; 
		SET @Currency = ISNULL(@Currency, 'EUR') ;
	
		-- Init Account v2
		INSERT INTO cp.Account (AccountId, AccountName, CompanyName, FreeCreditsOffer, 
			IsV2Allowed, MapUpdatedBy, MapUpdatedAt) 
		VALUES (@AccountId, @AccountName, @AccountName, 
			mno.CurrencyConverter(1 /* CONST FreeCreditsOffer = 1 EUR */, 'EUR', @Currency, DEFAULT), 
			1, @UpdatedBy, GETUTCDATE()) ;

		SELECT @AccountUid = AccountUid FROM cp.Account WHERE AccountId = @AccountId ;

		INSERT INTO ms.AccountMeta
				(AccountId, CustomerType, CompanyEntity, BillingMode, Manager, ManagerId,
				MainContact, MainContactEmail,
				Currency, CompanySize, TrafficType)
		VALUES (@AccountId, @CustomerType, @CompanyEntity, @BillingMode, @Manager, @ManagerId,
				@MainContact, @MainContactEmail,
				@Currency, @CompanySize, 'INCONC');

		-- CP v1 / backward compatibility
		DECLARE @AccountPassword varchar(20)
		SET @AccountPassword = dbo.fnGenerateRandomString(10)
		INSERT INTO dbo.AccountCredentials (AccountId, Password, isEncrypted, [date], [Description], overdraftAuthorized, ValidationTag, IsVerified) 
		VALUES (@AccountId, @AccountPassword, 0, GETUTCDATE(), 'Created by MAP', 0, '', 1);

		INSERT INTO dbo.AccountCredit (AccountId, CreditEuro) 
		VALUES (@AccountId, 0)

		INSERT INTO dbo.AccountBillingInformation (AccountId, AccountInformation, NextBillingDate, SubscriptionDate) 
		VALUES (@AccountId, '', GETUTCDATE(), GETUTCDATE());
	
		INSERT INTO dbo.AccountRecord (AccountId, Date, Record, value)
		VALUES (@AccountId, GETUTCDATE(), 'New Account', 0)

		INSERT INTO dbo.AccountBalanceAlert
			(AccountId, FirstBalanceAlert, FirstOverDraftAlert, CreatedBy, CreatedDateTime,
			IsFirstBalanceAlerted, IsBalanceZeroAlerted, IsFirstOverdraftalerted, IsOverdraftZeroalerted)
		VALUES (@AccountId, 0, NULL, 'MAP signup', GETUTCDATE(), 1, 1, 0, 0)

        -- Insert into cp.AccountEmail
        IF @OpsContactEmail IS NOT NULL
            INSERT INTO cp.AccountEmail (AccountUid, Email, Type, FlagPricing)
            VALUES (@AccountUid, @OpsContactEmail, 'TO', 1);

		IF @TechContactEmail IS NOT NULL
		BEGIN
			UPDATE cp.AccountEmail SET FlagTech = 1 WHERE AccountUid = @AccountUid AND Email = @TechContactEmail

			IF @@rowcount = 0
				INSERT INTO cp.AccountEmail (AccountUid, Email, Type, FlagTech)
				VALUES (@AccountUid, @TechContactEmail, 'TO', 1);
		END

		-- Init Account Wallet
		INSERT INTO cp.AccountWallet (AccountUid, Currency, Balance, OverdraftLimit)
		VALUES (@AccountUid, @Currency, 0, 0);

		--INSERT INTO cp.AccountFeatureToggle (Feature, AccountId, Enabled)
		--VALUES ('SMS-MCS', @AccountId, 1)

		IF @ApiKey IS NOT NULL
			INSERT INTO ms.AuthApi (AccountId, ApiKey, [Name], Active)
			VALUES (@AccountId, @ApiKey, 'DEFAULT', 1) ;

		-- Create 1st subaccount -- start
		DECLARE @SubAccountId varchar(50) = @AccountId + '_OTP'
		DECLARE @SubAccountUid INT
		EXEC @SubAccountUid = ms.SubAccount_Create_Internal @AccountUid = @AccountUid, @SubAccountId = @SubAccountId
		
		-- Setup of 1st SMS profile
		EXEC ms.SubAccount_SetupBasics_SMS @SubAccountUid = @SubAccountUid, @CustomerGroupId = 12 /* OTP @SMS_CustomerGroupId */

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 		

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
		
		THROW;
	END CATCH
	
	SELECT @AccountId AS AccountId, @AccountUid AS AccountUid, @AccountName As AccountName ;
END
