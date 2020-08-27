
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-04-07
-- Description:	List of Countries
-- =============================================
-- Examples:
-- EXEC rt.Country_GetByISOCode 'SG'
-- =============================================
CREATE PROCEDURE [rt].[Country_GetByISOCode]
	@CountryISO2alpha char(2)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CountryISO2alpha, CountryName, ISNULL(MCCDefault, 0) AS MCCDefault, Continent, Currency, DialCode, ISNULL(JsonData, '') AS JsonData
	FROM mno.Country
	WHERE CountryISO2alpha = @CountryISO2alpha

END

