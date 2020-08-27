

-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-06-28
-- Description:	<Description, ,>
-- =============================================
-- SELECT ms.ClusterGroup_GetId ()
CREATE FUNCTION [ms].[ClusterGroup_GetId] ()
RETURNS varchar(20)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ClusterGroupId varchar(20)

	-- Get ClusterGroupId by Host
	SELECT @ClusterGroupId = ClusterGroupId FROM ms.ClusterGroup WHERE UPPER(Host) = UPPER(HOST_NAME())
	
	-- Get default value
	IF (@ClusterGroupId IS NULL)
		SELECT @ClusterGroupId = ClusterGroupId FROM ms.ClusterGroup WHERE Host IS NULL
	
	-- Return the result of the function
	RETURN @ClusterGroupId

END
