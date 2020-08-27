
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-04
-- =============================================
-- EXEC map.MNO_Operator_GetAll
CREATE PROCEDURE [map].[MNO_Operator_GetAll]
AS
BEGIN

	SELECT o.CountryISO2alpha, c.CountryName, o.OperatorName, o.OperatorId
	FROM mno.Operator o
		LEFT JOIN mno.Country c ON o.CountryISO2alpha = c.CountryISO2alpha
	WHERE o.Active = 1
	ORDER BY o.CountryISO2alpha, o.OperatorName

END

