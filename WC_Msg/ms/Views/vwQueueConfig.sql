



-- SELECT * FROM [ms].[vwQueueConfig]
CREATE VIEW [ms].[vwQueueConfig]
AS
	SELECT q.*, a.SubAccountId, a.AccountId, UPPER(am.CustomerType) AS CustomerType
	FROM ms.QueueConfig q
		LEFT JOIN dbo.Account a ON q.SubAccountUid = a.SubAccountUid
		LEFT JOIN ms.AccountMeta am ON am.AccountId = a.AccountId
