
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-04
-- =============================================
-- EXEC map.MNO_Country_GetAll
CREATE PROCEDURE [map].[MNO_Country_GetAll]
AS
BEGIN

	SELECT 
		CountryISO2alpha, 
		CountryName, 
		ISNULL(MCCDefault, 0) AS MCCDefault, 
		Continent, 
		Currency, 
		DialCode, 
		ISNULL(JsonData, '') AS JsonData
    FROM mno.Country

END
