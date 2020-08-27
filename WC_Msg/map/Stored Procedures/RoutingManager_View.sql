
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-31
-- Updated By:  Nathanael Hinay
-- Date Updated: 2018-10-1
-- Added support for null operator
-- =============================================
-- EXEC map.RoutingManager_View @Country = 'TH', @OperatorId = 520001
CREATE PROCEDURE [map].[RoutingManager_View]
	@Country char(2),
	@OperatorId int	-- if value = NULL, means record for <ANY> operator
AS
BEGIN

	DECLARE @Output TABLE (
		Country char(2),
		OperatorId int,
		ConnUid smallint,
		--ConnId varchar(50),
		TargetType varchar(10),
		TargetId int,
		TargetName nvarchar(100),
		TierLevel tinyint,
		Active bit,
		CostEUR decimal(12,6),
		CostLocal decimal(12,6),
		CostLocalCurrency char(3)
	)

	INSERT INTO @Output (Country, OperatorId, ConnUid, TargetType, TargetId, TargetName, TierLevel, Active, CostEUR, CostLocal, CostLocalCurrency)
	SELECT 
		rpc.Country, 
		rpc.OperatorId, 
		rtc.ConnUid,
		'PLAN' AS TargetType, 
		rp.RoutingPlanId AS TargetId, 
		rp.RoutingPlanName AS TargetName, 
		rt.TierLevel AS Level, 
		rtc.Active, 
		scc.CostEUR, 
		scc.CostLocal, 
		scc.CostLocalCurrency
	FROM rt.RoutingPlanCoverage rpc 
		INNER JOIN rt.RoutingPlan rp ON rpc.RoutingPlanId = rp.RoutingPlanId AND rp.Deleted = 0 AND rpc.Deleted = 0
		INNER JOIN rt.RoutingGroup rg ON rpc.RoutingGroupId = rg.RoutingGroupId AND rg.Deleted = 0
		--INNER JOIN rt.RoutingGroupTier rgt ON rpc.RoutingGroupId = rgt.RoutingGroupId AND rgt.Deleted = 0 AND rgt.Level IN (1, rg.TierLevelCurrent)
		INNER JOIN rt.RoutingTier rt ON rg.RoutingGroupId = rt.RoutingGroupId AND rt.Deleted = 0 AND rt.TierLevel IN (1, rg.TierLevelCurrent)
		INNER JOIN rt.RoutingTierConn rtc ON rtc.RoutingTierId = rt.RoutingTierId AND rtc.Deleted = 0 --need both Active and Suspended statuses
		LEFT JOIN rt.SupplierCostCoverage scc ON scc.RouteUid = rtc.ConnUid AND scc.Country = rpc.Country AND ISNULL(scc.OperatorId, 0) = ISNULL(rpc.OperatorId, 0) AND scc.Deleted = 0 AND scc.SmsTypeId = 1 /*AND scc.EffectiveFrom <= SYSUTCDATETIME() AND scc.EffectiveTo >= SYSUTCDATETIME()*/
	WHERE rpc.Country = @Country
		AND ISNULL(@OperatorId, 0) = ISNULL(rpc.OperatorId, 0)
        --AND ((@OperatorId IS NULL AND rpc.OperatorId IS NULL) OR (@OperatorId IS NOT NULL AND rpc.OperatorId = @OperatorId))
	--ORDER BY rtc.ConnUid
	
	UNION ALL
	
	SELECT 
		rc.Country, 
		rc.OperatorId, 
		rtc.ConnUid, 
		'SUBACCOUNT' AS TargetType, 
		rc.SubAccountUid AS TargetId, 
		a.SubAccountId AS TargetName, 
		rt.TierLevel AS Level, 
		rtc.Active, 
		scc.CostEUR, 
		scc.CostLocal, 
		scc.CostLocalCurrency
	FROM rt.RoutingCustom rc
		INNER JOIN rt.RoutingGroup rg ON rc.RoutingGroupId = rg.RoutingGroupId AND rg.Deleted = 0 AND rc.Deleted = 0
		--INNER JOIN rt.RoutingGroupTier rgt ON rc.RoutingGroupId = rgt.RoutingGroupId AND rgt.Deleted = 0 AND rgt.Level IN (1, rg.TierLevelCurrent)
		INNER JOIN rt.RoutingTier rt ON rg.RoutingGroupId = rt.RoutingGroupId AND rt.Deleted = 0 AND rt.TierLevel IN (1, rg.TierLevelCurrent)
		INNER JOIN rt.RoutingTierConn rtc ON rtc.RoutingTierId = rt.RoutingTierId AND rtc.Deleted = 0
		LEFT JOIN rt.SupplierCostCoverage scc ON scc.RouteUid = rtc.ConnUid AND scc.Country = rc.Country AND ISNULL(scc.OperatorId, 0) = ISNULL(rc.OperatorId, 0) AND scc.Deleted = 0 AND scc.SmsTypeId = 1/*AND scc.EffectiveFrom <= SYSUTCDATETIME() AND scc.EffectiveTo >= SYSUTCDATETIME()*/
		INNER JOIN dbo.Account a ON a.SubAccountUid = rc.SubAccountUid
	WHERE rc.Country = @Country
		AND ISNULL(@OperatorId, 0) = ISNULL(rc.OperatorId, 0)
        --AND (@OperatorId IS NULL OR (@OperatorId IS NOT NULL AND rc.OperatorId = @OperatorId))
	--ORDER BY rtc.ConnUid

	SELECT DISTINCT o.Country, o.OperatorId, o.ConnUid, sc.ConnId, o.CostEUR, o.CostLocal, o.CostLocalCurrency
	FROM @Output o
		LEFT JOIN rt.SupplierConn sc ON o.ConnUid = sc.ConnUid

	SELECT ConnUid, TargetType, TargetId, TargetName, TierLevel, Active
	FROM @Output

END

