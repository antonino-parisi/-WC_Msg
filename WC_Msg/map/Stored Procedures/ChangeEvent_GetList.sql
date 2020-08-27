-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-07-31
-- Updated By:  Nathanael Hinay
-- Updated On:  2018-8-8
-- =============================================
-- SAMPLE:
-- EXEC map.ChangeEvent_GetList @RoutingPlanId = NULL
CREATE PROCEDURE [map].[ChangeEvent_GetList]
	@TimeframeStart datetime2(2),
	@TimeframeEnd datetime2(2),
	@RoutingPlanId int = NULL,		-- filter
	@PricingPlanId int = NULL,		-- filter
	@CustomerGroupId int = NULL,	-- filter
	@Country char(2) = NULL,		-- filter
    @CreatedBy int = NULL,          -- filter
    @EventType char(50) = NULL,     -- filter
	@PageSize int,
	@PageOffset int
AS
BEGIN
	SELECT 
		ce.EventId,
		ce.CreatedAt,
		ce.EventTypeId,
		cet.EventType,
		ce.RoutingPlanId,
		ce.PricingPlanId,
		ce.CustomerGroupId,
		ce.Countries,
		ce.EventSummary,
        ce.CreatedBy,
        u.FirstName,
        u.LastName
		--ce.EventData
	
	FROM rt.ChangeEvent ce
		LEFT JOIN rt.ChangeEventType cet ON cet.EventTypeId = ce.EventTypeId
        LEFT JOIN map.[User] u  ON ce.CreatedBy = u.UserId
	
	WHERE
		ce.CreatedAt >= @TimeframeStart AND
		ce.CreatedAt < @TimeframeEnd AND
		(@RoutingPlanId IS NULL OR (@RoutingPlanId IS NOT NULL AND ce.RoutingPlanId = @RoutingPlanId)) AND
		(@PricingPlanId IS NULL OR (@PricingPlanId IS NOT NULL AND ce.PricingPlanId = @PricingPlanId)) AND
		(@CustomerGroupId IS NULL OR (@CustomerGroupId IS NOT NULL AND ce.CustomerGroupId = @CustomerGroupId)) AND
		(@Country IS NULL OR (@Country IS NOT NULL AND CHARINDEX(@Country, ce.Countries) > 0 )) AND
        (@CreatedBy IS NULL OR (@CreatedBy IS NOT NULL AND ce.CreatedBy = @CreatedBy)) AND
        (@EventType IS NULL OR (@EventType IS NOT NULL AND cet.EventType = @EventType))

	ORDER BY ce.CreatedAt DESC
	OFFSET (@PageOffset) ROWS FETCH NEXT (@PageSize) ROWS ONLY
END
