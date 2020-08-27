-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2020-01-16
-- Description:	Update account info given AccountUid
-- =============================================
-- EXEC map.AccountMeta_Update @AccountUid='A4202809-C3CD-E711-8144-02D85F55FCE7', @VPN=1
-- Update History
-- 2020-07-15 Nathanael Remove EmergencyContact1 and Contact2

CREATE PROCEDURE [map].[AccountMeta_Update]
	@AccountUid uniqueidentifier,
	@AccountName nvarchar(255) = NULL,
	@CustomerType char(1) = NULL,
	@CompanySize char(1) = NULL,
	@MainContact nvarchar(100) = NULL,
	@MainContactEmail varchar(50) = NULL,
	@ManagerId smallint = NULL,
	@CompanyEntity varchar(10) = NULL,
	@BillingMode varchar(10) = NULL,
	@Currency char(3) = NULL,
	@ConnectionType varchar(4) = NULL,
	@UsesWebsender bit = NULL,
	@TrafficType varchar(20) = NULL,
	@VPN bit = NULL,
	@OnboardingStatus varchar(20) = NULL,
	@CustomerCategory varchar(5) = NULL,
	--@SalesforceCustomerId varchar(20) = NULL
	@MapUpdatedBy smallint = NULL-- userid in map.User
AS
BEGIN
	DECLARE @AccountId varchar(50) ;
	
	IF @AccountName IS NOT NULL
		UPDATE cp.Account
		SET	AccountName = @AccountName,
			MapUpdatedBy = @MapUpdatedBy,
			MapUpdatedAt = GETUTCDATE()
		WHERE AccountUid = @AccountUid ;

	-- deprecated
	--DECLARE @Manager varchar(50) ;
	--IF @ManagerId IS NOT NULL
	--	SELECT @Manager = Name 
	--	FROM ms.AccountManager
	--	WHERE ManagerId = @ManagerId ;

	SELECT @AccountId = AccountId FROM cp.Account
	WHERE AccountUid = @AccountUid ;

	IF NOT EXISTS (SELECT 1 FROM ms.AccountMeta WHERE AccountId = @AccountId) -- record does not exists in ms.AccountMeta. Insert
		BEGIN
			SET @CustomerType = ISNULL(@CustomerType, 'E') ;
			--SET @CompanyEntity = ISNULL(@CompanyEntity, 'SG') ;
			--SET @BillingMode = ISNULL(@BillingMode, 'PREPAID') ; 
			--SET @Currency = ISNULL(@Currency, 'EUR') ;

			INSERT INTO ms.AccountMeta
					(AccountId, CustomerType, CompanyEntity, BillingMode, ManagerId,
					MainContact, MainContactEmail,
					Currency, CompanySize, TrafficType, OnboardingStatus, CustomerCategory,
					ConnectionType, UsesWebSender, VPN, MapUpdatedBy)
			VALUES (@AccountId, @CustomerType, DEFAULT, DEFAULT, @ManagerId,
					@MainContact, @MainContactEmail, DEFAULT, 
					@CompanySize, ISNULL(@TrafficType, 'INCONC'), ISNULL(@OnboardingStatus, 'Created'),
					@CustomerCategory, @ConnectionType, @UsesWebsender, @VPN, @MapUpdatedBy) ;
		END
	ELSE -- record exists in ms.AccountMeta. Update
		IF @CustomerType IS NOT NULL OR @CompanySize IS NOT NULL OR @MainContact IS NOT NULL
			OR @MainContactEmail IS NOT NULL
			OR @ManagerId IS NOT NULL OR @CompanyEntity IS NOT NULL OR @BillingMode IS NOT NULL
			OR @Currency IS NOT NULL OR @ConnectionType IS NOT NULL OR @UsesWebsender IS NOT NULL
			OR @TrafficType IS NOT NULL OR @VPN IS NOT NULL OR @OnboardingStatus IS NOT NULL
			OR @CustomerCategory IS NOT NULL
			UPDATE ms.AccountMeta
			SET	CustomerType = ISNULL(@CustomerType, CustomerType),
				CompanySize = ISNULL(@CompanySize, CompanySize),
				MainContact = ISNULL(@MainContact, MainContact),
				MainContactEmail = ISNULL(@MainContactEmail, MainContactEmail),
				ManagerId = IIF(@ManagerId IS NULL, ManagerId, IIF(@ManagerId = -1, NULL, @ManagerId)), -- -1 is to remove
				--Manager = ISNULL(@Manager, Manager), -- deprecated
				CompanyEntity = ISNULL(@CompanyEntity, CompanyEntity),
				BillingMode = ISNULL(@BillingMode, BillingMode),
				Currency = ISNULL(@Currency, Currency),
				ConnectionType = ISNULL(@ConnectionType, ConnectionType),
				UsesWebsender = ISNULL(@UsesWebsender, UsesWebsender),
				TrafficType = ISNULL(@TrafficType, TrafficType),
				VPN = ISNULL(@VPN, VPN),
				OnboardingStatus = ISNULL(@OnboardingStatus, OnboardingStatus),
				CustomerCategory = ISNULL(@CustomerCategory, CustomerCategory),
				MapUpdatedBy = @MapUpdatedBy,
				UpdatedAt = SYSUTCDATETIME()
			WHERE AccountId = @AccountId;
END
