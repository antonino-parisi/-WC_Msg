-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-03
-- =============================================
-- EXEC rt.RoutingGroupTier_LoadAll
CREATE PROCEDURE [rt].[RoutingGroupTier_LoadAll]
	@LastSyncTimestamp datetime = NULL
AS
BEGIN

	--IF HOST_NAME() IN ('75227f7a7fce','0c35a3f73f37','0d9f7a013523')
	--BEGIN
	--	SELECT rgt.RoutingGroupTierId, rgt.RoutingGroupId, rgt.Level, rgt.RoutingTierId, rgt.Deleted
	--	FROM rt.RoutingGroupTier rgt
	--	WHERE ((@LastSyncTimestamp IS NULL AND rgt.Deleted = 0) 
	--		OR (@LastSyncTimestamp IS NOT NULL AND rgt.UpdatedAt >= @LastSyncTimestamp))
	--END
	--ELSE
	--BEGIN
	-- Backward compatibility for Morpheus v2. Prev table rt.RoutingGroupTier is not used anymore
		SELECT 
			rt.RoutingTierId AS RoutingGroupTierId, 
			rg.RoutingGroupId, 
			rt.TierLevel AS Level, 
			rt.RoutingTierId, 
			rt.Deleted | rg.Deleted AS Deleted
		FROM rt.RoutingTier rt
			INNER JOIN rt.RoutingGroup rg ON rt.RoutingGroupId = rg.RoutingGroupId
		WHERE ((@LastSyncTimestamp IS NULL AND rt.Deleted = 0 AND rg.Deleted = 0) 
			OR (@LastSyncTimestamp IS NOT NULL AND (
				rt.UpdatedAt >= @LastSyncTimestamp OR rg.UpdatedAt >= @LastSyncTimestamp
			)))
	--END
END
