

-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-31
-- Updated By:  Nathanael Hinay
-- Date Updated: 2018-10-02
-- Added support for Operator Any
-- =============================================
-- EXEC map.[RoutingManager_Reroute_ViewImpact] @Country = 'SG', @OperatorId = 525001, @ConnUid_Old = 27, @ConnUid_New = 70
CREATE PROCEDURE [map].[RoutingManager_Reroute_ViewImpact]
	@Country char(2),	--scope of change
	@OperatorId int,	--scope of change
	@ConnUid_Old smallint,	-- current supplier
	@ConnUid_New smallint	-- new supplier
AS
BEGIN
	
	/** 
	TODO: CostCalculated_New is working incorrect. Now it return ConnId cost, not calculated based on summary of all conns in Tier
	**/
	SELECT 
		rpc.Country, 
		rpc.OperatorId, 
		rtc.RoutingTierId, 
		rtc.ConnUid AS ConnUid_Old, 
		scc_new.ConnUid AS ConnUid_New,
		'PLAN' AS TargetType, 
		rp.RoutingPlanId AS TargetId, 
		rp.RoutingPlanName AS TargetName, 
		rt.TierLevel AS TierLevel, 
		rtc.Active AS TierActive, 
		scc.CostEUR AS Cost_Old, 
		ISNULL(rpc.CostCalculated, scc.CostEUR) AS TierCost_Old, 
		scc_new.CostEUR AS Cost_New, scc_new.CostEUR AS TierCost_New,
		NULL AS Price, 
		rpc.CostCurrency AS CompanyCurrency
	FROM rt.RoutingPlanCoverage rpc
		INNER JOIN rt.RoutingPlan rp ON 
			rpc.RoutingPlanId = rp.RoutingPlanId 
			AND rp.Deleted = 0 
			AND rpc.Deleted = 0
		INNER JOIN rt.RoutingGroup rg ON 
			rpc.RoutingGroupId = rg.RoutingGroupId AND rg.Deleted = 0
		--INNER JOIN rt.RoutingGroupTier rgt ON rpc.RoutingGroupId = rgt.RoutingGroupId AND rgt.Deleted = 0 AND rgt.Level IN (1, rg.TierLevelCurrent)
		INNER JOIN rt.RoutingTier rt ON 
			rg.RoutingGroupId = rt.RoutingGroupId 
			AND rt.Deleted = 0 
			AND rt.TierLevel IN (1, rg.TierLevelCurrent)
		INNER JOIN rt.RoutingTierConn_Active rtc ON rtc.RoutingTierId = rt.RoutingTierId
		LEFT JOIN rt.vwSupplierCostCoverage_Active scc ON 
			scc.ConnUid = rtc.ConnUid 
			AND scc.Country = rpc.Country 
			AND ISNULL(scc.OperatorId, 0) = ISNULL(rpc.OperatorId, 0) 
		LEFT JOIN rt.vwSupplierCostCoverage_Active scc_new ON 
			scc_new.ConnUid = @ConnUid_New 
			AND scc_new.Country = rpc.Country 
			AND ISNULL(scc_new.OperatorId, 0) = ISNULL(rpc.OperatorId, 0)
	WHERE rpc.Country = @Country
		AND ISNULL(@OperatorId, 0) = ISNULL(rpc.OperatorId, 0)
        --AND (@OperatorId IS NULL OR (@OperatorId IS NOT NULL AND rpc.OperatorId = @OperatorId))
        AND rtc.ConnUid = @ConnUid_Old
	--ORDER BY rtc.ConnUid
	
	UNION ALL
	
	SELECT 
		rc.Country, 
		rc.OperatorId, 
		rtc.RoutingTierId, 
		rtc.ConnUid AS ConnUid_Old, 
		scc_new.ConnUid AS ConnUid_New,
		'SUBACCOUNT' AS TargetType, 
		rc.SubAccountUid AS TargetId, 
		a.SubAccountId AS TargetName, 
		rt.TierLevel, 
		rtc.Active AS TierActive, 
		scc.CostEUR AS Cost_Old, 
		ISNULL(rc.CostCalculated, scc.CostEUR) AS TierCost_Old, 
		scc_new.CostEUR AS Cost_New, 
		scc_new.CostEUR AS TierCost_New, 
		rc.CompanyPrice AS Price, 
		rc.CompanyCurrency
	FROM rt.RoutingCustom rc
		INNER JOIN rt.RoutingGroup rg ON 
			rc.RoutingGroupId = rg.RoutingGroupId AND rg.Deleted = 0
		--INNER JOIN rt.RoutingGroupTier rgt ON rc.RoutingGroupId = rgt.RoutingGroupId AND rgt.Deleted = 0 AND rgt.Level IN (1, rg.TierLevelCurrent)
		INNER JOIN rt.RoutingTier rt ON 
			rg.RoutingGroupId = rt.RoutingGroupId 
			AND rt.Deleted = 0 
			AND rt.TierLevel IN (1, rg.TierLevelCurrent)
		INNER JOIN rt.RoutingTierConn_Active rtc ON 
			rtc.RoutingTierId = rt.RoutingTierId
		LEFT JOIN rt.vwSupplierCostCoverage_Active scc ON 
			scc.ConnUid = rtc.ConnUid 
			AND scc.Country = rc.Country 
			AND ISNULL(scc.OperatorId, 0) = ISNULL(rc.OperatorId, 0)
		LEFT JOIN rt.vwSupplierCostCoverage_Active scc_new ON 
			scc_new.ConnUid = @ConnUid_New 
			AND scc_new.Country = rc.Country 
			AND ISNULL(scc_new.OperatorId, 0) = ISNULL(rc.OperatorId, 0)
		INNER JOIN dbo.Account a ON a.SubAccountUid = rc.SubAccountUid
	WHERE rc.Country = @Country
   		AND ISNULL(@OperatorId, 0) = ISNULL(rc.OperatorId, 0)
		--AND (@OperatorId IS NULL OR (@OperatorId IS NOT NULL AND rc.OperatorId = @OperatorId))
        AND rtc.ConnUid = @ConnUid_Old
END

