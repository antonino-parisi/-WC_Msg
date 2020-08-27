-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-31
-- =============================================
-- EXEC map.PricingPlan_Insert @PricingPlanName = 'plan', @Description = 'description', @OwnerId = 123
CREATE PROCEDURE [map].[PricingPlan_Insert]
	@PricingPlanName nvarchar(100),
	@Description nvarchar(1000) = NULL,
	@OwnerId smallint
AS
BEGIN

	DECLARE @Output TABLE (PricingPlanId int)

	INSERT INTO rt.PricingPlan (PricingPlanName, Description, OwnerId, CreatedAt, UpdatedAt)
	OUTPUT inserted.PricingPlanId
	VALUES (@PricingPlanName, @Description, @OwnerId, SYSUTCDATETIME(), SYSUTCDATETIME())

	SELECT PricingPlanId FROM @Output
END
