-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-06-07
-- =============================================
-- EXEC cp.UserRole_Get
CREATE PROCEDURE [cp].[UserRole_Get]
AS
BEGIN

	SELECT RoleName AS Role
	FROM cp.UserRole
END
