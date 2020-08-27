-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-06-28
-- Description:	<Description, ,>
-- =============================================
-- SELECT ms.ClusterGroup_GetByHost (DEFAULT)
-- SELECT ms.ClusterGroup_GetByHost ('PRO-SMS3')
-- SELECT ms.ClusterGroup_GetByHost (NULL)
CREATE FUNCTION [ms].[ClusterGroup_GetByHost] (
	@Host varchar(20) = NULL
)
RETURNS varchar(20)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ClusterGroupId varchar(20)

	IF @Host IS NULL SET @Host = HOST_NAME()

	-- Get ClusterGroupId by Host
	SELECT @ClusterGroupId = ClusterGroupId FROM ms.ClusterGroup WHERE UPPER(Host) = UPPER(@Host)
	
	-- Get default value
	IF (@ClusterGroupId IS NULL)
		SELECT @ClusterGroupId = ClusterGroupId FROM ms.ClusterGroup WHERE Host IS NULL
	
	-- Return the result of the function
	RETURN @ClusterGroupId

END
