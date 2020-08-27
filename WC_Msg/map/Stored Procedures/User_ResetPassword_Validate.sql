
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-20
-- =============================================
-- EXEC map.User_ResetPassword_Validate @Token = 'aaaaaaaaaaaaaa'
CREATE PROCEDURE [map].[User_ResetPassword_Validate]
	@Token varchar(100)
AS
BEGIN

	DECLARE @ExpiresAt datetime = NULL
	DECLARE @Email varchar(255) = NULL

	SELECT @Email = Email, @ExpiresAt = PasswordResetExpiresAt
	FROM map.[User] WHERE PasswordResetToken = @Token

	IF @@ROWCOUNT = 0
		SELECT 'INVALID_TOKEN' AS Result, NULL as Email	-- Error
	ELSE IF (@ExpiresAt < GETUTCDATE())
		SELECT 'TOKEN_EXPIRED' AS Result, NULL as Email	-- Error
	ELSE IF (@ExpiresAt >= GETUTCDATE())
		SELECT 'VALID_TOKEN' AS Result, @Email as Email	-- OK
END

