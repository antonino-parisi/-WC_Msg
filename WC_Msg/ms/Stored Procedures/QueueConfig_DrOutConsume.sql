-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-05-09
-- Description:	List of DROUT queues to listen
-- =============================================
--	EXEC ms.[QueueConfig_DrOutConsume] @Host = 'PRO-SMS3'
--	EXEC ms.DbDependency_DataChanged @Key = 'dbo.CustomerRouting'
CREATE PROCEDURE [ms].[QueueConfig_DrOutConsume]
	@Host varchar(20) = NULL
AS
BEGIN

	DECLARE @ClusterGroupId varchar(50)
	SET @ClusterGroupId = ms.ClusterGroup_GetByHost(@Host)

	IF @Host IS NULL SET @Host = HOST_NAME()
	--IF @Host = 'PRO-SMS3'
	--	RETURN;
	--IF @Host <> 'PRO-SMS2' RETURN

	SELECT 'pro-rabbit-drout' AS ConnectionName, 
		'drout_http_' + LOWER(REPLACE(sa.SubAccountId, ' ', '-')) AS QueueName, 
		'DROUT' AS QueueRole,
		sa.SubAccountUid, sa.SubAccountId, 
		ISNULL(q.Priority, 2) AS Priority, 
		ISNULL(q.BufferSize, 5) AS BufferSize,
		ISNULL(q.ThreadCount, 5) AS ThreadCount
	FROM dbo.Account sa
		INNER JOIN dbo.CustomerRouting cr ON cr.AccountId = sa.AccountId
		INNER JOIN dbo.CustomerConnections cc ON cr.CustomerConnectionId = cc.CustomerConnectionId AND cc.Active = 1
		-- TODO: This block better to rewrite. 
		--		 Direct access to stats table is not recommended
		--INNER JOIN (
		--	SELECT st.SubAccountUid, SUM(st.SmsCountTotal) AS VolumeLast7d
		--	FROM sms.StatSmsLogDaily st (NOLOCK)
		--	WHERE st.Date >= DATEADD(DAY, -7, SYSUTCDATETIME())
		--	GROUP BY st.SubAccountUid
		--) st ON st.SubAccountUid = sa.SubAccountUid
		LEFT JOIN (
			SELECT q.SubAccountUid, 
				MIN(q.Priority) AS Priority, 
				MIN(q.BufferSize) AS BufferSize, 
				MIN(ThreadCount) AS ThreadCount
			FROM ms.QueueConfig q 
			WHERE q.QueueRole = 'DROUT' AND q.ClusterGroupId_Consumer IN ('ANY', @ClusterGroupId)
			GROUP BY q.SubAccountUid
		) q ON sa.SubAccountUid = q.SubAccountUid
	WHERE sa.Active = 1 AND sa.Deleted = 0
	UNION 
	SELECT q.ConnectionName, 
		q.QueueName, 
		q.QueueRole,
		q.SubAccountUid, NULL AS SubAccountId, 
		q.Priority, 
		q.BufferSize,
		q.ThreadCount
	FROM ms.QueueConfig q 
	WHERE q.QueueRole = 'DROUT' 
		AND q.ClusterGroupId_Consumer IN ('ANY', @ClusterGroupId)
		AND q.SubAccountUid IS NULL
			
END