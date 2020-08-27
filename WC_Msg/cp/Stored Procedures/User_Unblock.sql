
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-20
-- =============================================
-- EXEC cp.User_Unblock @UserId='...'
CREATE PROCEDURE [cp].[User_Unblock]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier
AS
BEGIN

	DECLARE @Updated TABLE (Login nvarchar(255))

	UPDATE cp.[User]
	SET UserStatus = 'A' /* active */, UpdatedAt = SYSUTCDATETIME()
	OUTPUT inserted.Login INTO @Updated
	WHERE UserId = @UserId AND AccountUid = @AccountUid AND UserStatus = 'B' /* blocked */

	UPDATE us SET Active = 1
	FROM dbo.Users us INNER JOIN @Updated u ON us.Username = u.Login
END

