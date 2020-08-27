CREATE VIEW cp.vwAccountEmail
AS
	SELECT a.AccountId, ae.* 
	FROM cp.AccountEmail AS ae
		LEFT JOIN cp.Account AS a ON ae.AccountUid = a.AccountUid