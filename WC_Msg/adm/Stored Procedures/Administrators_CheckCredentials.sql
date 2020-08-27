
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-09-29
-- Description:	Returns 2 tables:
--		1) user record by credentials
--		---- no 2) user's roles
-- =============================================
--	Example
--		EXEC [adm].[Administrators_CheckCredentials] 'bon.ariola@wavecell.com', 'AeAhM7qbIb9mgnEixgf7', 'RoutePortal'
-- =============================================
CREATE PROCEDURE [adm].[Administrators_CheckCredentials] 
	@Username varchar(50),
	@Password nvarchar(50),
	@App varchar(50)
AS
BEGIN

	--SELECT u.Username, u.Name--, ur.Role
	--FROM adm.[User] u
	--	--INNER JOIN adm.UserRole ur ON u.Username = ur.Username
	--WHERE u.Username = @Username AND u.[Password] = @Password AND IsActive = 1

	----SELECT ur.Role
	----FROM adm.UserRole ur
	----WHERE ur.Username = @Username

	SELECT u.EmailAddress as Username, u.Name--, ur.Role
	FROM dbo.Administrators u
	WHERE u.EmailAddress = @Username AND u.[Password] = @Password AND u.Active = 1

END

