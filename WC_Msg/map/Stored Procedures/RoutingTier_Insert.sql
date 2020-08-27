-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- =============================================
-- EXEC map.RoutingTier_Insert @RoutingGroupId = 12, @UpdatedBy = 123
CREATE PROCEDURE [map].[RoutingTier_Insert]
	@RoutingGroupId int,					-- to which RoutingGroup assign newly created RoutingTierId
	@TierLevel tinyint = NULL,				-- optional, default = add as last Tier inside RoutingGroup
	@RoutingTierName nvarchar(100) = NULL,	-- optional
	@UpdatedBy smallint						-- user who performs operation
AS
BEGIN

	IF (@TierLevel IS NULL)
	BEGIN
		SELECT @TierLevel = MAX(TierLevel) + 1 
		FROM rt.RoutingTier 
		WHERE RoutingGroupId = @RoutingGroupId AND Deleted = 0
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT 1 FROM rt.RoutingTier WHERE RoutingGroupId = @RoutingGroupId AND TierLevel = @TierLevel AND Deleted = 0)
			THROW 51000, 'Requested TierLevel is occupied already', 1;
	END

	BEGIN TRY
		BEGIN TRANSACTION

		--hard delete of previous
		--DELETE FROM rt.RoutingGroupTier WHERE RoutingGroupId = @RoutingGroupId AND Deleted = 1 AND Level = @TierLevel

		--insert
		DECLARE @OutputRt TABLE (RoutingTierId int)
	
		INSERT INTO rt.RoutingTier (RoutingTierName, CostCalculated, CostCurrency, ConnSummary, RoutingGroupId, TierLevel)
		OUTPUT inserted.RoutingTierId INTO @OutputRt(RoutingTierId)
		VALUES (@RoutingTierName, NULL, 'EUR', NULL, @RoutingGroupId, @TierLevel)

		--INSERT INTO rt.RoutingGroupTier (RoutingTierId, RoutingGroupId, Level)
		----OUTPUT inserted.RoutingTierId, inserted.RoutingGroupId, inserted.Level AS TierLevel -- main output from SP
		--SELECT TOP 1 RoutingTierId, @RoutingGroupId, @TierLevel
		--FROM @OutputRt

		-- return same results outside
		SELECT TOP 1 RoutingTierId, @RoutingGroupId AS RoutingGroupId, @TierLevel AS TierLevel
		FROM @OutputRt

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 		

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
		
		THROW;
	END CATCH
END
