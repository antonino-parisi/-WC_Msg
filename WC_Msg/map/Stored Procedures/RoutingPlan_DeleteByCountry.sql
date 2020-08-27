
-- =============================================
-- Author:		Nathanael Hinay
-- Create date: 2019-07-26
-- =============================================
-- EXEC map.RoutingPlan_DeleteByCountry @RoutingPlanId=1363 @Country='PH'
CREATE PROCEDURE [map].[RoutingPlan_DeleteByCountry]
	@RoutingPlanId int,
    @Country VARCHAR(2),
    @UpdatedBy SMALLINT
AS
BEGIN

	UPDATE [rt].[RoutingPlanCoverage]
	SET Deleted = 1, UpdatedAt = SYSUTCDATETIME(), UpdatedBy = @UpdatedBy
	WHERE RoutingPlanId = @RoutingPlanId 
        AND Country = @Country
		AND Deleted = 0

END
