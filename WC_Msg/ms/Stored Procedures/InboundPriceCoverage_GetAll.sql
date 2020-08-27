---
-- =============================================
-- History:
-- 2020-03-06	Anton Shchekalov	Created
-- =============================================
-- EXEC ms.InboundPriceCoverage_GetAll
CREATE PROCEDURE [ms].[InboundPriceCoverage_GetAll]
AS
BEGIN

	SELECT
		c.PriceCoverageId,
		c.SubAccountUid,
		c.VNType,
		c.VNCountry,
		c.MSISDNCountry,
		c.MSISDNOperatorId,
		c.BillingStart,
		c.BillingEnd,
		c.Currency,
		c.PricePerSms,
		mno.CurrencyConverter(c.PricePerSms, c.Currency, 'EUR', DEFAULT) AS PricePerSmsEUR
	FROM 
		rt.InboundPriceCoverage c
	WHERE 
		c.BillingEnd > SYSUTCDATETIME()
		
END
