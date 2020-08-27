-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-04
-- =============================================
-- EXEC map.PricingPlan_GetList @OwnerId = NULL
CREATE PROCEDURE map.PricingPlan_GetList
	@OwnerId smallint = NULL
AS
BEGIN

	SELECT pp.PricingPlanId, pp.PricingPlanName, pp.Description, pp.CreatedAt, pp.UpdatedAt,
		pp.OwnerId, u.Email AS Owner_Email, u.Firstname AS Owner_Firstname, u.LastName AS Owner_Lastname
	FROM rt.PricingPlan pp
		LEFT JOIN map.[User] u ON u.UserId = pp.OwnerId
	WHERE pp.Deleted = 0 AND (@OwnerId IS NULL OR (@OwnerId IS NOT NULL AND pp.OwnerId = @OwnerId))
END

