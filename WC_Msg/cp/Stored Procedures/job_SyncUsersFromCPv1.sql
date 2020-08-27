-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 08/01/2019  Rebecca  added update to UserStatus column if dbo.Users.Active=0

CREATE PROCEDURE [cp].[job_SyncUsersFromCPv1]
AS
BEGIN
	-- Update first for existing rows which matched
	UPDATE cu
	SET UserStatus = 'B'
	--SELECT cu.UserId, cu.[Login], du.Username, cu.UserStatus, du.Active
	FROM cp.[user] cu JOIN dbo.users du
	ON du.Active = 0
		AND cu.[Login] = du.Username
	WHERE cu.UserStatus <> 'B' and cu.UserStatus <> 'D' ;

	INSERT INTO cp.[User]
		(UserId, Login, AccountUid, PasswordHash, Firstname, Lastname, Phone, TimeZoneId,
			SecretKey, UserStatus, AccessLevel, SiteVersion_MigrationEnabled, PasswordResetForce) 
	SELECT NEWID() as UserId, RTRIM(du.Username) AS Login, a.AccountUid, 0x0 as PasswordHash, 
		du.Name as FirstName, NULL as Lastname, NULL As Phone, NULL as TimeZoneId, 
		dbo.fnGenerateRandomString(30) as SecretKey, 'A', 'A', 0, 1
	--SELECT *
	FROM cp.[Account] a
		inner join dbo.Users du on du.Active = 1 AND du.AccountId = a.AccountId
		--left join cp.[User] u ON a.AccountUid = u.AccountUid and u.Login = du.Username
		left join cp.[User] u ON u.[Login] = du.Username
	WHERE u.UserId is null

	UPDATE ac set AccountUid = ca.AccountUid
	FROM cp.Account ca 
		inner join dbo.AccountCredentials ac ON ca.AccountId = ac.AccountId
	WHERE ac.AccountUid IS NULL
END
