-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-20
-- Used to authenticate user or to get data when reset password
-- =============================================
-- EXEC map.User_GetByEmail @Email = 'atrony+123@gmail.com'
CREATE PROCEDURE [map].[User_GetByEmail]
	@Email nvarchar(255)
AS
BEGIN

    
	-- return user record
	SELECT u.UserId, u.PasswordHash, u.Email, u.FirstName, u.LastName, u.TimeZoneId
	FROM map.[User] u
	WHERE Email = @Email AND UserStatusId = 1 AND DeletedAt IS NULL

    IF @@ROWCOUNT = 0 RETURN

    DECLARE @UserId smallint;
	SELECT @UserId = u.UserId
    FROM map.[User] u
    WHERE Email = @Email

	-- update LastLoginAt
    UPDATE map.[User] SET LastLoginAt = GETUTCDATE()
    WHERE UserId = @UserId

	-- return user's permissions
    IF EXISTS (SELECT 1 FROM map.IAM_UserRole ur WHERE ur.UserId = @UserId)
        SELECT DISTINCT AccessPermission
        FROM map.IAM_UserRole ur
            INNER JOIN map.IAM_RolePermission rp ON ur.AccessRole = rp.AccessRole
        WHERE ur.UserId = @UserId
    ELSE
        SELECT AccessPermission FROM map.IAM_RolePermission WHERE AccessRole = 'Admin'

END



