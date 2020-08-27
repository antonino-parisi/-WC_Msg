
CREATE VIEW sms.vwStatSmsLogSIDDaily AS
	SELECT 
		s.*, 
		sa.SubAccountId, sa.AccountId, sa.CustomerType,
		o.OperatorName,
		sc.ConnId
	FROM sms.StatSmsLogSIDDaily s (NOLOCK)
		LEFT JOIN ms.vwSubAccount sa ON s.SubAccountUid = sa.SubAccountUid
		LEFT JOIN mno.Operator o ON s.OperatorId = o.OperatorId
		LEFT JOIN rt.SupplierConn sc ON sc.ConnUid = s.ConnUid