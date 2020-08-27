-- =============================================
-- Author: Anton Shchekalov
-- Create date: 2020-05-12
-- Description: To get the currencies
-- Usage : EXEC ms.CurrencyRate_GetAll
CREATE PROCEDURE ms.CurrencyRate_GetAll
AS
BEGIN

	SELECT CurrencyFrom, CurrencyTo, Rate, EffectiveFrom 
	FROM mno.CurrencyRate cr WITH (NOLOCK)
	WHERE cr.IsCurrent = 1
	ORDER BY cr.CurrencyFrom

END
