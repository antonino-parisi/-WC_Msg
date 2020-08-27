
CREATE VIEW [cp].[vwUser]
AS
	SELECT a.AccountId, a.AccountName, 
		u.UserId, 
		u.Login, 
		u.AccountUid, 
		u.UserStatus
      ,u.AccessLevel
      ,u.Firstname
      ,u.Lastname
      ,u.Phone
      ,u.MSISDN
      ,u.PhoneVerified
      ,u.TimeZoneId
      ,u.CreatedAt
      ,u.UpdatedAt
      ,u.DeletedAt
      ,u.LastLoginAt
      ,u.InvitedByUser
      ,u.NeedMigrationFromV1
	FROM cp.[User] u
		LEFT JOIN cp.Account a ON u.AccountUid = a.AccountUid
		--LEFT JOIN dbo.AccountCredentials ac ON a.AccountId = ac.AccountId
