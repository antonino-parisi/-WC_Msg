-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-14
-- =============================================
-- EXEC map.RoutingPlanCoverage_Delete @RoutingPlanId = 2, ...
CREATE PROCEDURE [map].[RoutingPlanCoverage_Delete]
	@RoutingPlanId int,		--filter
	@Country char(2),		--filter
	@OperatorId int,		--filter
	@TrafficCategory varchar(3) = 'DEF',	--filter
	@UpdatedBy smallint
AS
BEGIN

	UPDATE rt.RoutingPlanCoverage 
	SET Deleted = 1
	OUTPUT inserted.RoutingPlanCoverageId
	WHERE RoutingPlanId = @RoutingPlanId 
		AND Country = @Country 
		AND ISNULL(OperatorId, 0) = ISNULL(@OperatorId, 0)
		AND TrafficCategory = @TrafficCategory

	--TODO: 
	--	What to do with deleted RoutingGroupId? 
	--	To execute soft delete here or app will take care of it?
END
