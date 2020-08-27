-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-06-28
-- Description:	Return ApplicationSettings for MessageSphere apps, filtered by ClusterGroup
-- =============================================
-- EXEC ms.ApplicationSettings_GetByHost
CREATE PROCEDURE [ms].[ApplicationSettings_GetByHost]
AS
BEGIN
	DECLARE @ClusterGroupId varchar(20) = ms.ClusterGroup_GetId()

	-- Get settings. Priority to settings with same ClusterGroupId otherwise use default (ClusterGroupId=NULL)
	SELECT Keys.ParameterName, ISNULL(gr.ParameterValue, def.ParameterValue) AS ParameterValue
	FROM 
		(SELECT DISTINCT ParameterName FROM ms.ApplicationSettings2) Keys
		LEFT JOIN ms.ApplicationSettings2 gr ON Keys.ParameterName = gr.ParameterName AND gr.ClusterGroupId = @ClusterGroupId
		LEFT JOIN ms.ApplicationSettings2 def ON Keys.ParameterName = def.ParameterName AND def.ClusterGroupId = 'ANY'
END
