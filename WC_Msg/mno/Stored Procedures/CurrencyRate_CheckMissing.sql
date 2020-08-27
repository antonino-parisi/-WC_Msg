-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2019-05-10
-- =============================================
-- EXEC mno.CurrencyRate_CheckMissing 'EUR-USD, IDR-EUR'
-- EXEC mno.CurrencyRate_CheckMissing 'EUR-USD, IDR-EUR', '2019-05-01', '2019-05-09'

CREATE PROCEDURE [mno].[CurrencyRate_CheckMissing]
	@DateFrom date = NULL,
	@DateTo date = NULL
AS
BEGIN
	SET NOCOUNT ON ;

	DECLARE @date date ;
	DECLARE @date_tab TABLE ([Date] date) ;

	SET @DateFrom = ISNULL(@DateFrom, DATEADD(dd, -121, GETUTCDATE())) ;
	--SET @DateFrom = '2018-12-01';
	SET @DateTo = ISNULL(@DateTo, DATEADD(dd, -1, GETUTCDATE())) ;
	SET @date = @DateFrom ;

	WHILE @date <= @DateTo
		BEGIN
			INSERT INTO @date_tab VALUES (@date) ;
			SET @date = DATEADD(dd, 1, @date) ;
		END ;

	SELECT t.CurrencyFrom, t.CurrencyTo, t.[Date]
	FROM (SELECT * FROM @date_tab, mno.CurrencyPair WITH (NOLOCK))  t
		LEFT JOIN
		(SELECT CurrencyFrom, CurrencyTo, CAST(EffectiveFrom AS date) [Date]
			FROM mno.CurrencyRateSource WITH (NOLOCK)
			WHERE EffectiveFrom >= @DateFrom AND EffectiveFrom < DATEADD(dd, 1, @DateTo)
		) c
	ON t.CurrencyFrom = c.CurrencyFrom
		AND t.CurrencyTo = c.CurrencyTo
		AND t.[Date] = c.[Date]
	WHERE c.[Date] IS NULL ;

END 
