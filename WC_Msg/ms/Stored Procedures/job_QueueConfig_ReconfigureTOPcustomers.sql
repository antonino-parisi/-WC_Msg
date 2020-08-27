

-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-05-26
-- =============================================
-- SAMPLE:
-- EXEC ms.job_QueueConfig_ReconfigureTOPcustomers
CREATE PROCEDURE [ms].[job_QueueConfig_ReconfigureTOPcustomers]
AS
BEGIN

	-- clean up of hard deleted subaccounts
	DELETE FROM q
	FROM ms.QueueConfig q 
		LEFT JOIN dbo.Account sa on q.SubAccountUid = sa.SubAccountUid
	WHERE q.SubAccountUid IS NOT NULL and sa.SubAccountUid IS NULL
	PRINT dbo.Log_ROWCOUNT ('Clean up of config for hard-deleted subaccounts')

	-- Add new W & E queues
	INSERT INTO ms.QueueConfig
           ([ConnectionName]
           ,[QueueName]
		   ,ClusterGroupId_Consumer, ClusterGroupId_Publish
           ,[QueueRole]
           ,[Priority]
           ,[BufferSize]
           ,[SubAccountUid])
	SELECT 
		'pro-rabbit-def' as ConnectionName, 
		'mt_' + lower(ISNULL(am.CustomerType, 'l')) + '_' + ltrim(rtrim(lower(a.SubAccountId))) as QueueName, 
		'ANY' AS ClusterGroupId_Consumer, 
		'ANY' AS ClusterGroupId_Publish, 
		'MT' as QueueRole,
		-- default priority based on SubAccount convention
		CASE
			WHEN a.SubAccountId like '%_otp' THEN 13
			WHEN a.SubAccountId like '%_hq' THEN 10
			WHEN a.SubAccountId like '%_mkt' THEN 3
			ELSE 8
		END AS Priority,
		5 AS BufferSize, 
		a.SubAccountUid
	--select *
	FROM ms.AccountMeta am
		INNER JOIN dbo.Account a ON am.AccountId = a.AccountId AND a.Deleted = 0
		LEFT JOIN ms.QueueConfig qc ON 
			qc.SubAccountUid = a.SubAccountUid 
			AND qc.QueueRole = 'MT' -- qc.QueueName = 'mt_' + lower(ISNULL(am.CustomerType, 'l')) + '_' + ltrim(rtrim(lower(a.SubAccountId)))
		--INNER JOIN (
		--	-- volume of traffic in last week by SubAccountUid
		--	SELECT s.SubAccountUid, SUM(s.MsgCountTotal) AS MsgCountTotal
		--	FROM sms.StatSmsLogDaily s (NOLOCK)
		--	WHERE s.Date > GETUTCDATE()-7	/* time frame */
		--	GROUP BY s.SubAccountUid
		--	HAVING SUM(s.MsgCountTotal) >= 500 /* threshold of creating dedicated queue */
		--) s ON s.SubAccountUid = a.SubAccountUid
	WHERE
		qc.QueueName IS NULL
		and am.CustomerType IN ('W', 'E')

	PRINT dbo.Log_ROWCOUNT ('New E&W subaccounts added with own queues')

	--------------------------------------

	--- we have dedicated running queues only for subaccounts 
	--- with existing traffic in last 30 days or if they were created in last 15 days
	UPDATE qc SET
		ClusterGroupId_Consumer = IIF(s.SubAccountUid IS NOT NULL OR sa.Date > GETUTCDATE() - 15, 'ANY', 'NONE'),
		ClusterGroupId_Publish  = IIF(s.SubAccountUid IS NOT NULL OR sa.Date > GETUTCDATE() - 15, 'ANY', 'NONE')
	--select *, IIF(s.SubAccountUid IS NOT NULL OR sa.Date > GETUTCDATE() - 15, 'ANY', 'NONE')
	FROM ms.QueueConfig qc
		--ms.AccountMeta am
		INNER JOIN dbo.Account sa ON qc.SubAccountUid = sa.SubAccountUid AND sa.Deleted = 0
		--LEFT JOIN ms.QueueConfig qc ON qc.SubAccountUid = a.SubAccountUid -- qc.QueueName = 'mt_' + lower(ISNULL(am.CustomerType, 'l')) + '_' + ltrim(rtrim(lower(a.SubAccountId)))
		LEFT JOIN (
			-- volume of traffic in timerange by SubAccountUid
			SELECT s.SubAccountUid
			FROM sms.StatSmsLogDaily s (NOLOCK)
			WHERE s.Date >= GETUTCDATE()-30	/* time frame */
			GROUP BY s.SubAccountUid
		) s ON s.SubAccountUid = qc.SubAccountUid
	WHERE qc.SubAccountUid IS NOT NULL 
		AND qc.ClusterGroupId_Consumer IN ('ANY', 'NONE')
		AND qc.ClusterGroupId_Consumer IN ('ANY', 'NONE')
		AND qc.QueueRole = 'MT'
		AND qc.ClusterGroupId_Consumer <> IIF(s.SubAccountUid IS NOT NULL OR sa.Date > GETUTCDATE() - 15, 'ANY', 'NONE')
		--AND s.SubAccountUid IS NULL

	PRINT dbo.Log_ROWCOUNT ('Queues with no traffic for many dates are ON HOLD or reactive some not used before')
	--------------------------------------
	/*
	--------------------------------------
	DECLARE @TopSubaccounts TABLE (SubAccountUid int primary key)

	INSERT INTO @TopSubaccounts (SubAccountUid)
	SELECT SubAccountUid --, SUM(MsgCountTotal) AS MsgCountTotal
	FROM sms.StatSmsLogDaily
	WHERE Date >= DATEADD(DAY, -7, CAST(GETUTCDATE() AS date))
	GROUP BY SubAccountUid
	HAVING SUM(MsgCountTotal) > 7000 /* threshold */
	
	PRINT dbo.Log_ROWCOUNT ('Received subaccounts with highest amount')


	-- use ALL instances for high-volume subaccounts
	UPDATE q SET ClusterGroupId_Consumer = 'ANY'
	--SELECT * 
	FROM ms.QueueConfig q
		INNER JOIN @TopSubaccounts s ON s.SubAccountUid = q.SubAccountUid
	WHERE q.QueueRole = 'MT' AND q.ClusterGroupId_Consumer = 'AWS-Cluster2'

	PRINT dbo.Log_ROWCOUNT ('Queues switched to ALL working instances')

	-- limit instances for low-volume subaccounts
	UPDATE q SET ClusterGroupId_Consumer = 'AWS-Cluster2'
	--SELECT * 
	FROM ms.QueueConfig q
		LEFT JOIN @TopSubaccounts s ON s.SubAccountUid = q.SubAccountUid
	WHERE q.QueueRole = 'MT' AND q.ClusterGroupId_Consumer = 'ANY'
		AND s.SubAccountUid IS NULL

	PRINT dbo.Log_ROWCOUNT ('Queues switched to limited working instances')
	*/
END
