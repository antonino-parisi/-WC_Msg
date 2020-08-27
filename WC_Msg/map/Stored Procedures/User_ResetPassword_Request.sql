
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-10
-- Possible exceptions to catch:
--   - Dublicated Token: Cannot insert duplicate key row in object 'map.User' with unique index 'UIX_map_User_PasswordResetToken'
--   - Non existing email (in table map.User)
-- =============================================
-- EXEC map.User_ResetPassword_Request @Email='test01@gmail.com', @Token = 'aaaaaaaaaaaaaa'
CREATE PROCEDURE [map].[User_ResetPassword_Request]
	@Email varchar(255),
	@Token varchar(100)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM map.[User] WHERE Email = @Email)
		THROW 51000, 'Non existing email', 1;

	UPDATE map.[User]
	SET PasswordResetToken = @Token, PasswordResetExpiresAt = DATEADD(HOUR, 24, GETUTCDATE())
	WHERE Email = @Email
END

