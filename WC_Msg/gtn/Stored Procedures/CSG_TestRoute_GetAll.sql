
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-11-03
-- Description:	List of all Test Route mapping
-- =============================================
-- Examples:
-- EXEC [gtn].[CSG_TestRoute_GetAll]
-- =============================================
CREATE PROCEDURE [gtn].[CSG_TestRoute_GetAll]
AS
BEGIN

	SELECT CSG_SMSRouteId, WC_RouteId FROM gtn.CSG_Route

END

