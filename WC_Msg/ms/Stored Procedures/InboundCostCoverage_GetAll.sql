
---
-- =============================================
-- History:
-- 2020-03-06	Anton Shchekalov	Created
-- =============================================
-- EXEC ms.InboundCostCoverage_GetAll
CREATE PROCEDURE [ms].[InboundCostCoverage_GetAll]
AS
BEGIN

	SELECT
		c.CostCoverageId,
		c.ConnUid,
		c.VNType,
		c.VNCountry,
		c.MSISDNCountry,
		c.MSISDNOperatorId,
		c.BillingStart,
		c.BillingEnd,
		c.Currency,
		c.CostPerSms,
		mno.CurrencyConverter(c.CostPerSms, c.Currency, 'EUR', DEFAULT) AS CostPerSmsEUR
	FROM 
		rt.InboundCostCoverage c
	WHERE 
		c.BillingEnd > SYSUTCDATETIME()
		
END
