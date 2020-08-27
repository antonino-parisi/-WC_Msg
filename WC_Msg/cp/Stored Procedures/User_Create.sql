-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-11-13
-- =============================================
-- EXEC cp.User_Create @UserId = '7A627C9E-A119-490B-AF15-DD9B859C07B2', @Token = 'awekljljhq', @AccountId='company3', @SecretKey = '6198723yuoie', @PasswordHash = 0x0
-- =============================================
-- Change History
-- =============================================
-- Date        Author               Description 
-- ----------  -------------------  ------------------------------------
-- 10/01/2019  Alexjander Bacalso   added column OptIn_Marketing column
CREATE PROCEDURE [cp].[User_Create]
	@UserId uniqueidentifier,
	@Token varchar(100),
	@SecretKey varchar(100),
	@AccountId varchar(50),
	@Password nvarchar(50) = NULL,	-- for CPv1 compatibility
	@PasswordHash varbinary(1024),	--@PasswordHash with format "algorithm:iterations:salt:hash"
	@Firstname nvarchar(255) = NULL,
	@Lastname nvarchar(255) = NULL,
	@Phone varchar(20) = NULL,
	@TimeZoneName varchar(35) = NULL,
    @OptIn_Marketing bit = 0,
    @PasswordHashAlgorithm varchar(20) = NULL
AS
BEGIN

	SET NOCOUNT ON

	-- Get timezone id
	DECLARE @TimeZoneid smallint
	SELECT @TimeZoneid = TimeZoneid FROM mno.TimeZone WHERE TimeZoneName = @TimeZoneName

	-- Get email (only for *valid* token)
	DECLARE @Login nvarchar(255)
	DECLARE @AccountId_FromToken varchar(50)
	DECLARE @AccountUid uniqueidentifier
	
	SELECT @Login = ua.Email, @AccountId_FromToken = ua.AccountId
	FROM cp.UserActivation ua
	WHERE Token = @Token AND Activated = 0 AND ExpiresAt > GETUTCDATE()
	
	-- Validate token/email, account
	DECLARE @msg NVARCHAR(2048)
	IF (@Login IS NULL)
	BEGIN
		SET @msg = 'Invalid token=' + @Token + ' to create User in AccountId=' + @AccountId;
		THROW 51000, @msg, 1;
	END
	IF (@AccountId_FromToken IS NOT NULL AND @AccountId_FromToken <> @AccountId)
	BEGIN
		SET @msg = 'Attempt to activate Token=' + @Token + ' for wrong AccountId=' + @AccountId;
		THROW 51001, @msg, 1;
	END
	-- Validate AccountId
	SELECT @AccountUid = AccountUid FROM cp.Account a WHERE a.AccountId = @AccountId
	IF @AccountUid IS NULL
	BEGIN
		SET @msg = 'AccountId=' + @AccountId + ' does not exists';
		THROW 51002, @msg, 1;
	END

	-- Insert new User
	BEGIN TRY
		BEGIN TRANSACTION
	
		-- CP v2
		UPDATE cp.UserActivation
		SET Activated = 1, UpdatedAt = GETUTCDATE(), AccountId = ISNULL(@AccountId_FromToken, @AccountId)
		WHERE Token = @Token

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
		INSERT INTO cp.[User] (UserId, Login, AccountUid, PasswordHash, UserStatus, AccessLevel, Firstname, Lastname,
            Phone, TimeZoneId, SecretKey, OptIn_Marketing, PasswordHashAlgorithm, PasswordExpiresAt) 
		VALUES (@UserId, @Login, @AccountUid, @PasswordHash, 'A', 'A', @Firstname, @Lastname,
            @Phone, @TimeZoneId, @SecretKey, @OptIn_Marketing, @PasswordHashAlgorithm, DATEADD(DAY, 180, SYSUTCDATETIME()))

		-- CP v1 / backward compatibility
		DECLARE @Fullname nvarchar(50)
		IF (@Firstname IS NOT NULL AND @Lastname IS NULL) SET @Fullname = @Firstname
		ELSE IF (@Firstname IS NULL AND @Lastname IS NOT NULL) SET @Fullname = @Lastname
		ELSE IF (@Firstname IS NOT NULL AND @Lastname IS NOT NULL) SET @Fullname = @Firstname + ' ' + @Lastname

		DELETE FROM dbo.Users WHERE Username = @Login AND Active = 0

		-- deprecated, removed
		--INSERT INTO dbo.Users (Username, Password, Name, AdminLevel, EmailAddress, Phone, Active, AccountId)
		--VALUES (@Login, CAST(@UserId AS VARCHAR(40)) + LEFT(@SecretKey, 10) /*@Password*/, @Fullname, 0, @Login, @Phone, 1, @AccountId)

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 		

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
		
		THROW;
	END CATCH

	SELECT @UserId AS UserId
END
