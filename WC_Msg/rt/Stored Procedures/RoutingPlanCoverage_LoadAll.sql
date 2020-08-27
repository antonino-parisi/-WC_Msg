-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-03
-- =============================================
-- EXEC rt.RoutingPlanCoverage_LoadAll
CREATE PROCEDURE [rt].[RoutingPlanCoverage_LoadAll]
	@LastSyncTimestamp datetime = NULL
AS
BEGIN
	SELECT rpc.RoutingPlanCoverageId, rpc.RoutingPlanId, 
		rpc.Country, rpc.OperatorId, rpc.TrafficCategory, rpc.RoutingGroupId,
		rpc.CostCalculated, rpc.CostCurrency, rpc.Deleted
	FROM rt.RoutingPlanCoverage rpc
	WHERE ((@LastSyncTimestamp IS NULL AND rpc.Deleted = 0) 
		OR (@LastSyncTimestamp IS NOT NULL AND rpc.UpdatedAt >= @LastSyncTimestamp))
END
