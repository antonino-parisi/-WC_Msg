-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-01-16
-- Description:	Data for RoutingMatrix. List of all active CustomerConnections
-- =============================================
CREATE PROCEDURE [ms].[CustomerConnections_GetAll]
AS
BEGIN
	SELECT CustomerConnectionId
		,ConnectionType
		,ClassName
		,TrashOnFail
		,Connection_MO_Queue
		,Connection_DR_Queue
		,DRThreadCount
		,MOThreadCount
	FROM dbo.CustomerConnections 
	WHERE Active = 1

END
