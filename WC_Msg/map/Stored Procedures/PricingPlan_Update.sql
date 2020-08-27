-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-31
-- =============================================
-- EXEC map.PricingPlan_Update @PricingPlanId = 123, @PricingPlanName = 'plan', @Description = 'description', @OwnerId = 123
CREATE PROCEDURE [map].[PricingPlan_Update]
	@PricingPlanId int,
	@PricingPlanName nvarchar(100),
	@Description nvarchar(1000) = NULL,
	@OwnerId smallint
AS
BEGIN

	UPDATE rt.PricingPlan
	SET PricingPlanName = @PricingPlanName, Description = @Description, 
		OwnerId = @OwnerId, UpdatedAt = SYSUTCDATETIME()
	WHERE PricingPlanId = @PricingPlanId

END
