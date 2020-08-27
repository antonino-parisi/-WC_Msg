-- =============================================
-- Author:		Igor Valyansy	
-- Create date: 2018-10-19
-- Description:	Get queue configuration for all IPM queues
-- =============================================
-- EXEC ms.DbDependency_DataChanged @Key = 'ipm.QueueConfig'
CREATE PROCEDURE [ms].[QueueConfig_Ipm]
	@Host varchar(20) = NULL
AS
BEGIN
	DECLARE @ClusterGroupId varchar(50)
	SET @ClusterGroupId = ms.ClusterGroup_GetByHost(@Host)
​
	-- IF UPPER(HOST_NAME()) NOT IN ('PRO-SMS3', 'MSG-SG-A1') RETURN
	-- IF UPPER(HOST_NAME()) NOT IN ('PRO-SMS5') RETURN
​
	SELECT 
		ConnectionName, 
		QueueName, 
		QueueRole, 
		[Priority],
		ThreadCount,
		SubAccountUid,
		ThrottlingRate
	FROM ipm.QueueConfig
	WHERE ClusterGroupId_Consumer IN ('ANY', @ClusterGroupId)
	
	UNION
	
	SELECT DISTINCT
		'pro-rabbit-ipm' AS ConnectionName,
		'ipmin_' + sa.SubAccountId AS QueueName,
		'IPMIN' AS QueueRole,
		10 AS [Priority],
		5 AS ThreadCount,
		cf.SubAccountUid,
		0 AS ThrottlingRate
	FROM ipm.ChannelFallback AS cf
		INNER JOIN ms.SubAccount AS sa ON cf.SubAccountUid = sa.SubAccountUid
		INNER JOIN ipm.Channel AS c ON cf.ChannelId = c.ChannelId
    WHERE cf.IsTrial = 0
		AND c.ChannelType = 'WA'
		AND c.StatusId = 'A'
		AND cf.SubAccountUid NOT IN (
			SELECT DISTINCT SubAccountUid 
			FROM ipm.QueueConfig AS qc 
			WHERE QueueRole = 'IPMIN' AND qc.SubAccountUid IS NOT NULL)
​
	UNION
	
	SELECT DISTINCT
		'pro-rabbit-ipm' AS ConnectionName,
		'ipmout_' + sa.SubAccountId AS QueueName,
		'IPMOUT' AS QueueRole,
		10 AS [Priority],
		5 AS ThreadCount,
		cf.SubAccountUid,
		0 AS ThrottlingRate
	FROM ipm.ChannelFallback AS cf
		INNER JOIN ms.SubAccount AS sa ON cf.SubAccountUid = sa.SubAccountUid
		INNER JOIN ipm.Channel AS c ON cf.ChannelId = c.ChannelId
    WHERE cf.IsTrial = 0
		AND c.ChannelType = 'WA'
		AND c.StatusId = 'A'
		AND cf.SubAccountUid NOT IN (
			SELECT DISTINCT SubAccountUid 
			FROM ipm.QueueConfig AS qc 
			WHERE QueueRole = 'IPMOUT' AND qc.SubAccountUid IS NOT NULL)
	
END
