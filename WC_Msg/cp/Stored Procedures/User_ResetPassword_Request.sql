
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-10
-- Possible exceptions to catch:
--   - Dublicated Token: Cannot insert duplicate key row in object 'cp.User' with unique index 'UIX_cp_User_PasswordResetToken'
--   - Non existing email (in table cp.User)
-- =============================================
-- EXEC cp.User_ResetPassword_Request @Email='test01@gmail.com', @Token = 'aaaaaaaaaaaaaa'
CREATE PROCEDURE [cp].[User_ResetPassword_Request]
	@Email nvarchar(255),
	@Token varchar(100)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM cp.[User] WHERE Login = @Email)
		THROW 51000, 'Non existing email', 1;

	UPDATE cp.[User]
	SET PasswordResetToken = @Token, PasswordResetExpiresAt = DATEADD(HOUR, 72, SYSUTCDATETIME())
	WHERE Login = @Email
END


