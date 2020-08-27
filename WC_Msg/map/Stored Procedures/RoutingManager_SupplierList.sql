-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-11-01
-- Description:	List of available routes for Operator
-- =============================================
-- Examples:
-- EXEC map.RoutingManager_SupplierList @Country = 'SG', @OperatorId = 525001
-- =============================================
CREATE PROCEDURE [map].[RoutingManager_SupplierList]
	@Country char(2),
	@OperatorId int,
	@ConnUid smallint = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		c.ConnUid, c.ConnId, 
		ISNULL(ro.Ranking, 99) AS Ranking, 
		cost.CostEUR, 
		cost.CostLocal, cost.CostLocalCurrency, 
		ro.JsonData AS MetaInfo
	FROM rt.SupplierConn c
		LEFT JOIN rt.RoutingView_Operator ro ON ro.RouteUid = c.ConnUid AND ro.OperatorId = @OperatorId AND ro.IsActiveRoute = 1
		INNER JOIN rt.vwSupplierCostCoverage_Active cost ON cost.ConnUid = c.ConnUid AND cost.Country = @Country AND ISNULL(cost.OperatorId,0) = ISNULL(@OperatorId,0) AND cost.SmsTypeId = 1
	WHERE c.Deleted = 0 
		AND (@ConnUid IS NULL OR (@ConnUid IS NOT NULL AND c.ConnUid = @ConnUid))
	ORDER BY ro.Ranking, c.ConnId
END
