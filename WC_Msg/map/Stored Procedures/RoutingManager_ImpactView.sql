-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-31
-- =============================================
-- EXEC map.RoutingManager_ImpactView @Country = 'SG', @OperatorId = 525001, @ConnUid_Old = 27, @ConnUid_New = 70
CREATE PROCEDURE [map].[RoutingManager_ImpactView]
	@Country char(2),
	@OperatorId int,
	@ConnUid_Old smallint,
	@ConnUid_New smallint
AS
BEGIN
	--DECLARE @Output TABLE (
	--	Country char(2),
	--	OperatorId int,
	--	TargetType varchar(10),
	--	TargetId int,
	--	TargetName nvarchar(100),
	--	TierLevel tinyint,
	--	Active bit,
	--	CostEUR decimal(12,6),
	--	CostLocal decimal(12,6),
	--	CostLocalCurrency char(3),
	--	PriceEUR decimal(12,6) NULL
	--)

	--INSERT INTO @Output (Country, OperatorId, ConnUid, ConnId, TargetType, TargetId, TargetName, TierLevel, Active, CostEUR, CostLocal, CostLocalCurrency)
	--DECLARE @Country char(2) = 'SG'
	--DECLARE @OperatorId int = 525001
	--DECLARE @ConnUid_Old smallint = 27
	--DECLARE @ConnUid_New smallint = 70
	
	/** 
	TODO: CostCalculated_New is working incorrect. Now it return ConnId cost, not calculated based on summary of all conns in Tier
	**/
	SELECT 
		rpc.Country, rpc.OperatorId, 
		rtc.ConnUid AS ConnUid_Old, scc_new.ConnUid AS ConnUid_New,
		'PLAN' AS TargetType, 
		rp.RoutingPlanId AS TargetId, rp.RoutingPlanName AS TargetName, 
		rt.TierLevel, rtc.Active AS TierActive, 
		scc.CostEUR AS Cost_Old, ISNULL(rpc.CostCalculated, scc.CostEUR) AS TierCost_Old, 
		scc_new.CostEUR AS Cost_New, scc_new.CostEUR AS TierCost_New,
		NULL AS Price, rpc.CostCurrency AS CompanyCurrency
	FROM rt.RoutingPlanCoverage rpc
		INNER JOIN rt.RoutingPlan rp ON rpc.RoutingPlanId = rp.RoutingPlanId AND rp.Deleted = 0 AND rpc.Deleted = 0
		INNER JOIN rt.RoutingGroup rg ON rpc.RoutingGroupId = rg.RoutingGroupId AND rg.Deleted = 0
		--INNER JOIN rt.RoutingGroupTier rgt ON rpc.RoutingGroupId = rgt.RoutingGroupId AND rgt.Deleted = 0 AND rgt.Level IN (1, rg.TierLevelCurrent)
		INNER JOIN rt.RoutingTier rt ON rpc.RoutingGroupId = rt.RoutingGroupId AND rt.Deleted = 0 AND rt.TierLevel IN (1, rg.TierLevelCurrent)
		INNER JOIN rt.RoutingTierConn_Active rtc ON rtc.RoutingTierId = rt.RoutingTierId
		LEFT JOIN rt.vwSupplierCostCoverage_Active scc ON scc.ConnUid = rtc.ConnUid AND scc.Country = rpc.Country AND ISNULL(scc.OperatorId, 0) = ISNULL(rpc.OperatorId, 0) 
		LEFT JOIN rt.vwSupplierCostCoverage_Active scc_new ON  scc_new.ConnUid = @ConnUid_New AND scc_new.Country = rpc.Country AND ISNULL(scc_new.OperatorId, 0) = ISNULL(rpc.OperatorId, 0)
	WHERE rpc.Country = @Country AND rpc.OperatorId = @OperatorId AND rtc.ConnUid = @ConnUid_Old
	--ORDER BY rtc.ConnUid
	UNION ALL
	SELECT 
		rc.Country, rc.OperatorId, 
		rtc.ConnUid AS ConnUid_Old, scc_new.ConnUid AS ConnUid_New,
		'SUBACCOUNT' AS TargetType, 
		rc.SubAccountUid AS TargetId, a.SubAccountId AS TargetName, 
		rt.TierLevel, rtc.Active AS TierActive, 
		scc.CostEUR AS Cost_Old, ISNULL(rc.CostCalculated, scc.CostEUR) AS TierCost_Old, 
		scc_new.CostEUR AS Cost_New, scc_new.CostEUR AS TierCost_New, 
		rc.CompanyPrice AS Price, rc.CompanyCurrency
	FROM rt.RoutingCustom rc
		INNER JOIN rt.RoutingGroup rg ON rc.RoutingGroupId = rg.RoutingGroupId AND rg.Deleted = 0
		--INNER JOIN rt.RoutingGroupTier rgt ON rc.RoutingGroupId = rgt.RoutingGroupId AND rgt.Deleted = 0 AND rgt.Level IN (1, rg.TierLevelCurrent)
		INNER JOIN rt.RoutingTier rt ON rc.RoutingGroupId = rt.RoutingGroupId AND rt.Deleted = 0 AND rt.TierLevel IN (1, rg.TierLevelCurrent)
		INNER JOIN rt.RoutingTierConn_Active rtc ON rtc.RoutingTierId = rt.RoutingTierId
		LEFT JOIN rt.vwSupplierCostCoverage_Active scc ON scc.ConnUid = rtc.ConnUid AND scc.Country = rc.Country AND ISNULL(scc.OperatorId, 0) = ISNULL(rc.OperatorId, 0)
		LEFT JOIN rt.vwSupplierCostCoverage_Active scc_new ON  scc_new.ConnUid = @ConnUid_New AND scc_new.Country = rc.Country AND ISNULL(scc_new.OperatorId, 0) = ISNULL(rc.OperatorId, 0)
		INNER JOIN dbo.Account a ON a.SubAccountUid = rc.SubAccountUid
	WHERE rc.Country = @Country AND rc.OperatorId = @OperatorId AND rtc.ConnUid = @ConnUid_Old
END
