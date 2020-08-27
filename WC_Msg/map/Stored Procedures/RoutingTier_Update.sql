-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- Description: this SP allows to
--		- Rename TierName
--		- Change TierLevel
--		- Activate / Suspend tier
-- =============================================
-- EXEC map.RoutingTier_Update @RoutingTierId = 234, @RoutingTierName = 'new name', @UpdatedBy = 123
CREATE PROCEDURE [map].[RoutingTier_Update]
	@RoutingTierId int,		-- filter
	@TierLevel tinyint = NULL,
	@RoutingTierName nvarchar(100) = NULL,
	@RoutingTierStatus bit = NULL,		-- NULL - do not change current value, 1/0 - suspend or activate tier
	@UpdatedBy smallint
AS
BEGIN

	--DECLARE @ToRecalcCurrentLevel bit = 0

	IF @RoutingTierName IS NOT NULL
		UPDATE rt.RoutingTier
		SET RoutingTierName = @RoutingTierName
		WHERE RoutingTierId = @RoutingTierId AND Deleted = 0

	IF @TierLevel IS NOT NULL
	BEGIN
		--delete prev soft deleted record, if exist
		--DELETE FROM rgtPrev
		--FROM rt.RoutingGroupTier rgtPrev
		--	INNER JOIN rt.RoutingGroupTier rgtNew 
		--	ON rgtPrev.RoutingGroupId = rgtNew.RoutingGroupId AND rgtPrev.Level = @TierLevel AND rgtPrev.Deleted = 1
		--WHERE rgtNew.RoutingTierId = @RoutingTierId AND rgtNew.Deleted = 0
		
		----update tier level - schema v1
		--UPDATE rt.RoutingGroupTier
		--SET Level = @TierLevel
		--WHERE RoutingTierId = @RoutingTierId 
		--	AND Deleted = 0
		--	AND Level <> @TierLevel
		
		--update tier level - schema v2
		-- this command triggers other dependant changes
		UPDATE rt.RoutingTier
		SET TierLevel = @TierLevel
		WHERE RoutingTierId = @RoutingTierId
			AND Deleted = 0
			AND TierLevel <> @TierLevel

	END

	-- Tier Suspend/Unsuspend logic
	IF @RoutingTierStatus IS NOT NULL
	BEGIN
		-- change 'Active' status for all Tier connections
		UPDATE rt.RoutingTierConn 
		SET Active = @RoutingTierStatus
		WHERE RoutingTierId = @RoutingTierId AND Deleted = 0 AND Active <> @RoutingTierStatus

		--IF @@ROWCOUNT > 0 SET @ToRecalcCurrentLevel = 1
	END

END
