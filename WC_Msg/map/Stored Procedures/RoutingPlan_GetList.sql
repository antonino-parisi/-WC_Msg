
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-10
-- =============================================
-- EXEC map.RoutingPlan_GetList @OwnerId = NULL
CREATE PROCEDURE [map].[RoutingPlan_GetList]
	@OwnerId smallint = NULL
AS
BEGIN

	SELECT rp.RoutingPlanId, rp.RoutingPlanName, rp.Description, rp.CreatedAt, rp.UpdatedAt,
		rp.OwnerId, u.Email AS Owner_Email, u.Firstname AS Owner_Firstname, u.LastName AS Owner_Lastname
	FROM rt.RoutingPlan rp
		LEFT JOIN map.[User] u ON u.UserId = rp.OwnerId
	WHERE rp.Deleted = 0 AND (@OwnerId IS NULL OR (@OwnerId IS NOT NULL AND rp.OwnerId = @OwnerId))
END

