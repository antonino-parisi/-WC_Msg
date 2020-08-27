-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-12-13
-- =============================================
-- EXEC map.[CustomerGroup_Insert] @CustomerGroupName = 'plan', @OwnerId = 123
CREATE PROCEDURE [map].[CustomerGroup_Insert]
	@CustomerGroupName nvarchar(100),
	@Description nvarchar(1000) = NULL,
	@OwnerId smallint,
	@RoutingPlanId_Default int = NULL,
	@PricingPlanId_Default int = NULL
AS
BEGIN

	DECLARE @Output TABLE (CustomerGroupId int)

	INSERT INTO rt.CustomerGroup (CustomerGroupName, OwnerId, Description, RoutingPlanId_Default, PricingPlanId_Default)
	OUTPUT inserted.CustomerGroupId
	VALUES (@CustomerGroupName, @OwnerId, @Description, @RoutingPlanId_Default, @PricingPlanId_Default)

	SELECT CustomerGroupId FROM @Output
END
