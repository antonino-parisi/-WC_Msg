-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-31
-- =============================================
-- EXEC map.PricingPlan_Delete @PricingPlanId=123
CREATE PROCEDURE [map].[PricingPlan_Delete]
	@PricingPlanId int
AS
BEGIN

	UPDATE rt.PricingPlan
	SET Deleted = 1, UpdatedAt = SYSUTCDATETIME()
	WHERE PricingPlanId = @PricingPlanId

END
