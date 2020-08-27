
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- =============================================
-- EXEC map.RoutingPlanCoverage_Insert @RoutingPlanId = 2, ...
CREATE PROCEDURE [map].[RoutingPlanCoverage_Insert]
	@RoutingPlanId int,		--filter
	@Country char(2),		--filter
	@OperatorId int,		--filter
	@TrafficCategory varchar(3),	--filter
	@RoutingGroupId int,	-- new value
	@UpdatedBy smallint
AS
BEGIN

	--DECLARE @CostCalculated decimal(12,6)

	--SELECT @CostCalculated = SUM(rtc.Weight * scc.CostEUR) / SUM(rtc.Weight)
	--FROM rt.RoutingGroupTier rgt 
	--	JOIN rt.RoutingTierConn rtc ON rgt.RoutingTierId = rtc.RoutingTierId AND rgt.Level = 1 AND rgt.Deleted = 0
	--	JOIN rt.vwSupplierCostCoverage_Active scc ON scc.ConnUid = rtc.ConnUid AND scc.Country = @Country AND ISNULL(scc.OperatorId, 0) = ISNULL(@OperatorId, 0)
	--WHERE rgt.RoutingGroupId = @RoutingGroupId AND rgt.Deleted = 0 AND rtc.Deleted = 0
	--GROUP BY rtc.RoutingTierId, scc.Country, scc.OperatorId

	--SELECT @CostCalculated = CostCalculated
	--FROM rt.RoutingTier
	--WHERE RoutingGroupId = @RoutingGroupId AND TierLevel = 1 AND Deleted = 0

	-- Hard delete of prev record
	DELETE TOP (1) FROM rt.RoutingPlanCoverage
	WHERE Deleted = 1 AND 
		ISNULL(RoutingPlanId, 0) = ISNULL(@RoutingPlanId, 0) AND
		Country = @Country AND
		ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0) AND
		TrafficCategory = @TrafficCategory

	DECLARE @Output TABLE (RoutingPlanCoverageId int)

	INSERT INTO rt.RoutingPlanCoverage (RoutingPlanId, Country, OperatorId, TrafficCategory, 
		RoutingGroupId, DataSourceId, CostCurrency, CostCalculated, 
		CreatedAt, CreatedBy, UpdatedAt, UpdatedBy)
	OUTPUT inserted.RoutingPlanCoverageId INTO @Output (RoutingPlanCoverageId)
	VALUES (@RoutingPlanId, @Country, @OperatorId, @TrafficCategory, 
		@RoutingGroupId, 2, 'EUR', NULL /* CostCalculated */, 
		SYSUTCDATETIME(), @UpdatedBy, SYSUTCDATETIME(), @UpdatedBy)

	-- update dependencies:
	-- link between RoutingPlanCoverage and RoutingGroup is set now
	-- next query will triggers to calculate CostCalculated in Tiers for the 1st time
	UPDATE rt.RoutingTier
	SET UpdatedAt = SYSUTCDATETIME()
	WHERE RoutingGroupId = @RoutingGroupId AND Deleted = 0

    UPDATE rt.RoutingPlan
	SET UpdatedAt = SYSUTCDATETIME()
	WHERE RoutingPlanId = @RoutingPlanId AND Deleted = 0

	SELECT RoutingPlanCoverageId FROM @Output
END
