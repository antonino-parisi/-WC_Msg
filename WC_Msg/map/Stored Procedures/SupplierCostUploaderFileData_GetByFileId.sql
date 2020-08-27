-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-05-21
-- =============================================
-- SAMPLE:
-- EXEC map.SupplierCostUploaderFileData_GetByFileId @FileId = 215
-- EXEC map.SupplierCostUploaderFileData_GetByFileId @FileId = 215, @IsValid = 1, @IsSaved = 1
CREATE PROCEDURE [map].[SupplierCostUploaderFileData_GetByFileId]
	@FileId int,
	@ConnUid int = NULL,
	@IsValid bit =  NULL,	-- 0 - only invalid lines, 1 - only valid lines, NULL - all
	@IsSaved bit = NULL		-- 0 - only unsaved, 1 - only saved, NULL - all
AS
BEGIN

	SELECT d.RecordId, d.IsValid, 
		-- input columns
		d.ConnId, d.MCC, d.MNC, d.SmsType, d.Currency, d.Cost, d.EffectiveFrom, d.Active, d.ErrorCode,
		-- output columns
		d.ConnUid, d.Country, d.OperatorId, d.SmsTypeId,
		-- extra columns
		c.CostLocal AS CostCurrent, c.CostLocalCurrency AS CurrencyCurrent,
		c.CostEUR AS CostCurrentEUR,
		IIF (d.Currency = 'EUR', d.Cost, d.Cost * fx.Rate) AS CostEUR
	FROM map.SupplierCostUploaderFileData d
		LEFT JOIN rt.SupplierCostCoverage c 
			ON d.ConnUid = c.RouteUid 
				AND d.Country = c.Country
				AND d.SmsTypeId = c.SmsTypeId
				AND ISNULL(d.OperatorId, -1) = ISNULL(c.OperatorId, -1)
				AND c.Deleted = 0 AND c.EffectiveFrom < SYSUTCDATETIME()
		LEFT JOIN mno.CurrencyRate fx
			ON fx.IsCurrent = 1 AND 
				fx.CurrencyFrom = d.Currency AND
				fx.CurrencyTo = 'EUR'
	WHERE d.FileId = @FileId 
		AND (d.IsValid = ISNULL(@IsValid, d.IsValid))
		AND (@ConnUid IS NULL OR (@ConnUid IS NOT NULL AND d.ConnUid = @ConnUid))
		AND (@IsSaved IS NULL OR (@IsSaved IS NOT NULL AND d.Saved = @IsSaved))

END
