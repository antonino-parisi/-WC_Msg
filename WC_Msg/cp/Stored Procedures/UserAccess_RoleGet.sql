-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-06-04
-- =============================================
-- EXEC cp.UserAccess_RoleGet @UserId='607E2CD4-BD22-4C42-8DEC-044496142C35'
CREATE PROCEDURE [cp].[UserAccess_RoleGet]
	@UserId uniqueidentifier
AS
BEGIN

	-- if user has limit on roles
	SELECT ur.RoleName AS Role
	FROM cp.[User] u
		INNER JOIN cp.UserAccess ua ON ua.UserId = u.UserId
		INNER JOIN cp.UserRole ur ON ur.RoleId = ua.RoleId
	WHERE u.UserId = @UserId AND u.LimitRoles = 1
	-- if user has NO limit on roles
	UNION ALL
	SELECT ur.RoleName AS Role
	FROM cp.[User] u
		CROSS JOIN cp.UserRole ur
	WHERE u.UserId = @UserId AND u.LimitRoles = 0
	--	AND ur.Product NOT IN ('VO') 
	UNION ALL
	-- hardcoded role for Admins
	SELECT 'UserManagement' AS Role
	FROM cp.[User]
	WHERE UserId = @UserId AND AccessLevel = 'A' ;

	/*
	DECLARE @Roles TABLE (Role varchar(50))

	INSERT INTO @Roles (Role)
	SELECT ur.RoleName
	FROM cp.UserAccess ua
		INNER JOIN cp.UserRole ur ON ur.RoleId = ua.RoleId
	WHERE ua.UserId = @UserId

	-- if user has no restriction on roles or if he is Admin, we return all roles
	IF @@ROWCOUNT = 0 OR 
		EXISTS (SELECT 1 FROM cp.[User] WHERE UserId = @UserId AND AccessLevel = 'A')
	BEGIN
		INSERT INTO @Roles (Role)
		SELECT ur.RoleName AS Role
		FROM cp.UserRole ur
		UNION ALL
		-- hardcoded role for Admins
		SELECT 'UserManagement' AS Role
		FROM cp.[User]
		WHERE UserId = @UserId AND AccessLevel = 'A'
	END

	SELECT DISTINCT @UserId AS UserId, Role
	FROM @Roles
	*/
END
