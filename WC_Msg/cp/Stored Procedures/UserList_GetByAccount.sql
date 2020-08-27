-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-17
-- Used in User management page
-- Updated By:  Nathanael Hinay
-- Updated Date: 2018-06-14
-- Changes: Add SubAccountId in return list of allowed SubAccounts
-- =============================================
-- EXEC cp.UserList_GetByAccount @AccountUid='499250FE-E2E5-E611-813F-06B9B96CA965'
-- SELECT TOP 100 * FROM cp.Account 
CREATE PROCEDURE [cp].[UserList_GetByAccount]
	@AccountUid uniqueidentifier
AS
BEGIN

	SET NOCOUNT ON

	SELECT 
		u.UserId, 
		u.Login, 
		u.Firstname, 
		u.Lastname, 
		u.UserStatus, 
		u.AccessLevel, 
		u.LimitSubAccounts,
		u.LimitRoles,
		u.CreatedAt,
		u.InvitedByUser AS InvitedBy_UserId, 
		inv.Login AS InvitedBy_Login, 
		inv.Firstname AS InvitedBy_Firstname, 
		inv.Lastname AS InvitedBy_Lastname
	FROM cp.[User] u
		INNER JOIN cp.Account a ON u.AccountUid = a.AccountUid
		LEFT JOIN cp.[User] inv ON u.InvitedByUser = inv.UserId
	WHERE u.AccountUid = @AccountUid AND u.UserStatus IN ('A', 'I', 'B') AND u.DeletedAt IS NULL

	--SELECT ur.UserId, ur.[Role]
	--FROM cp.UserRole ur
	--	INNER JOIN cp.[User] u ON u.UserId = ur.UserId
	--	INNER JOIN cp.Account a ON u.AccountUid = a.AccountUid
	--WHERE u.AccountUid = @AccountUid

	-- *** return list of allowed roles ***
	
	-- if user has limit on roles
	SELECT u.UserId, ur.RoleName AS Role
	FROM cp.[User] u
		INNER JOIN cp.UserAccess ua ON ua.UserId = u.UserId
		INNER JOIN cp.UserRole ur ON ur.RoleId = ua.RoleId
	WHERE u.AccountUid = @AccountUid
		--AND u.UserId = @UserId 
		AND u.LimitRoles = 1
	-- if user has NO limit on roles
	UNION ALL
	SELECT u.UserId, ur.RoleName AS Role
	FROM cp.[User] u
		CROSS JOIN cp.UserRole ur
	WHERE u.AccountUid = @AccountUid
		-- AND u.UserId = @UserId 
		AND u.LimitRoles = 0
	UNION ALL
	-- hardcoded role for Admins
	SELECT u.UserId, 'UserManagement' AS Role
	FROM cp.[User] u
	WHERE u.AccountUid = @AccountUid
		--AND UserId = @UserId 
		AND u.AccessLevel = 'A'

	-- return list of allowed SubAccounts
	SELECT u.UserId, sa.SubAccountUid, sa.SubAccountId
	FROM cp.[User] u
		INNER JOIN cp.Account a ON u.AccountUid = a.AccountUid
		INNER JOIN dbo.Account sa ON sa.AccountId = a.AccountId
		LEFT JOIN cp.UserSubAccount us ON u.UserId = us.UserId AND us.SubAccountUid = sa.SubAccountUid
	WHERE u.AccountUid = @AccountUid
		AND (u.LimitSubAccounts = 0 OR (u.LimitSubAccounts = 1 AND us.Id IS NOT NULL))

END
