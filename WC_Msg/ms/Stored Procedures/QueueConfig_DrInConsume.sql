-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-05-09
-- Description:	List of DR-IN queues to listen
-- =============================================
--	EXEC ms.[QueueConfig_DrInConsume] @Host = 'PRO-SMS2'
--	EXEC ms.DbDependency_DataChanged @Key = 'dbo.CarrierConnections'
CREATE PROCEDURE [ms].[QueueConfig_DrInConsume]
	@Host varchar(20) = NULL
AS
BEGIN

	--DECLARE @ClusterGroupId varchar(50)
	--SET @ClusterGroupId = ms.ClusterGroup_GetByHost(@Host)
	
	IF @Host IS NULL SET @Host = HOST_NAME()

	--IF @Host = 'PRO-SMS3'
		--RETURN;

	SELECT 'pro-rabbit-drin' AS ConnectionName, 
		'drin_' + IIF(cc.ClassName = 'NozaraConnections.Http.KannelConnection', 'smpp', 'http') + '_' + LOWER(REPLACE(cc.RouteId, ' ', '-')) AS QueueName, 
		'DRIN' AS QueueRole,
		cc.RouteUid AS ConnUid, cc.RouteId AS ConnId, 
		10 AS Priority, 
		50 AS BufferSize,
		5 AS ThreadCount
	FROM dbo.CarrierConnections cc
	WHERE cc.Active = 1
	UNION
	-- default queue for undefined connections (when route is not found)
	SELECT 'pro-rabbit-drin' AS ConnectionName, 
		'drin_http_default' AS QueueName, 
		'DRIN' AS QueueRole,
		NULL AS ConnUid, NULL AS ConnId, 
		3 AS Priority, 
		10 AS BufferSize,
		5 AS ThreadCount
END