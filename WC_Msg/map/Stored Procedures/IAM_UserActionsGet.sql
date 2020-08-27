
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-04-06
-- Description:	Get access actions for user
-- =============================================
-- EXEC map.IAM_UserActionsGet @UserId = 11
CREATE PROCEDURE [map].[IAM_UserActionsGet]
	@UserId int
AS
BEGIN
	SELECT DISTINCT ur.UserId, pa.Action
	--SELECT ur.UserId, ur.AccessRole, pa.AccessPermission, pa.Action
	FROM map.IAM_UserRole ur
		INNER JOIN map.IAM_RolePermission rp ON ur.AccessRole = rp.AccessRole
		INNER JOIN map.IAM_PermissionAction pa ON rp.AccessPermission = pa.AccessPermission
	WHERE ur.UserId = @UserId
END

