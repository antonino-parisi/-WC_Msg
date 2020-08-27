-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- =============================================
-- EXEC map.RoutingGroup_Update @RoutingGroupId = 234, @RoutingGroupName = 'new name', @UpdatedBy = 123
CREATE PROCEDURE [map].[RoutingGroup_Update]
	@RoutingGroupId int,		-- filter
	@RoutingGroupName nvarchar(100),
	@UpdatedBy smallint
AS
BEGIN

	UPDATE rt.RoutingGroup
	SET RoutingGroupName = @RoutingGroupName
	WHERE RoutingGroupId = @RoutingGroupId AND Deleted = 0

END
