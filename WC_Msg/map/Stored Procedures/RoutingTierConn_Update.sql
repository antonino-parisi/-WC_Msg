-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- =============================================
-- EXEC map.RoutingTierConn_Update @RoutingTierId = 234, @ConnUid = 123, @Weight = 1, @Active = 1, @UpdatedBy = 123
CREATE PROCEDURE [map].[RoutingTierConn_Update]
	@RoutingTierId int,		-- filter
	@ConnUid smallint,		-- filter
	@Weight tinyint,		-- new value
	@Active bit,			-- new value
	@UpdatedBy smallint
AS
BEGIN

	-- update record	
	UPDATE rt.RoutingTierConn
	SET Weight = @Weight, Active = @Active
	WHERE RoutingTierId = @RoutingTierId AND ConnUid = @ConnUid AND Deleted = 0

	--EXEC map.RoutingTier_UpdateConnSummary @RoutingTierId
END
