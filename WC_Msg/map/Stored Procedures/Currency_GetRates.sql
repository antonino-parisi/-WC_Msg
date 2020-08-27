-- =============================================
-- Author: Rebecca Loh
-- Create date: 08 Aug 2019
-- Description: To get the currencies
-- Usage : EXEC map.Currency_GetRates @CurrencyFrom='USD'
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
CREATE PROCEDURE [map].[Currency_GetRates]
	@CurrencyFrom char(3) = NULL,
	@CurrencyTo char(3) = 'EUR',
	@Date date = NULL
AS
BEGIN
	SELECT DISTINCT 
		c.Currency, 
		c.CurrencyName, 
		r.CurrencyTo, 
		r.Rate, 
		r.EffectiveFrom
	FROM mno.Currency c WITH (NOLOCK)
		CROSS APPLY
		(	SELECT TOP 1 CurrencyFrom, CurrencyTo, Rate, EffectiveFrom 
			FROM mno.CurrencyRate WITH (NOLOCK)
			WHERE CurrencyTo = @CurrencyTo
				AND (@Date IS NULL OR EffectiveFrom <= @Date)
				AND CurrencyFrom = c.Currency
			ORDER BY EffectiveFrom DESC
		) r
	WHERE (@CurrencyFrom IS NULL OR c.Currency = @CurrencyFrom) ;
END
