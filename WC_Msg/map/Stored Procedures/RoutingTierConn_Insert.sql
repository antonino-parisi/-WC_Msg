-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- =============================================
-- EXEC map.RoutingTierConn_Insert @RoutingTierId = 234, @ConnUid = 123, @Weight = 1, @UpdatedBy = 123
CREATE PROCEDURE [map].[RoutingTierConn_Insert]
	@RoutingTierId int,		--filter
	@ConnUid smallint,		-- add
	@Weight tinyint,		-- add
	@UpdatedBy smallint
AS
BEGIN

	BEGIN TRY
		BEGIN TRANSACTION

		--hard delete of prev soft deleted record
		DELETE FROM rt.RoutingTierConn 
		WHERE RoutingTierId = @RoutingTierId AND ConnUid = @ConnUid AND Deleted = 1

		DECLARE @Output TABLE (TierEntryId int)

		-- insert record	
		INSERT INTO rt.RoutingTierConn (RoutingTierId, ConnUid, Weight, Active)
		OUTPUT inserted.TierEntryId INTO @Output (TierEntryId)
		VALUES (@RoutingTierId, @ConnUid, @Weight, 1)

		--EXEC map.RoutingTier_UpdateConnSummary @RoutingTierId

		SELECT TierEntryId FROM @Output

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 		

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
		
		THROW;
	END CATCH
END
