-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2020-05-20
-- =============================================
-- EXEC ms.QueueConfig_MtIn
-- EXEC ms.DbDependency_DataChanged @Key = 'ms.QueueConfig'
-- SELECT * FROM ms.ClusterGroup
CREATE PROCEDURE [ms].[QueueConfig_MtIn]
	@Host varchar(20) = NULL
AS
BEGIN

	IF @Host IS NULL SET @Host = UPPER(HOST_NAME())

	--DECLARE @ClusterGroupId varchar(50)
	--SET @ClusterGroupId = 'ANY'--ms.ClusterGroup_GetByHost(@Host)

	SELECT ConnectionName, QueueName, QueueRole, [Priority], ThrottlingRate, SubAccountUid
	FROM ms.QueueConfig
	WHERE 
		ClusterGroupId_Consumer IN ('ANY'/*, @ClusterGroupId*/) AND 
		QueueRole = 'MT'
END
