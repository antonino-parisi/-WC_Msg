
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-10
-- Possible exceptions to catch:
--   - Invalid token to reset user's password
-- =============================================
-- EXEC cp.User_ResetPassword_Update @Token = 'aaaaaaaaaaaaaa', @SecretKey = '5kK7654D6D2A1EC45069456FC33113', @NewPasswordHash = 0x0000001000000200BBA36AAE95882CB417A2BC4EEF124D31AC8B49A49D774F1BB7B33C458633E97DA8538CE6C9F650E53AB1D5573E916022DF659CE15B381B88DC1677585B82E521300C9DC09CAC2024F042F71899D49C23
CREATE PROCEDURE [cp].[User_ResetPassword_Update]
	@Token varchar(100),
	@NewPasswordHash varbinary(1024), --PasswordHash has format "algorithm:iterations:salt:hash"
	@NewPassword nvarchar(50) = NULL,
    @PasswordHashAlgorithm varchar(20) = NULL
AS
BEGIN

	DECLARE @Updated TABLE (UserId uniqueidentifier)

	UPDATE cp.[User]
	SET PasswordResetToken = NULL, PasswordResetExpiresAt = NULL, 
		PasswordHash = @NewPasswordHash, UpdatedAt = SYSUTCDATETIME(),
		UserStatus = IIF(UserStatus = 'I', 'A', UserStatus),	-- switch user "active" from "pending invitation"
		PasswordResetForce = 0,--, SiteVersion_MigrationEnabled = 0
        PasswordHashAlgorithm = @PasswordHashAlgorithm,
        PasswordExpiresAt = DATEADD(DAY, 180, SYSUTCDATETIME())
	OUTPUT inserted.UserId INTO @Updated
	WHERE PasswordResetToken = @Token AND PasswordResetExpiresAt > SYSUTCDATETIME()

	IF @@ROWCOUNT = 0
		THROW 51000, 'Invalid token to reset user''s password', 1;

	---- update password in old CPv1 (should be removed after stoping CPv1)
	--IF @NewPassword IS NOT NULL 
	--	UPDATE u SET Password = @NewPassword
	--	FROM dbo.Users u
	--		INNER JOIN cp.[User] cu ON cu.Login = u.Username
	--		INNER JOIN @Updated upd ON cu.UserId = upd.UserId

END
