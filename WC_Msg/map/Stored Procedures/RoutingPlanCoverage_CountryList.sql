-- =============================================
-- Author:		Nathanael Hinay
-- Create date: 2020-05-05
-- =============================================
-- EXEC map.RoutingPlanCoverage_CountryList @RoutingPlanId = 3
CREATE PROCEDURE [map].[RoutingPlanCoverage_CountryList]
	@RoutingPlanId int,
    @Country char(2) = NULL
AS
BEGIN

	SELECT DISTINCT 
		rpc.Country,
        rpc.Country as CountryISO2alpha,	--	for MAP UI compatibility
        c.CountryName,
        CAST(0 as bit) as isNew,			--	for MAP UI compatibility
        NULL as UpdatedAt					--	for MAP UI compatibility
	FROM rt.RoutingPlanCoverage rpc
		INNER JOIN rt.RoutingPlan rp ON rp.RoutingPlanId = rpc.RoutingPlanId AND rp.Deleted = 0
		INNER JOIN mno.Country c ON rpc.Country = c.CountryISO2alpha
		LEFT JOIN mno.Operator o ON rpc.OperatorId = o.OperatorId
		LEFT JOIN rt.RoutingGroup rg ON rg.RoutingGroupId = rpc.RoutingGroupId AND rg.Deleted = 0
		LEFT JOIN rt.RoutingTier rtL1 ON rg.RoutingGroupId = rtL1.RoutingGroupId AND rtL1.TierLevel = 1 AND rtL1.Deleted = 0
	WHERE rpc.RoutingPlanId = @RoutingPlanId
		AND rpc.TrafficCategory = 'DEF'
        AND rpc.Deleted = 0 -- Added to filter deleted countries
        AND (@Country IS NULL OR (@Country IS NOT NULL AND rpc.Country = @Country))
    ORDER BY c.CountryName ASC
END
