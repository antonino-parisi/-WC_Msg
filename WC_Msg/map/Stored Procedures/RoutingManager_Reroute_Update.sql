-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-31
-- =============================================
-- EXEC map.RoutingManager_Reroute_Update @RoutingTierId = 6784, @ConnUid_Old = 69, @ConnUid_New = 19, @UpdateBy = 1
-- SELECT * FROM rt.RoutingTierConn rtc WHERE rtc.RoutingTierId = 6784
CREATE PROCEDURE [map].[RoutingManager_Reroute_Update]
	@RoutingTierId int,		-- Id of Tier that going to be changed
	@ConnUid_Old smallint,	-- current supplier
	@ConnUid_New smallint,	-- new supplier
	@UpdateBy smallint		-- User who performs update
AS
BEGIN

	BEGIN TRY
		BEGIN TRANSACTION

		--DECLARE @RoutingTierId int = 1742
		DECLARE @Successful bit = 0

		--if new ConnUid is already presents in same Tier
		IF EXISTS (
			SELECT 1 FROM rt.RoutingTierConn rtc
			WHERE rtc.RoutingTierId = @RoutingTierId AND rtc.Deleted = 0 AND rtc.ConnUid = @ConnUid_New)
		BEGIN
			UPDATE rtc SET Weight += rtc_old.Weight
			FROM rt.RoutingTierConn rtc
				INNER JOIN rt.RoutingTierConn rtc_old ON rtc.RoutingTierId = rtc_old.RoutingTierId AND rtc_old.Deleted = 0 AND rtc_old.ConnUid = @ConnUid_Old
			WHERE rtc.RoutingTierId = @RoutingTierId AND rtc.Deleted = 0 AND rtc.ConnUid = @ConnUid_New

			IF (@@ROWCOUNT > 0) SET @Successful = 1
			PRINT dbo.Log_ROWCOUNT ('Merged 2 Connections to 1 inside RoutingTier')
		END
		ELSE
		--normal case, just switch ConnUid
		BEGIN
			--hard delete of prev deleted record
			DELETE FROM rtc FROM rt.RoutingTierConn rtc WHERE rtc.RoutingTierId = @RoutingTierId AND rtc.Deleted = 1 AND rtc.ConnUid = @ConnUid_New
		
			--insert into ConnUid as copy of current @ConnUid_Old
			INSERT INTO rt.RoutingTierConn (RoutingTierId, ConnUid, Weight, Deleted, Active)
			SELECT rtc.RoutingTierId, @ConnUid_New AS ConnUid, rtc.Weight, rtc.Deleted, rtc.Active
			FROM rt.RoutingTierConn rtc
			WHERE rtc.RoutingTierId = @RoutingTierId AND rtc.Deleted = 0 AND rtc.ConnUid = @ConnUid_Old

			IF (@@ROWCOUNT > 0) SET @Successful = 1
			PRINT dbo.Log_ROWCOUNT ('Added new ConnUid to RoutingTier')
		END

		-- soft delete of @ConnUid_Old
		UPDATE rtc SET Deleted = 1
		FROM rt.RoutingTierConn rtc
		WHERE rtc.RoutingTierId = @RoutingTierId AND rtc.Deleted = 0 AND rtc.ConnUid = @ConnUid_Old
		PRINT dbo.Log_ROWCOUNT ('Soft delete of prev ConnUid inside RoutingTier')

		-- return to app, if operations was successful
		-- Note: very simple logic now, needs rethinking and improvement
		IF @Successful = 1 SELECT @RoutingTierId AS RoutingTierId

		/* Tier summary update */
		--DECLARE @RoutingTierId int = 1221
		--EXEC map.RoutingTier_UpdateConnSummary @RoutingTierId

		COMMIT TRANSACTION

		RETURN 1
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 		

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
		
		THROW;
	END CATCH

	RETURN 0
END
