

---
-- =============================================
-- History:
-- 2020-03-06	Anton Shchekalov	Created
-- =============================================
-- SELECT TOP 100 * FROM rt.vwInboundPriceCoverage
-- =============================================
CREATE VIEW [rt].[vwInboundPriceCoverage]
AS
	SELECT
		p.PriceCoverageId,
		p.SubaccountUid,
		sa.SubAccountId,
		sa.AccountId,
		sa.AccountUid,
		p.VNType,
		t.VNTypeName,
		p.VNCountry,
		c1.CountryName AS VNCountryName,
		p.MSISDNCountry,
		c2.CountryName AS MSISDNCountryName,
		p.MSISDNOperatorId,
		p.BillingStart,
		p.BillingEnd,
		p.Currency,
		p.PricePerSms,
		p.UpdatedAt
	FROM 
		rt.InboundPriceCoverage p (NOLOCK)
		LEFT JOIN ms.vwSubAccount sa ON p.SubaccountUid = sa.SubAccountUid
		LEFT JOIN ms.DimVirtualNumberType t ON p.VNType = t.VNType
		LEFT JOIN mno.Country c1 ON p.VNCountry = c1.CountryISO2alpha
		LEFT JOIN mno.Country c2 ON p.MSISDNCountry = c2.CountryISO2alpha
