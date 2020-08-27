-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-25
-- =============================================
-- EXEC rt.SupplierCostCoverage_LoadAll
CREATE PROCEDURE [rt].[SupplierCostCoverage_LoadAll]
	@LastSyncTimestamp datetime = NULL
AS
BEGIN
	SELECT 
		scc.CostCoverageId, 
		scc.Country, 
		scc.OperatorId, 
		sc.ConnId, 
		scc.RouteUid AS ConnUid, 
		'EUR' AS CostCurrency, 
		CostEUR AS Cost,
		CostEUR,
		CostLocal AS CostContract,
		CostLocalCurrency AS CostContractCurrency,
		/*EffectiveFrom, EffectiveTo, */
		scc.Deleted
	FROM rt.SupplierCostCoverage scc
		LEFT JOIN rt.SupplierConn sc ON scc.RouteUid = sc.ConnUid
	WHERE 
		scc.SmsTypeId = 1 AND
		((@LastSyncTimestamp IS NULL AND scc.Deleted = 0)
			OR (@LastSyncTimestamp IS NOT NULL AND scc.UpdatedAt >= @LastSyncTimestamp))
END
