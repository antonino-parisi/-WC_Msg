
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2020-07-10
-- =============================================
-- EXEC rt.[SupplierConn_Ops_Delete] @ConnId = 'HiMedia'
CREATE PROCEDURE [rt].[SupplierConn_Ops_Delete]
	@ConnId VARCHAR(50)
AS
BEGIN

	DECLARE @ConnUid INT;

	SELECT @ConnUid = ConnUid FROM rt.SupplierConn AS sc WHERE sc.ConnId = @ConnId;
	IF @ConnUid IS NULL 
		THROW 51000, 'Connection not found', 1;

	IF EXISTS (
		SELECT TOP 1 1 
		FROM rt.vwRoutingPlanCoverageAllConn AS rpc 
		WHERE rpc.ConnUid = @ConnUid AND rpc.RP_Deleted = 0 AND rpc.Deleted = 0 AND rpc.RTC_Deleted = 0 AND rpc.RT_Deleted = 0
	)
		THROW 51001, 'Can not delete. Remove Connection from Routing configuration first', 1;

	IF EXISTS (
		SELECT TOP 1 1 
		FROM ms.VirtualNumber AS vn
		WHERE VN.SMS_ConnUid = @ConnUid
	)
		THROW 51002, 'Can not delete. Connection is used in VirtualNumber', 1;

	BEGIN TRY
    	BEGIN TRANSACTION
    		
		UPDATE rt.SupplierConn 
		SET Deleted = 1, UpdatedAt = SYSUTCDATETIME()
		WHERE ConnUid = @ConnUid AND Deleted = 0;
		PRINT dbo.Log_ROWCOUNT('Soft delete from rt.SupplierConn done')

		-- following operation cancelled as it can remove cost data for past ~1 month
		--UPDATE rt.SupplierCostCoverage
		--SET Deleted = 1, UpdatedAt = SYSUTCDATETIME()
		--WHERE RouteUid = @ConnUid AND Deleted = 0;
		--PRINT dbo.Log_ROWCOUNT('Soft delete from rt.SupplierCostCoverage done')

		DELETE FROM dbo.TrafficErrorCode where RouteId = @ConnId
		PRINT dbo.Log_ROWCOUNT('Hard delete from dbo.TrafficErrorCode done')

		UPDATE optimus.SenderMaskingRules SET DELETED = 1 WHERE RouteId = @ConnId
		PRINT dbo.Log_ROWCOUNT('Soft delete from optimus.SenderMaskingRules done')

		DELETE optimus.MessageBodyPrefixRules WHERE RouteId = @ConnId
		PRINT dbo.Log_ROWCOUNT('Hard delete from optimus.MessageBodyPrefixRules done')

		--UPDATE dbo.CarrierConnections SET ACTIVE = 0 WHERE RouteUid = @ConnUid;
		DELETE FROM dbo.CarrierConnectionParameters WHERE RouteId = @ConnId;
		DELETE FROM dbo.CarrierConnections WHERE RouteUid = @ConnUid;
		PRINT dbo.Log_ROWCOUNT('Hard delete in dbo.CarrierConnections, dbo.CarrierConnectionParameters done')

		UPDATE ms.CarrierMeta SET IsActive = 0 WHERE RouteId = @ConnId
		PRINT dbo.Log_ROWCOUNT('Record in ms.CarrierMeta deactivated')

		DELETE FROM ms.FeatureFilter_Optimus WHERE RouteUid = @ConnUid
		DELETE FROM ms.FeatureFilter_SMSCDLR WHERE RouteId = @ConnId
		PRINT dbo.Log_ROWCOUNT('FeatureFilters deleted')

		-- Delete relevant CSG subaccount
		DECLARE @CSGSubAccount VARCHAR(50) = 'csg_' + @ConnId;
		BEGIN TRY
			EXEC ms.SubAccount_Ops_Delete @AccountId = '1CSGtest1', @SubAccountId = @CSGSubAccount;
			PRINT dbo.Log_ROWCOUNT('Delete of CSG subaccount done')
		END TRY
		BEGIN CATCH
			PRINT dbo.Log_ROWCOUNT('Relevant CSG subaccount is not found.')
		END CATCH

		PRINT 'Operation completed successfully'

    	COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    	PRINT 
    		'(!) Operation cancelled. Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
      		', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
      		', State ' + CONVERT(varchar(5), ERROR_STATE()) +
      		', Line ' + CONVERT(varchar(5), ERROR_LINE())
      
    	PRINT ERROR_MESSAGE();
      
      	IF XACT_STATE() <> 0 BEGIN
    		ROLLBACK TRANSACTION
      	END
    END CATCH;
	
END
