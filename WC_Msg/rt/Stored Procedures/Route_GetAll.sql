-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-05-10
-- Description:	List of all routes
-- =============================================
-- Examples:
-- EXEC rt.[Route_GetAll]
-- =============================================
CREATE PROCEDURE [rt].[Route_GetAll]
AS
BEGIN
	SET NOCOUNT ON;

	--SELECT RouteId
	--FROM rt.Route
	--ORDER BY 1

	SELECT sc.ConnId AS RouteId
	FROM rt.SupplierConn sc
	WHERE sc.Deleted = 0
	ORDER BY 1
END
