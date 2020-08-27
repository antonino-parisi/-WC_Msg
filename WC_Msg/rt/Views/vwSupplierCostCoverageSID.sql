



---
-- =============================================
-- History:
-- 2020-04-16	Anton Shchekalov	Created
-- =============================================
-- SELECT TOP 100 * FROM rt.vwSupplierCostCoverageSID
CREATE VIEW [rt].[vwSupplierCostCoverageSID]
AS

	SELECT
		s.CostCoverageSIDId,
		s.ConnUid,
		sc.ConnId,
		s.Country,
		s.OperatorId,
		ISNULL(o.OperatorName, '<ANY>') AS OperatorName,
		s.BillingStart,
		s.BillingEnd,
		IIF(sg.SID IS NULL, NULL, s.SID) AS SIDGroup,
		ISNULL(sg.SID, s.SID) AS SID,
		--0 AS sg.CaseSensitive,
		s.Currency,
		s.CostPerSms,
		IIF(s.OperatorId IS NOT NULL, 10, 0) /*+ IIF(sg.CaseSensitive = 1, 5, 0)*/ AS Priority
	FROM 
		rt.SupplierCostCoverageSID s
		LEFT JOIN rt.SupplierCostCoverageSIDGroup sg ON s.CostCoverageSIDId = sg.CostCoverageSIDId
		LEFT JOIN rt.SupplierConn sc ON s.ConnUid = sc.ConnUid
		LEFT JOIN mno.Operator o ON s.OperatorId = o.OperatorId
