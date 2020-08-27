
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-04-07
-- Description:	List of Countries
-- =============================================
-- Examples:
-- EXEC rt.Country_GetAll
-- =============================================
CREATE PROCEDURE [rt].[Country_GetAll]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CountryISO2alpha, CountryName, ISNULL(MCCDefault, 0) AS MCCDefault, Continent, Currency, DialCode, ISNULL(JsonData, '') AS JsonData
	FROM mno.Country

END

