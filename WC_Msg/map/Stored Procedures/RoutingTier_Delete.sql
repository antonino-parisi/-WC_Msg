-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- =============================================
-- EXEC map.RoutingTier_Delete @RoutingTierId = 234, @UpdatedBy = 123
CREATE PROCEDURE [map].[RoutingTier_Delete]
	@RoutingTierId int,		-- filter
	@UpdatedBy smallint
AS
BEGIN

	-- soft delete of record	
	UPDATE rt.RoutingTier
	SET Deleted = 1
	WHERE RoutingTierId = @RoutingTierId AND Deleted = 0

	--UPDATE rt.RoutingGroupTier
	--SET Deleted = 1
	--WHERE RoutingTierId = @RoutingTierId AND Deleted = 0
END
