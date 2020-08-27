
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2020-07-25
-- =============================================
-- EXEC mno.Operator_Ops_Delete @OperatorId = 234001
CREATE PROCEDURE [mno].[Operator_Ops_Delete]
	@OperatorId INT
WITH EXECUTE AS OWNER
AS
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM mno.Operator WHERE OperatorId = @OperatorId)
		THROW 51000, 'Operator not found. Nothing to delete', 1;

	IF EXISTS (
		SELECT TOP 1 1 
		FROM WC_MNO.mno.NumberingPlan AS np
		WHERE np.OperatorId = @OperatorId AND np.Deleted = 0
	)
		THROW 51001, 'Can not delete. Please clean up records in WC_MNO.mno.NumberingPlan first', 1;

	IF EXISTS (
		SELECT TOP 1 1 
		FROM mno.OperatorIdLookup AS oil
		WHERE oil.OperatorId = @OperatorId)
		THROW 51002, 'Can not delete. Please clean up records in MessageSphere.mno.OperatorIdLookup first', 1;

	BEGIN TRY
    	BEGIN TRANSACTION
    		
		DELETE FROM rt.SupplierCostCoverageFuture WHERE OperatorId = @OperatorId;
		UPDATE rt.SupplierCostCoverage SET Deleted = 1 WHERE OperatorId = @OperatorId AND Deleted = 0;
		PRINT dbo.Log_ROWCOUNT('Soft delete from rt.SupplierCostCoverage done')

		DELETE rt.SupplierCostCoverageSID WHERE  OperatorId = @OperatorId AND BillingStart > SYSUTCDATETIME();
		UPDATE rt.SupplierCostCoverageSID SET BillingEnd = SYSUTCDATETIME() WHERE  OperatorId = @OperatorId AND BillingEnd > SYSUTCDATETIME() AND BillingStart < SYSUTCDATETIME();
		
		UPDATE optimus.SenderMaskingRules SET Deleted = 1 WHERE OperatorId = @OperatorId AND Deleted = 0
		PRINT dbo.Log_ROWCOUNT('Soft delete from optimus.SenderMaskingRules done')

		DELETE optimus.MessageBodyPrefixRules WHERE OperatorId = @OperatorId
		PRINT dbo.Log_ROWCOUNT('Hard delete from optimus.MessageBodyPrefixRules done')

		-- deprecated morph.Routing*
		DELETE rrf 
		FROM morph.RoutingRuleFallback rrf
			INNER JOIN morph.RoutingRule AS rr ON rrf.SubRuleId = rr.SubRuleId
			INNER JOIN morph.Routing AS r ON rr.RuleId = r.RuleId
		WHERE r.OperatorId = @OperatorId
		
		DELETE rr
		FROM morph.RoutingRule AS rr
			INNER JOIN morph.Routing AS r ON rr.RuleId = r.RuleId
		WHERE r.OperatorId = @OperatorId
		
		DELETE morph.Routing WHERE OperatorId = @OperatorId
		PRINT dbo.Log_ROWCOUNT('Hard delete from morph.Routing* (deprecated) done')

		DELETE FROM rt.RoutingMeta WHERE OperatorId = @OperatorId
		DELETE FROM rt.RoutingView_Operator WHERE OperatorId = @OperatorId
		DELETE FROM rt.RoutingView_Customer WHERE OperatorId = @OperatorId
		PRINT dbo.Log_ROWCOUNT('Hard delete in rt.RoutingView* done')

		DELETE FROM ms.FeatureFilter_PriceOnDelivery WHERE OperatorId = @OperatorId
		DELETE FROM ms.FeatureFilter_SMSCDLR WHERE OperatorId = @OperatorId
		DELETE FROM ms.FeatureFilter_SmsRouter WHERE OperatorId = @OperatorId
		PRINT dbo.Log_ROWCOUNT('Hard delete in ms.FeatureFilter* done')

		DELETE FROM rt.SupplierOperatorConfig WHERE OperatorId = @OperatorId
		PRINT dbo.Log_ROWCOUNT('Hard delete in rt.SupplierOperatorConfig done');

		DELETE FROM rt.InboundCostCoverage  WHERE MSISDNOperatorId = @OperatorId AND BillingStart > SYSUTCDATETIME()
		DELETE FROM rt.InboundPriceCoverage WHERE MSISDNOperatorId = @OperatorId AND BillingStart > SYSUTCDATETIME()
		UPDATE rt.InboundCostCoverage  SET BillingEnd = SYSUTCDATETIME() WHERE MSISDNOperatorId = @OperatorId AND BillingEnd > SYSUTCDATETIME() AND BillingStart < SYSUTCDATETIME()
		UPDATE rt.InboundPriceCoverage SET BillingEnd = SYSUTCDATETIME() WHERE MSISDNOperatorId = @OperatorId AND BillingEnd > SYSUTCDATETIME() AND BillingStart < SYSUTCDATETIME()
		PRINT dbo.Log_ROWCOUNT('Adjusted BillingEnd in rt.InboundPriceCoverage, rt.InboundCostCoverage');

		UPDATE rt.RoutingPlanCoverage SET Deleted = 1 WHERE OperatorId = @OperatorId AND Deleted = 0
		UPDATE rt.PricingPlanCoverage SET Deleted = 1 WHERE OperatorId = @OperatorId AND Deleted = 0
		UPDATE rt.CustomerGroupCoverage SET Deleted = 1 WHERE OperatorId = @OperatorId AND Deleted = 0
		UPDATE rt.RoutingCustom SET Deleted = 1 WHERE OperatorId = @OperatorId AND Deleted = 0
		PRINT dbo.Log_ROWCOUNT('Soft delete from rt.*Coverage done')

		-- ** WC_MNO **
		UPDATE WC_MNO.mno.MSISDNData 
		SET ExpiringAt = SYSUTCDATETIME(), UpdatedAt = SYSUTCDATETIME() 
		WHERE OperatorId = @OperatorId
		PRINT dbo.Log_ROWCOUNT('Soft delete from WC_MNO.mno.MSISDNData done')

		UPDATE WC_MNO.mno.HlrProvider
		SET DELETED = 1, UpdatedAt = SYSUTCDATETIME() 
		WHERE NPOperatorId = @OperatorId
		PRINT dbo.Log_ROWCOUNT('Soft delete from WC_MNO.mno.HlrProvider done')

		-- *** Tada, and finally ... ***
		IF NOT EXISTS (SELECT TOP 1 1 FROM sms.StatSmsLogDaily AS ssld WHERE ssld.OperatorId = @OperatorId)
		BEGIN
			DELETE FROM WC_MNO.mno.Operator WHERE OperatorId = @OperatorId
			DELETE FROM mno.Operator WHERE OperatorId = @OperatorId
			PRINT dbo.Log_ROWCOUNT('Hard delete in mno.Operator done. Reason: Usage never happened')
		END
		ELSE
		BEGIN
			UPDATE WC_MNO.mno.Operator SET Active = 0 WHERE OperatorId = @OperatorId
			UPDATE mno.Operator SET Active = 0 WHERE OperatorId = @OperatorId
			PRINT dbo.Log_ROWCOUNT('Soft delete in mno.Operator done. Reason: There is usage in Stats for this Operator')
		END

    	COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
    	PRINT 
    		'Transaction rolled back. Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
      		', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
      		', State ' + CONVERT(varchar(5), ERROR_STATE()) +
      		', Line ' + CONVERT(varchar(5), ERROR_LINE())
      
    	PRINT ERROR_MESSAGE();
      
      	IF XACT_STATE() <> 0 BEGIN
    		ROLLBACK TRANSACTION
      	END
    END CATCH;
	
END
