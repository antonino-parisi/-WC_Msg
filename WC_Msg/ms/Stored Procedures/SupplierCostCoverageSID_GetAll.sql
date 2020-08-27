


---
-- =============================================
-- History:
-- 2020-04-16	Anton Shchekalov	Created
-- =============================================
-- EXEC ms.[SupplierCostCoverageSID_GetAll]
CREATE PROCEDURE [ms].[SupplierCostCoverageSID_GetAll]
AS
BEGIN

	SELECT
		--s.CostCoverageSIDId,
		s.ConnUid,
		s.Country,
		s.OperatorId,
		s.BillingStart,
		s.BillingEnd,
		ISNULL(sg.SID, s.SID) AS SID,
		0 AS CaseSensitive,
		s.Currency,
		s.CostPerSms,
		mno.CurrencyConverter(s.CostPerSms, s.Currency, 'EUR', DEFAULT) AS CostPerSmsEUR,
		IIF(s.OperatorId IS NOT NULL, 10, 0) /*+ IIF(sg.CaseSensitive = 1, 5, 0)*/ AS Priority
	FROM 
		rt.SupplierCostCoverageSID s
		LEFT JOIN rt.SupplierCostCoverageSIDGroup sg ON s.CostCoverageSIDId = sg.CostCoverageSIDId
	WHERE 
		s.BillingEnd > SYSUTCDATETIME()
		
END
