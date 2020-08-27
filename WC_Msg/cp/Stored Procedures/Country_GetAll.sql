
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-20
-- =============================================
-- EXEC cp.Country_GetAll
CREATE PROCEDURE [cp].[Country_GetAll]
AS
BEGIN

	SELECT CountryISO2alpha, CountryName, DialCode
	FROM mno.Country
	ORDER BY CountryName

END
