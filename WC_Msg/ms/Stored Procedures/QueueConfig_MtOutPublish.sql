-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-11-10
-- Description:	List of queues that must used to publish messages to Suppliers
-- =============================================
CREATE PROCEDURE [ms].[QueueConfig_MtOutPublish]
AS
BEGIN

	SELECT 'ANY' AS ConnectionName,
		'mtout_' + IIF(ClassName = 'NozaraConnections.Http.KannelConnection', 'smpp', 'http') + '_' + LOWER(REPLACE(cc.RouteId, ' ', '-')) AS QueueName, 
		RouteUid AS ConnUid, RouteId AS ConnId
	FROM dbo.CarrierConnections cc
	WHERE cc.Active = 1

END
