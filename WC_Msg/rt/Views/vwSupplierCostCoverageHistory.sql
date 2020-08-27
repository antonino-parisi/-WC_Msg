

CREATE VIEW [rt].[vwSupplierCostCoverageHistory]
AS

	SELECT 
		scch.Id,
		scch.ChangedBy,
		scch.ChangedAt,
		scch.Action,
		scch.CostCoverageId,
		scch.RouteUid AS ConnUid,
		ISNULL(sc.ConnId, '<DELETED>') AS ConnId,
		scch.Country,
		scch.OperatorId,
		scch.CostLocal,
		scch.CostLocalCurrency,
		scch.CostEUR,
		scch.EffectiveFrom,
		scch.CreatedAt,
		scch.UpdatedAt,
		scch.SmsTypeId,
		scch.Deleted
	FROM rt.SupplierCostCoverageHistory scch
		LEFT JOIN rt.SupplierConn sc ON sc.ConnUid = scch.RouteUid
