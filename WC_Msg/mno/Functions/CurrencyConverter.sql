
-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-08-31
-- =============================================
-- SAMPLE:
--SELECT mno.CurrencyConverter(NULL, 'EUR', 'SGD', DEFAULT)
--SELECT mno.CurrencyConverter(100, 'EUR', 'EUR', '2019-02-01')
--SELECT mno.CurrencyConverter(100, 'SGD', 'EUR', '2019-03-01')
--SELECT mno.CurrencyConverter(100, 'EUR', 'RUB', '2019-03-01')
CREATE FUNCTION [mno].[CurrencyConverter](
	@MoneyFrom decimal(19,7), 
	@CurrencyFrom char(3),
	@CurrencyTo char(3),
	@Date date = NULL	-- null means <today>
)
RETURNS decimal(19, 7)
AS
BEGIN

	DECLARE @MoneyTo decimal(19,7)

	IF @CurrencyTo = @CurrencyFrom OR @MoneyFrom IS NULL
		SET @MoneyTo = @MoneyFrom
	-- current date
	ELSE IF @Date IS NULL	
	BEGIN
		SELECT @MoneyTo = ROUND(cr.Rate * @MoneyFrom, 7)
		FROM mno.CurrencyRate cr 
		WHERE cr.CurrencyFrom = @CurrencyFrom
				AND cr.CurrencyTo = @CurrencyTo
				AND cr.IsCurrent = 1
	END
	ELSE
	--historical rate
	BEGIN
		SELECT TOP 1 @MoneyTo = ROUND(cr.Rate * @MoneyFrom, 7)
		FROM mno.CurrencyRate cr 
		WHERE cr.CurrencyFrom = @CurrencyFrom
				AND cr.CurrencyTo = @CurrencyTo
				AND cr.EffectiveFrom <= @Date
		ORDER BY cr.EffectiveFrom DESC

		IF @MoneyTo IS NULL
			SELECT TOP 1 @MoneyTo = ROUND((1/cr.Rate) * @MoneyFrom, 7)
			FROM mno.CurrencyRate cr 
			WHERE cr.CurrencyTo = @CurrencyFrom
				AND cr.CurrencyFrom = @CurrencyTo
				AND cr.EffectiveFrom <= @Date
			ORDER BY cr.EffectiveFrom DESC
	END

	IF @MoneyFrom IS NOT NULL AND @MoneyTo IS NULL
		RETURN CAST('No exchange rate exists for pair: ' + @CurrencyFrom + '->' + @CurrencyTo as int);

	RETURN @MoneyTo
END
