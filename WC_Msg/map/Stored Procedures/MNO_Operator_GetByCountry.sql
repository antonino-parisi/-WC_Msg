-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-04
-- =============================================
-- EXEC map.MNO_Operator_GetByCountry @Country = 'SG'
CREATE PROCEDURE [map].[MNO_Operator_GetByCountry]
	@Country char(2) = NULL
AS
BEGIN

	SELECT o.CountryISO2alpha, c.CountryName, o.OperatorName, o.OperatorId
	FROM mno.Operator o
		LEFT JOIN mno.Country c ON o.CountryISO2alpha = c.CountryISO2alpha
	WHERE 
		(@Country IS NULL OR (@Country IS NOT NULL AND o.CountryISO2alpha = @Country))
		AND o.Active = 1
	ORDER BY o.CountryISO2alpha, o.OperatorName

END
