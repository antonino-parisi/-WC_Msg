
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-11-21
-- Description:	Uploads CarrierConnection configuration for SupplierWorker
-- =============================================
CREATE PROCEDURE [ms].[CarrierConnections_GetAll]
AS
BEGIN
	SELECT c.RouteId AS ConnId, 
		p.ParameterName, 
		p.ParameterValue
	FROM dbo.CarrierConnections AS c
		JOIN dbo.CarrierConnectionParameters AS p ON c.RouteId = p.RouteId
	WHERE c.Active = 1
END
