-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-31
-- Description:	Data for RoutingMatrix. List of all active CustomerConnections
-- =============================================
CREATE PROCEDURE [dbo].[sp_RoutingMatrix_PopulateCustomerConnections]
AS
BEGIN

	SELECT CustomerConnectionId, ConnectionType, AssemblyName, ClassName, LogFolder, LogLevel, TrashOnFail, Connection_MO_Queue, Connection_DR_Queue, DRThreadCount, MOThreadCount
	FROM dbo.CustomerConnections 
	WHERE Active = 1

END
