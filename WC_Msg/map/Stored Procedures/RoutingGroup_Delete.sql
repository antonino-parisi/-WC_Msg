-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- =============================================
-- EXEC map.RoutingGroup_Delete @RoutingGroupId = 234, @UpdatedBy = 123
CREATE PROCEDURE [map].[RoutingGroup_Delete]
	@RoutingGroupId int,		-- filter
	@UpdatedBy smallint
AS
BEGIN

	-- soft delete of record	
	UPDATE rt.RoutingGroup
	SET Deleted = 1
	WHERE RoutingGroupId = @RoutingGroupId AND Deleted = 0

END
