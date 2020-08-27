-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017/10/06
-- Description:	Returns list of Kannel status page urls for Morpheus app (to check data on this pages)
-- =============================================
-- EXEC rt.KannelStatusUrl_Get
CREATE PROCEDURE rt.[KannelStatusUrl_Get]
	@LastSyncTimeStamp datetime2(2) = NULL
AS
BEGIN
	SELECT DISTINCT RANK() OVER (ORDER BY ccp.ParameterValue) AS id, REPLACE(ccp.ParameterValue, ':13013/cgi-bin/sendsms', ':13000/status.xml?password=W4v3c3ll1') AS Url
	FROM [dbo].[CarrierConnectionParameters] ccp
		INNER JOIN [dbo].[CarrierConnections] cc ON cc.RouteId = ccp.RouteId
	WHERE [ParameterName] = 'ConnectionAddress'
		AND ClassName = 'NozaraConnections.Http.KannelConnection'
		AND ParameterValue like 'http://[0-9]%'
		AND (@LastSyncTimestamp IS NULL OR (@LastSyncTimestamp IS NOT NULL AND cc.UpdatedAt >= @LastSyncTimestamp))
END
