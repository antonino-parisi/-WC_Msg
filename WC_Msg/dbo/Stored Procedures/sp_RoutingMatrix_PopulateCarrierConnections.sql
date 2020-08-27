-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-31
-- Description:	Data for RoutingMatrix. List of all active CarrierConnections
-- =============================================
CREATE PROCEDURE [dbo].[sp_RoutingMatrix_PopulateCarrierConnections]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT LTRIM(RTRIM(RouteId)) as RouteId, ConnectionType, AssemblyName, ClassName, LogFolder, LogLevel, TrashOnConnectionFail, TrashOnMessageFail, Route_MT_Queue, ThreadCount
	FROM CarrierConnections
	WHERE Active = 1

END

