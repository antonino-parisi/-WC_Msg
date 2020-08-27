-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- =============================================
-- Modified By      : Alexjander Bacalso
-- Modified date    : 2020-03-23
-- Description      : Update rt.RoutingPlan when Add or Updated coverage of specified Routing Plan.
-- Ticket Reference : https://wavecellagile.atlassian.net/secure/RapidBoard.jspa?rapidView=1&projectKey=MAP&modal=detail&selectedIssue=MAP-734
-- =============================================
-- EXEC map.RoutingPlanCoverage_Update @RoutingPlanId = 2, ...
CREATE PROCEDURE [map].[RoutingPlanCoverage_Update]
	@RoutingPlanId int,		--filter
	@Country char(2),		--filter
	@OperatorId int,		--filter
	@TrafficCategory varchar(3) = 'DEF',	--filter
	@RoutingGroupId int,	--new value
	@UpdatedBy smallint
AS
BEGIN

	--DECLARE @CostCalculated decimal(12,6)

	--SELECT @CostCalculated = SUM(rtc.Weight * scc.CostEUR) / SUM(rtc.Weight)
	--FROM rt.RoutingGroupTier rgt 
	--	JOIN rt.RoutingTierConn rtc ON rgt.RoutingTierId = rtc.RoutingTierId AND rgt.Level = 1
	--	JOIN rt.vwSupplierCostCoverage_Active scc ON scc.ConnUid = rtc.ConnUid AND scc.Country = @Country AND ISNULL(scc.OperatorId, 0) = ISNULL(@OperatorId, 0)
	--WHERE rgt.RoutingGroupId = @RoutingGroupId AND rgt.Deleted = 0 AND rtc.Deleted = 0
	--GROUP BY rtc.RoutingTierId, scc.Country, scc.OperatorId

	DECLARE @Output TABLE (RoutingPlanCoverageId int)

	UPDATE rt.RoutingPlanCoverage 
	SET RoutingGroupId = @RoutingGroupId
		-- CostCalculated will be recalced later, by trigger on RoutingTier
		--, CostCalculated = @CostCalculated, CostCurrency = 'EUR'
	OUTPUT inserted.RoutingPlanCoverageId INTO @Output (RoutingPlanCoverageId)
	WHERE RoutingPlanId = @RoutingPlanId 
		AND Country = @Country
		AND ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0)
		AND TrafficCategory = @TrafficCategory

	-- update dependencies:
	-- link between RoutingPlanCoverage and RoutingGroup has changed
	-- next query will trigger to re-calculate CostCalculated in Tiers and RoutingPlanCoverage itself
	UPDATE rt.RoutingTier
	SET UpdatedAt = SYSUTCDATETIME()
	WHERE RoutingGroupId = @RoutingGroupId AND Deleted = 0

    -- Reference: MAP-734
    UPDATE rt.RoutingPlan
	SET UpdatedAt = SYSUTCDATETIME()
	WHERE RoutingPlanId = @RoutingPlanId AND Deleted = 0
    -- 
    
	SELECT RoutingPlanCoverageId FROM @Output
	--TODO: 
	--	What to do with old, removed RoutingGroupId? 
	--	To execute soft delete here or app will take care of it?
END
