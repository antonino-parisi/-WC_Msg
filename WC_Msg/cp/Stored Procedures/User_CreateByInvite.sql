-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-19
-- Updated By:  Nathanael Hinay
-- Updated On: 2018-06-15
-- Changes: Add LimitRoles, LimitSubAccounts
-- =============================================
-- EXEC cp.[User_CreateByInvite] @AccountUid='2318BDEB-C250-E711-8141-06B9B96CA965', @Login = 'raymond.torino+20@wavecell.com', @AccessLevel='A', @SecretKey = 'WHIWSH_A4PRR1UMujC66BthfAUM2FhneHKLNP9qox8M', @PasswordResetToken = 'VaH8cEjY3nRlJ9gtI-KmsA2WsyE54gPQtkIBu2MAcI4', @InvitedByUser = '2A793B40-1E23-47F4-9A95-7662822EE5DB'
CREATE PROCEDURE [cp].[User_CreateByInvite]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier = NULL,	-- optional
	@Login nvarchar(255),
	@AccessLevel char(1),				-- 'A' or 'U'
	@SecretKey varchar(100),			-- for future password generation
	@PasswordResetToken varchar(100),	-- for invitation email 
	@InvitedByUser uniqueidentifier = NULL,
	@InvitedByMapUser smallint = NULL,
    @LimitRoles bit = NULL,             -- optional
    @LimitSubAccounts bit = NULL        -- optional
AS
BEGIN

	IF @InvitedByUser IS NULL AND @InvitedByMapUser IS NULL
		THROW 51000, 'Not invited by any user', 1;

	-- Validate email
	DECLARE @msg NVARCHAR(2048)
	IF EXISTS(SELECT 1 FROM cp.[User] WHERE Login = @Login AND AccountUid = @AccountUid AND DeletedAt IS NULL)
	BEGIN
		SET @msg = 'Login=' + @Login + ' already exists';
		THROW 51000, @msg, 1;
	END

	-- read properties of InvitedBy
	DECLARE @AccountId varchar(50)
	DECLARE @TimeZoneId smallint -- to copy TimeZone from inviter
	DECLARE @NowUtc datetime2(2) = SYSUTCDATETIME()

	IF @InvitedByUser IS NOT NULL
		BEGIN
			SELECT @AccountUid = u.AccountUid, @AccountId = a.AccountId,  @TimeZoneId = u.TimeZoneId 
			FROM cp.[User] u INNER JOIN cp.Account a ON u.AccountUid = a.AccountUid 
			WHERE u.UserId = @InvitedByUser AND u.AccountUid = @AccountUid ;

			-- validate InvitedBy
			IF @AccountId IS NULL
			BEGIN
				SET @msg = 'InvitedBy = ' + CAST(@InvitedByUser as varchar(40)) + ' does not match with AccountUid = ' + CAST(@AccountUid as varchar(40));
				THROW 51001, @msg, 1;
			END
		END ;
	ELSE
		SELECT @AccountId = AccountId FROM cp.Account
		WHERE AccountUid = @AccountUid ;		

	IF @UserId IS NULL SET @UserId = NEWID()
	
	-- Insert new User
	BEGIN TRY
		BEGIN TRANSACTION
	
		-- delete prev user with same Login
		DECLARE @PrevUserId uniqueidentifier = NULL
		SELECT @PrevUserId = UserId FROM cp.[User] WHERE Login = @Login AND (DeletedAt IS NOT NULL OR UserStatus = 'D')

		IF @PrevUserId IS NOT NULL
		BEGIN
			DELETE FROM cp.UserSubAccount WHERE UserId = @PrevUserId
			DELETE FROM cp.UserAccess WHERE UserId = @PrevUserId
			DELETE FROM cp.[User] WHERE UserId = @PrevUserId
		END

		-- main insert
		INSERT INTO cp.[User] (
			UserId, Login, 
			AccountUid, 
			UserStatus, UserStatusId, 
			PasswordHash, 
			AccessLevel, 
			LimitSubAccounts, LimitRoles, 
			Firstname, Lastname, Phone, TimeZoneId, CreatedAt,
			SecretKey, PasswordResetForce, PasswordResetToken, PasswordResetExpiresAt, 
			InvitedByUser, InvitedByMapUser) 
		VALUES (
			@UserId, @Login, 
			@AccountUid, 
			'I', 0 /* Invited */, 
			0x00, 
			@AccessLevel, 
			ISNULL(@LimitSubAccounts, 0), ISNULL(@LimitRoles, 0), 
			NULL, NULL, NULL, @TimeZoneId, @NowUtc,
			@SecretKey, 0, @PasswordResetToken, DATEADD(DAY, 7, @NowUtc), 
			@InvitedByUser, @InvitedByMapUser)

		-- in case if user requested new account on his own
		UPDATE cp.UserActivation SET ExpiresAt = @NowUtc WHERE Email = @Login

		-- CP v1 / backward compatibility
		DELETE FROM dbo.Users WHERE Username = @Login AND Active = 0

		-- deprecated, removing
		--INSERT INTO dbo.Users (Username, Password, Name, AdminLevel, EmailAddress, Phone, Active, AccountId)
		--VALUES (@Login, '--invited--in-CPv2-not--set--%%^$*', NULL, 0, @Login, NULL, 1, @AccountId)

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 		

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
		
		THROW;
	END CATCH

	SELECT @UserId AS UserId, @NowUtc AS CreatedAt
END
