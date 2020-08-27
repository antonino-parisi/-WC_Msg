CREATE VIEW [cp].[vwBillingTransaction]
AS
	SELECT
		ac.AccountId,
		bt.*,
		u.Email AS MapUserEmail
	FROM cp.BillingTransaction bt
		 INNER JOIN cp.Account ac ON bt.AccountUid = ac.AccountUid
		 LEFT JOIN map.[User] u ON u.UserId = bt.MapUserId
