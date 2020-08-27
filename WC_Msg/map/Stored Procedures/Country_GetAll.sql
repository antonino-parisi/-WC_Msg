
-- =============================================
-- Author:		Nathanael Hinay
-- Create date: 2019-11-22
-- =============================================
-- EXEC map.Country_GetAll
CREATE PROCEDURE [map].[Country_GetAll]
AS
BEGIN

	SELECT CountryISO2alpha, CountryName, DialCode
	FROM mno.Country
	ORDER BY CountryName

END
