-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2020-07-29
-- Description:	Hard delete for records
-- =============================================
CREATE PROCEDURE [ms].[job_HardDeleteOfRecords]
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @ExpiredBefore datetime = DATEADD(DAY, -7, GETUTCDATE())
	-- clean dbo.Account
	DELETE a  
	FROM dbo.Account a
	LEFT JOIN sms.StatSmsLogDaily s ON s.SubAccountUid = a.SubAccountUid
	WHERE s.SubAccountUid IS NULL
	and a.Deleted = 1 AND a.UpdatedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Clean up of dbo.Account done')
	-- clean rt.RoutingView_Operator
	DELETE FROM rvo 
	FROM rt.RoutingView_Operator rvo
		INNER JOIN rt.SupplierConn AS sc ON rvo.RouteUid = sc.ConnUid
	WHERE sc.Deleted = 1 AND sc.UpdatedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Clean up of rt.RoutingView_Operator done')
	-- clean rt.SupplierConn
	DELETE  a
	FROM rt.SupplierConn a
	LEFT JOIN sms.StatSmsLogDaily s ON s.ConnUid = a.ConnUid
	WHERE a.Deleted = 1 AND a.UpdatedAt < @ExpiredBefore
	AND s.ConnUid IS NULL
	PRINT [dbo].[Log_ROWCOUNT] ('Clean up of rt.SupplierConn done')
	-- clean optimus.SenderMaskingRules
	DELETE FROM optimus.SenderMaskingRules
	WHERE Deleted = 1 AND UpdatedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Clean up of optimus.SenderMaskingRules done')
	-- clean rt.CustomerGroupCoverage
	DELETE FROM rt.CustomerGroupCoverage
	WHERE Deleted = 1 AND UpdatedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Clean up of rt.CustomerGroupCoverage done')
	-- clean rt.CustomerGroupSubAccount
	DELETE FROM rt.CustomerGroupSubAccount
	WHERE Deleted = 1 AND UpdatedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Clean up of rt.CustomerGroupSubAccount done')
	-- clean rt.RoutingPlanCoverage
	DELETE FROM rt.RoutingPlanCoverage
	WHERE Deleted = 1 AND UpdatedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Clean up of rt.RoutingPlanCoverage done')
	-- clean rt.RoutingTierConn
	DELETE FROM rt.RoutingTierConn
	WHERE Deleted = 1 AND UpdatedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Clean up of rt.RoutingTierConn done')
	DELETE FROM rtc
	FROM rt.RoutingTierConn rtc
		INNER JOIN rt.RoutingTier AS rt ON rtc.RoutingTierId = rt.RoutingTierId
	WHERE rt.Deleted = 1 AND rt.UpdatedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Clean up of rt.RoutingTierConn done')
	-- clean rt.RoutingTier
	DELETE FROM rt.RoutingTier
	WHERE Deleted = 1 AND UpdatedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Clean up of rt.RoutingTier done')
	-- clean rt.RoutingGroup
	DELETE FROM rt.RoutingGroup
	WHERE Deleted = 1 AND UpdatedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Clean up of rt.RoutingGroup done')
	DELETE FROM rt.PricingPlanCoverage
	WHERE Deleted = 1 AND UpdatedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Clean up of rt.PricingPlanCoverage done')
	DELETE FROM ppc
	FROM rt.PricingPlanCoverage ppc
		INNER JOIN rt.PricingPlan AS pp ON ppc.PricingPlanId = pp.PricingPlanId
	WHERE pp.Deleted = 1 AND pp.UpdatedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Clean up of rt.PricingPlanCoverage done')
	DELETE FROM rt.PricingPlan
	WHERE Deleted = 1 AND UpdatedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Clean up of rt.PricingPlan done')
END
