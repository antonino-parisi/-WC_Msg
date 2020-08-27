-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-08-01
-- =============================================
-- SAMPLE:
-- EXEC mno.job_CurrencyRate_SetWavecell
-- SELECT * FROM mno.CurrencyRate WHERE IsCurrent = 1
CREATE PROCEDURE [mno].[job_CurrencyRate_SetWavecell]
AS
BEGIN

	SET NOCOUNT ON

	/* query to explain dates range: from last day of -2 months till 1st day of current month */
	--SELECT 
	--	EOMONTH ( SYSUTCDATETIME(), -2 ) AS StartDate, 
	--	DATEADD(DAY, 1, EOMONTH ( SYSUTCDATETIME(), -1 )) AS EndDate;
	-- KNOWN ISSUE - it doesn't count

	BEGIN TRANSACTION
	BEGIN TRY

		DECLARE @Rates AS TABLE (
			EffectiveFrom datetime2(0),
			CurrencyFrom char(3),
			CurrencyTo char(3),
			Rate decimal(18,10)
		)

		INSERT INTO @Rates (EffectiveFrom, CurrencyFrom, CurrencyTo, Rate)
		SELECT 
			DATEADD(DAY, 1, EOMONTH ( EffectiveFrom, 0 )) AS EffectiveFrom, 
			CurrencyFrom, 
			CurrencyTo, 
			AVG(Rate) AS Rate
			--,MIN(EffectiveFrom) AS MinDate, MAX(EffectiveFrom) AS MaxDate
		--SELECT DATEADD(DAY, 1, EOMONTH ( EffectiveFrom, 0 )) AS EffectiveFrom, *
		FROM mno.CurrencyRateSource cr 
		WHERE EffectiveFrom BETWEEN DATEADD(DAY, 1, EOMONTH ( SYSUTCDATETIME(), -2 )) AND DATEADD(DAY, 0, EOMONTH ( SYSUTCDATETIME(), -1 ))
			--AND CurrencyFrom = 'USD'
			--AND cr.CurrencyTo = 'EUR'
		GROUP BY CurrencyTo, CurrencyFrom, EOMONTH ( EffectiveFrom, 0 )

		PRINT [dbo].[Log_ROWCOUNT] ('Calc new rates')

		UPDATE r SET IsCurrent = 0, UpdatedAt = SYSUTCDATETIME()
		--SELECT *
		FROM mno.CurrencyRate r
			INNER JOIN @Rates t ON 
				r.CurrencyTo = t.CurrencyTo AND
				r.CurrencyFrom = t.CurrencyFrom AND
				r.EffectiveFrom < t.EffectiveFrom AND
				r.IsCurrent = 1
		PRINT [dbo].[Log_ROWCOUNT] ('Remove IsActive flag from prev rates')

		UPDATE r SET IsCurrent = 1, Rate = t.Rate, UpdatedAt = SYSUTCDATETIME()
		--SELECT *
		FROM mno.CurrencyRate r
			INNER JOIN @Rates t ON 
				r.CurrencyTo = t.CurrencyTo AND
				r.CurrencyFrom = t.CurrencyFrom AND
				r.EffectiveFrom = t.EffectiveFrom AND
				r.IsCurrent = 1 AND 
				r.Rate <> t.Rate
		PRINT [dbo].[Log_ROWCOUNT] ('Existing records updated')

		INSERT INTO mno.CurrencyRate (EffectiveFrom, CurrencyTo, CurrencyFrom, Rate, IsCurrent)
		SELECT EffectiveFrom, CurrencyTo, CurrencyFrom, Rate, IIF(t.EffectiveFrom = DATEADD(DAY, 1, EOMONTH ( SYSUTCDATETIME(), -1 )), 1, 0) AS IsCurrent
		FROM @Rates t
		WHERE NOT EXISTS (
			SELECT 1 FROM mno.CurrencyRate r
			WHERE r.CurrencyTo = t.CurrencyTo AND
				r.CurrencyFrom = t.CurrencyFrom AND
				r.EffectiveFrom = t.EffectiveFrom
		)
		PRINT [dbo].[Log_ROWCOUNT] ('New records added')

	END TRY
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  

		IF @@TRANCOUNT > 0  
			ROLLBACK TRANSACTION;  
	END CATCH;  

	IF @@TRANCOUNT > 0  
		COMMIT TRANSACTION;
END
