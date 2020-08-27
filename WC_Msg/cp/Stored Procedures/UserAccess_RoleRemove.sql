-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-06-04
-- =============================================
-- EXEC cp.UserAccess_RoleRemove @UserId='...'
CREATE PROCEDURE [cp].[UserAccess_RoleRemove]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier,
	@Role varchar(50)
AS
BEGIN

	DELETE FROM ua
	FROM cp.UserAccess ua
		INNER JOIN cp.UserRole ur ON ur.RoleId = ua.RoleId
	WHERE ua.UserId = @UserId AND ur.RoleName = @Role
END
