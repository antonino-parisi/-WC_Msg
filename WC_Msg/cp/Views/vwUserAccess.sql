
CREATE VIEW [cp].[vwUserAccess]
AS
	SELECT 
		ua.*,
		u.Login, 
		u.LimitRoles,
		a.AccountId,
		ur.RoleName
	FROM [cp].[UserAccess] ua 
		LEFT JOIN cp.[User] u ON u.UserId = ua.UserId
		LEFT JOIN cp.Account a ON a.AccountUid = u.AccountUid
		LEFT JOIN cp.UserRole ur ON ur.RoleId = ua.RoleId
