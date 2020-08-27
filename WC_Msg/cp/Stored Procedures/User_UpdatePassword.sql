
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-10
-- Possible exceptions to catch:
--   - Invalid token to reset user's password
-- =============================================
-- EXEC cp.User_UpdatePassword @UserId = '9F5F15C4-3EBC-4BF5-B790-3085F0A3C468', @NewPasswordHash = 0x0000001000000200BBA36AAE95882CB417A2BC4EEF124D31AC8B49A49D774F1BB7B33C458633E97DA8538CE6C9F650E53AB1D5573E916022DF659CE15B381B88DC1677585B82E521300C9DC09CAC2024F042F71899D49C23
CREATE PROCEDURE [cp].[User_UpdatePassword]
	@UserId uniqueidentifier,
	@NewPasswordHash varbinary(1024),	--PasswordHash has format "algorithm:iterations:salt:hash"
	@NewPassword nvarchar(50) = NULL,	-- for CPv1 compatibility
	@SecretKey varchar(100) = NULL,
    @PasswordHashAlgorithm varchar(20) = NULL
AS
BEGIN

	UPDATE cp.[User]
	SET PasswordHash = @NewPasswordHash, SecretKey = ISNULL(@SecretKey, SecretKey), UpdatedAt = GETUTCDATE(),
		PasswordResetForce = 0, --SiteVersion_MigrationEnabled = 0,
		UserStatus = IIF(UserStatus = 'I', 'A', UserStatus),
        PasswordHashAlgorithm = @PasswordHashAlgorithm,
        PasswordExpiresAt = DATEADD(DAY, 180, SYSUTCDATETIME())
	WHERE UserId = @UserId

	IF @@ROWCOUNT = 0
		THROW 51000, 'Not existing UserId', 1;

	-- update password in old CPv1 (should be removed after stoping CPv1)
	--IF @NewPassword IS NOT NULL 
	--	UPDATE u SET Password = @NewPassword
	--	FROM dbo.Users u
	--		INNER JOIN cp.[User] cu ON cu.Login = u.Username
	--		INNER JOIN cp.Account ca ON ca.AccountUid = cu.AccountUid AND ca.AccountId = u.AccountId
	--	WHERE cu.UserId = @UserId
END
