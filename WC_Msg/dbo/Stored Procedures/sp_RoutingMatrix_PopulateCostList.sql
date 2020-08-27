-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-31
-- Description:	Data for RoutingMatrix. List of all CostLists
-- =============================================
CREATE PROCEDURE dbo.sp_RoutingMatrix_PopulateCostList
AS
BEGIN
	SET NOCOUNT ON;

	SELECT Operator, RouteId, Cost FROM CostList

END

