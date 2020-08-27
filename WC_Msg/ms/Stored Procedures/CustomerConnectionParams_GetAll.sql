-- =============================================
-- Author:		Igor Valyanky
-- Create date: 2018-01-16
-- Description:	Get Customer Connection parameters
-- =============================================
CREATE PROCEDURE [ms].[CustomerConnectionParams_GetAll]
AS
BEGIN
	
	SELECT p.CustomerConnectionId, p.ParameterName, p.ParameterValue 
	FROM CustomerConnectionParameters AS p
		JOIN dbo.CustomerConnections AS c ON p.CustomerConnectionId = c.CustomerConnectionId
	WHERE c.Active = 1
END
