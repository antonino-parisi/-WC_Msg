
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-20
-- =============================================
-- EXEC cp.User_Block @UserId='...'
CREATE PROCEDURE [cp].[User_Block]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier
AS
BEGIN

	DECLARE @Updated TABLE (Login nvarchar(255))

	UPDATE cp.[User]
	SET UserStatus = 'B' /* blocked */, UpdatedAt = SYSUTCDATETIME()
	OUTPUT inserted.Login INTO @Updated
	WHERE UserId = @UserId AND AccountUid = @AccountUid AND UserStatus = 'A' /* active */

	UPDATE us SET Active = 0
	FROM dbo.Users us INNER JOIN @Updated u ON us.Username = u.Login
END

