-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-31
-- Description:	Data for RoutingMatrix. RouteList
-- =============================================
CREATE PROCEDURE dbo.sp_RoutingMatrix_PopulateRouteList
AS
BEGIN
	SET NOCOUNT ON;

	SELECT AccountId, SubAccountId, Prefix, RouteId, Price, Operator, TariffRoute, Cost
	FROM PlanRouting 
	WHERE Active = 1 
	ORDER BY AccountId, [Priority] DESC

END

