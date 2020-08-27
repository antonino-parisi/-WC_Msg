
CREATE PROCEDURE [mno].[job_CurrencyRate_Validate]	
AS
BEGIN
	IF NOT EXISTS (
		SELECT TOP (1) 1
		--SELECT *
		FROM mno.CurrencyRateSource cr
		WHERE cr.UpdatedAt > DATEADD(hh, -48, SYSUTCDATETIME()) 
			AND cr.EffectiveFrom > DATEADD(hh, -120, SYSUTCDATETIME())
			AND cr.IsCurrent = 1
	)
		THROW 51000, 'WARNING: No recent changes in Currency Rates. Please check data import.', 1;  
		
END
