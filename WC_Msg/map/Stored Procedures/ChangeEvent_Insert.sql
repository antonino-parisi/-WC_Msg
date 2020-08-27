-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-07-31
-- =============================================
-- SAMPLE:
-- EXEC map.ChangeEvent_Insert
CREATE PROCEDURE [map].[ChangeEvent_Insert]
	@EventType varchar(50),
	@RoutingPlanId int = NULL,
	@PricingPlanId int = NULL,
	@CustomerGroupId int = NULL,
	@Countries varchar(100) = NULL,
	@EventSummary nvarchar(4000),
	@EventData nvarchar(max),
	@CreatedBy smallint
AS
BEGIN

	DECLARE @EventTypeId tinyint
	SELECT @EventTypeId = EventTypeId 
	FROM rt.ChangeEventType 
	WHERE EventType = @EventType

	IF (@EventTypeId IS NULL)
	BEGIN
		THROW 51000, 'EventType not found', 0
	END

	INSERT INTO rt.ChangeEvent (
		CreatedAt, 
		EventTypeId,
		RoutingPlanId,
		PricingPlanId,
		CustomerGroupId,
		Countries,
		EventSummary,
		EventData,
		CreatedBy 
	) VALUES (
		SYSUTCDATETIME(),
		@EventTypeId,
		@RoutingPlanId,
		@PricingPlanId,
		@CustomerGroupId,
		@Countries,
		@EventSummary,
		@EventData,
		@CreatedBy
	)
END
