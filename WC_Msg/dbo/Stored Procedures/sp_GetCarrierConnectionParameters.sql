-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-04-01
-- Description:	Get Carrier Connection parameters
-- =============================================
-- EXEC [dbo].[sp_GetCarrierConnectionParameters] @RouteId='profyleNotification_dev'
CREATE PROCEDURE [dbo].[sp_GetCarrierConnectionParameters]
	@RouteId VARCHAR(50)
AS
BEGIN
	
	SELECT LTRIM(RTRIM(RouteId)) as RouteId, LTRIM(RTRIM(ParameterName)) as ParameterName, LTRIM(RTRIM(ParameterValue)) as ParameterValue 
	FROM CarrierConnectionParameters
	WHERE RouteId = @RouteId

	---- TODO: rewrite it ASAP. Only for migration to AWS. Anton 2016-06-28
	--IF ms.ClusterGroup_GetId() = 'AWS-Cluster1'
	--BEGIN
	--	SELECT LTRIM(RTRIM(RouteId)) as RouteId, 
	--		LTRIM(RTRIM(ParameterName)) as ParameterName, 
	--		LTRIM(RTRIM(
	--			REPLACE(
	--			REPLACE(
	--			REPLACE(ParameterValue, 'http://suppliers.smpp.wavecell.io:13013/cgi-bin/sendsms', 'http://suppliers.smpp.int.wavecell.io:13013/cgi-bin/sendsms'),
	--				'http://wms1.wavecell.com/Deliver.aspx','http://sms.api.wavecell.io/Deliver.aspx'),
	--				'c:\\Certs\\', 'C:\Wavecell.Apps\Certificates\')
	--			)) as ParameterValue
	--	FROM CarrierConnectionParameters
	--	WHERE RouteId = @RouteId
	--END
	--ELSE
	--BEGIN
	--	SELECT LTRIM(RTRIM(RouteId)) as RouteId, LTRIM(RTRIM(ParameterName)) as ParameterName, LTRIM(RTRIM(ParameterValue)) as ParameterValue 
	--	FROM CarrierConnectionParameters
	--	WHERE RouteId = @RouteId
	--END
END