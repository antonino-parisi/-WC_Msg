-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-19
-- =============================================
-- EXEC cp.[User_Delete] @UserId='...'
CREATE PROCEDURE [cp].[User_Delete]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier
AS
BEGIN

	DECLARE @Deleted TABLE (Login nvarchar(255))
	DECLARE @UserStatus char(1)

	SELECT TOP 1 @UserStatus = UserStatus FROM cp.[User]
	WHERE UserId = @UserId AND AccountUid = @AccountUid

	IF @UserStatus IN ('A', 'B')
	BEGIN
		UPDATE cp.[User]
		SET UserStatus = 'D' /* deleted */, UpdatedAt = SYSUTCDATETIME(), DeletedAt = SYSUTCDATETIME()
		OUTPUT inserted.Login INTO @Deleted
		WHERE UserId = @UserId AND AccountUid = @AccountUid

		UPDATE u SET Active = 0
		FROM dbo.Users u INNER JOIN @Deleted d ON u.Username = d.Login
	END
	ELSE IF @UserStatus IN ('I')
	BEGIN
		/* Delete cp.UserSubAccount entries */
		DELETE FROM cp.UserSubAccount WHERE UserId = @UserId

		/* Delete cp.UserAccess entries */
		DELETE FROM cp.UserAccess WHERE UserId = @UserId

		/* Delete cp.User entries */
		DELETE FROM cp.[User]
		OUTPUT deleted.Login INTO @Deleted
		WHERE UserId = @UserId AND AccountUid = @AccountUid AND UserStatus = 'I' /* pending invitation */

		DELETE FROM u
		FROM dbo.Users u INNER JOIN @Deleted d ON u.Username = d.Login
	END
END
