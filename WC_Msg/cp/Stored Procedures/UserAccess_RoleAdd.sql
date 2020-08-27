-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-06-04
-- =============================================
-- EXEC cp.UserAccess_RoleAdd @UserId='...'
CREATE PROCEDURE [cp].[UserAccess_RoleAdd]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier,
	@Role varchar(50)
AS
BEGIN

	INSERT INTO cp.UserAccess (UserId, RoleId)
	SELECT @UserId, RoleId
	FROM cp.UserRole
	WHERE RoleName = @Role
END
