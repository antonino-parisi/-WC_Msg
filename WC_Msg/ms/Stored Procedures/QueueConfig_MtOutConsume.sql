
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-11-10
-- Description:	List of queues that must used to consume messages from Suppliers
-- =============================================
--	EXEC [ms].[QueueConfig_MtOutConsume] @Host = 'PRO-SMS3'
--	EXEC ms.DbDependency_DataChanged @Key = 'ms.QueueConfig'
--	EXEC ms.DbDependency_DataChanged @Key = 'dbo.CarrierConnections'
CREATE PROCEDURE [ms].[QueueConfig_MtOutConsume]
	@Host varchar(20) = NULL
AS
BEGIN

	IF @Host IS NULL SET @Host = UPPER(HOST_NAME())
	-- DECLARE @host varchar(20) = 'pro-sms2'
	--IF @Host = 'PRO-SMS3'
		--RETURN;

	SELECT 'pro-rabbit-mtout' AS ConnectionName,
		'mtout_' + IIF(ClassName = 'NozaraConnections.Http.KannelConnection', 'smpp', 'http') + '_' + LOWER(REPLACE(cc.RouteId, ' ', '-')) AS QueueName,
		RouteUid AS ConnUid,
		RouteId AS ConnId,
		cc.Priority,
		cc.BufferSize,
		cc.ThreadCount,
		cc.ClassName,
		cc.ThrottlingRate
	FROM dbo.CarrierConnections cc
	WHERE cc.Active = 1
		--AND ((@Host <> 'PRO-SMS3' and RouteId <> 'Every8D_Test') OR 
		--	(@Host = 'PRO-SMS3' /*AND (RouteId like '%_sim' or RouteId like '%_std' or RouteId = 'PLDT_SUN_DIR')*/))

END
