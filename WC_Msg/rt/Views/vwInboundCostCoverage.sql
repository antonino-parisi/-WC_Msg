
---
-- =============================================
-- History:
-- 2020-03-06	Anton Shchekalov	Created
-- =============================================
-- SELECT TOP 100 * FROM rt.vwInboundCostCoverage
-- =============================================
CREATE VIEW [rt].[vwInboundCostCoverage]
AS
	SELECT
		c.CostCoverageId,
		c.ConnUid,
		sc.ConnId,
		c.VNType,
		t.VNTypeName,
		c.VNCountry,
		c1.CountryName AS VNCountryName,
		c.MSISDNCountry,
		c2.CountryName AS MSISDNCountryName,
		c.MSISDNOperatorId,
		c.BillingStart,
		c.BillingEnd,
		c.Currency,
		c.CostPerSmsSupplier,
		c.CostPerSmsOperator,
		c.CostPerSms,
		c.UpdatedAt
	FROM 
		rt.InboundCostCoverage c (NOLOCK)
		LEFT JOIN rt.SupplierConn sc ON c.ConnUid = sc.ConnUid
		LEFT JOIN ms.DimVirtualNumberType t ON c.VNType = t.VNType
		LEFT JOIN mno.Country c1 ON c.VNCountry = c1.CountryISO2alpha
		LEFT JOIN mno.Country c2 ON c.MSISDNCountry = c2.CountryISO2alpha
