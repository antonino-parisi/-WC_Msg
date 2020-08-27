
CREATE PROCEDURE [dbo].[sp_GetApplicationSettings]
AS
	SELECT ParameterName, ParameterValue 
	FROM ms.ApplicationSettings2
	WHERE ClusterGroupId = 'ANY'


