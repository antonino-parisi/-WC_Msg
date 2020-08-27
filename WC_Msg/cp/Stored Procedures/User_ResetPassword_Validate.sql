
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-10
-- =============================================
-- EXEC cp.User_ResetPassword_Validate @Token = 'aaaaaaaaaaaaaa'
CREATE PROCEDURE [cp].[User_ResetPassword_Validate]
	@Token varchar(100)
AS
BEGIN

	DECLARE @ExpiresAt datetime = NULL
	DECLARE @Login nvarchar(255) = NULL

	SELECT @Login = Login, @ExpiresAt = PasswordResetExpiresAt
	FROM cp.[User] WHERE PasswordResetToken = @Token

	IF @@ROWCOUNT = 0
		SELECT 'INVALID_TOKEN' AS Result, NULL as Login	-- Error
	ELSE IF (@ExpiresAt < GETUTCDATE())
		SELECT 'TOKEN_EXPIRED' AS Result, NULL as Login	-- Error
	ELSE IF (@ExpiresAt >= GETUTCDATE())
		SELECT 'VALID_TOKEN' AS Result, @Login as Login	-- OK
END

