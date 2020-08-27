-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2019-05-13
-- =============================================
-- EXEC mno.GetCurrencyPairs 

CREATE PROCEDURE [mno].[CurrencyPair_GetAll]
AS
BEGIN
	SET NOCOUNT ON ;

	SELECT * FROM mno.CurrencyPair WITH (NOLOCK) ;

END 
