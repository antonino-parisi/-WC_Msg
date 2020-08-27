


CREATE VIEW [rt].[vwSupplierCostCoverage_Active]
AS
	SELECT 
		scc.CostCoverageId, 
		scc.RouteUid AS ConnUid, 
		sc.ConnId, 
		scc.Country, 
		scc.OperatorId,
		o.OperatorName,
		scc.CostLocal, 
		scc.CostLocalCurrency, 
		scc.CostEUR,
		scc.SmsTypeId,
		scc.UpdatedAt
	FROM rt.SupplierCostCoverage scc
		LEFT JOIN rt.SupplierConn sc ON sc.ConnUid = scc.RouteUid
		LEFT JOIN mno.Operator o ON o.OperatorId = scc.OperatorId
	WHERE scc.Deleted = 0 
		AND scc.EffectiveFrom <= SYSUTCDATETIME() /*AND scc.EffectiveTo >= SYSUTCDATETIME()*/
