
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-12-13
-- =============================================
-- EXEC map.CustomerGroup_Update @CustomerGroupId = 123, @CustomerGroupName = 'group'
CREATE PROCEDURE [map].[CustomerGroup_Update]
	@CustomerGroupId int,
	@CustomerGroupName nvarchar(100),
	@Description nvarchar(1000),
	@OwnerId smallint,
	@RoutingPlanId_Default int,
	@PricingPlanId_Default int
AS
BEGIN

	UPDATE rt.CustomerGroup
	SET CustomerGroupName = @CustomerGroupName, 
		Description = @Description,
		OwnerId = @OwnerId, 
		UpdatedAt = SYSUTCDATETIME(),
		RoutingPlanId_Default = @RoutingPlanId_Default,
		PricingPlanId_Default = @PricingPlanId_Default
	WHERE CustomerGroupId = @CustomerGroupId

END
