-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-11
-- =============================================
-- EXEC ms.QueueConfig_Consuming @QueueRole = 'MT'
-- EXEC ms.QueueConfig_Consuming @QueueRole = 'MT', @Host = 'PRO-SMS4'
-- EXEC ms.DbDependency_DataChanged @Key = 'ms.QueueConfig'
-- SELECT * FROM ms.ClusterGroup
CREATE PROCEDURE [ms].[QueueConfig_Consuming]
	@QueueRole varchar(3) = 'MT',
	@Host varchar(20) = NULL
AS
BEGIN

	IF @Host IS NULL SET @Host = UPPER(HOST_NAME())

	DECLARE @ClusterGroupId varchar(50)
	SET @ClusterGroupId = ms.ClusterGroup_GetByHost(@Host)

	-- FOR testing & incremental rollout purpose 
	--IF (@ClusterGroupId = 'AWS-Cluster4')
-- 	IF (@Host = 'PRO-SMS3')
-- 		--DECLARE @ClusterGroupId varchar(50) = 'AWS-Cluster2', @QueueRole varchar(3) = 'MT'
-- 		SELECT ConnectionName, QueueName, QueueRole, MIN(Priority) AS Priority, MIN(BufferSize) AS BufferSize
-- 		FROM ms.QueueConfig
-- 		WHERE (ClusterGroupId_Consumer IN (@ClusterGroupId) or QueueName = 'mt_l_default')
-- 			AND QueueRole = @QueueRole
-- 		GROUP BY ConnectionName, QueueName, QueueRole
-- 	ELSE
		SELECT ConnectionName, QueueName, QueueRole, MIN(Priority) AS Priority, ThrottlingRate
		FROM ms.QueueConfig
		WHERE ClusterGroupId_Consumer IN ('ANY', @ClusterGroupId) AND QueueRole = @QueueRole
		GROUP BY ConnectionName, QueueName, QueueRole, ThrottlingRate
END
