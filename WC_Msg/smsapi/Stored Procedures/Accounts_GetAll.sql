-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-10-11
-- Description:	Returns account passwords and queue for MT
-- =============================================
--	EXEC [smsapi].[Accounts_GetAll] @Host = 'PRO-SMS1'
--	update ms.TableChanges set LastChangeTime = GETUTCDATE() where [Key] = 'ms.SubAccount'
CREATE PROCEDURE [smsapi].[Accounts_GetAll] 
	@Host varchar(20) = NULL
AS
BEGIN

	--DECLARE @Host varchar(20) = NULL
	DECLARE @ClusterGroupId varchar(50)
	SET @ClusterGroupId = ms.ClusterGroup_GetByHost(@Host)

	SELECT DISTINCT ac.AccountId, ac.Password, 
		--IIF(rabbit_customcluster.QueueName IS NULL AND rabbit_defcluster.QueueName IS NULL AND rabbit_defcluster_lt.QueueName IS NULL, 'MSMQ', 'R') AS QueueType,
		'R' AS QueueType,
		IIF(rabbit_customcluster.QueueName IS NULL AND rabbit_defcluster.QueueName IS NULL AND rabbit_defcluster_lt.QueueName IS NULL, 'mt_l_default', ISNULL(rabbit_customcluster.QueueName, ISNULL(rabbit_defcluster.QueueName, rabbit_defcluster_lt.QueueName))) AS Queue_MT, 
		NULL AS Default_SenderId,
		a.SubAccountId, a.SubAccountUid, IIF(aip.RuleCount > 0, 1, 0) AS IPWhitelistEnabled
	FROM dbo.AccountCredentials ac
		--LEFT JOIN ms.MasterQueues2 mq ON ac.AccountId = mq.AccountId AND mq.MessageType = 'MT' AND mq.ClusterGroupId = @ClusterGroupId
		--LEFT JOIN ms.MasterQueues2 mqdef ON mqdef.AccountId = 'default' AND mqdef.MessageType = 'MT' AND mqdef.ClusterGroupId = @ClusterGroupId
		INNER JOIN dbo.Account a ON a.AccountId = ac.AccountId and a.Active = 1 and a.Deleted = 0
		LEFT JOIN cp.Account ca ON ca.AccountId = ac.AccountId
		LEFT JOIN (SELECT AccountUid, COUNT(1) AS RuleCount FROM ms.AuthIP GROUP BY AccountUid) aip ON aip.AccountUid = ca.AccountUid
		OUTER APPLY (
			SELECT TOP (1) QueueName FROM ms.QueueConfig qc WHERE a.SubAccountUid = qc.SubAccountUid AND qc.QueueRole = 'MT' AND ClusterGroupId_Publish = @ClusterGroupId
		) rabbit_customcluster
		OUTER APPLY (
			SELECT TOP (1) QueueName FROM ms.QueueConfig qc WHERE a.SubAccountUid = qc.SubAccountUid AND qc.QueueRole = 'MT' AND ClusterGroupId_Publish = 'ANY'
		) rabbit_defcluster
		OUTER APPLY (
			SELECT TOP (1) QueueName FROM ms.QueueConfig qc WHERE qc.SubAccountUid IS NULL AND qc.QueueRole = 'MT' AND qc.ClusterGroupId_Publish IN (@ClusterGroupId, 'ANY')
				--AND NOT EXISTS (SELECT 1 FROM ms.AccountMeta am WHERE am.CustomerType IN ('W', 'E') AND am.AccountId = a.AccountId)
		) rabbit_defcluster_lt
	ORDER BY ac.AccountId
END
