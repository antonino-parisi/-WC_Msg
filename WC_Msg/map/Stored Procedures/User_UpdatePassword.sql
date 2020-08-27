
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-20
-- Possible exceptions to catch:
--   - Invalid token to reset user's password
-- =============================================
-- EXEC map.User_UpdatePassword @UserId = '9F5F15C4-3EBC-4BF5-B790-3085F0A3C468', @NewPasswordHash = 0x0000001000000200BBA36AAE95882CB417A2BC4EEF124D31AC8B49A49D774F1BB7B33C458633E97DA8538CE6C9F650E53AB1D5573E916022DF659CE15B381B88DC1677585B82E521300C9DC09CAC2024F042F71899D49C23
CREATE PROCEDURE [map].[User_UpdatePassword]
	@UserId smallint,
	@NewPasswordHash varbinary(1024) --PasswordHash has format "algorithm:iterations:salt:hash"
AS
BEGIN

	
	UPDATE map.[User]
	SET PasswordHash = @NewPasswordHash, UpdatedAt = GETUTCDATE()
	WHERE UserId = @UserId

	IF @@ROWCOUNT = 0
		THROW 51000, 'Not existing UserId', 1;
END

