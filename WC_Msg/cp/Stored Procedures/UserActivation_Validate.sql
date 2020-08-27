
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-11-11
-- =============================================
-- EXEC cp.UserActivation_Validate @Token='wrong-lkjasjdflkasdhlq9p848lkjegakjgljj34q98'
-- EXEC cp.UserActivation_Validate @Token='Lkjasjdflkasdhlq9p848lkjegakjgljj34q98'
-- EXEC cp.UserActivation_Validate @Token='lkjasjdflkasdhlq9p848lkjegakjgljj34q98'
CREATE PROCEDURE [cp].[UserActivation_Validate]
	@Token varchar(100)
AS
BEGIN

	DECLARE @ExpiresAt datetime = NULL
	DECLARE @Activated bit = NULL
	DECLARE @Email nvarchar(255) = NULL

	SELECT @Email = Email, @ExpiresAt = ExpiresAt, @Activated = Activated FROM cp.UserActivation WHERE Token = @Token

	IF @@ROWCOUNT = 0
		SELECT 'INVALID_TOKEN' AS Result, NULL as Email	-- Error
	ELSE IF (@Activated = 1)
		SELECT 'TOKEN_ALREADY_ACTIVATED' AS Result, @Email as Email	-- OK
	ELSE IF (@Activated = 0 AND @ExpiresAt < GETUTCDATE())
		SELECT 'TOKEN_EXPIRED' AS Result, NULL as Email	-- Error
	ELSE IF (@Activated = 0 AND @ExpiresAt >= GETUTCDATE())
		SELECT 'VALID_TOKEN' AS Result, @Email as Email	-- OK
	ELSE
		SELECT 'UNSUPPORTED_CASE' AS Result, NULL as Email
END

