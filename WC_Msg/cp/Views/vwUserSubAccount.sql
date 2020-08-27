CREATE VIEW cp.vwUserSubAccount
AS
	SELECT us.*, u.Login, u.LimitSubAccounts, u.UserStatus, sa.SubAccountId, sa.AccountId
	FROM cp.UserSubAccount us
		LEFT JOIN cp.[User] u ON us.UserId = u.UserId
		LEFT JOIN ms.vwSubAccount sa ON us.SubAccountUid = sa.SubAccountUid
