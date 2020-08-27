-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- =============================================
-- EXEC map.RoutingTierConn_Delete @RoutingTierId = 234, @ConnUid = 123, @UpdatedBy = 123
CREATE PROCEDURE [map].[RoutingTierConn_Delete]
	@RoutingTierId int,		-- filter
	@ConnUid smallint,		-- filter
	@UpdatedBy smallint
AS
BEGIN

	-- soft delete of record
	UPDATE rt.RoutingTierConn
	SET Deleted = 1
	WHERE RoutingTierId = @RoutingTierId AND ConnUid = @ConnUid AND Deleted = 0

	--EXEC map.RoutingTier_UpdateConnSummary @RoutingTierId
END
