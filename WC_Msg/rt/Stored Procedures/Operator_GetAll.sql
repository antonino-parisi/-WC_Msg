
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-05-10
-- Description:	List of Countries and Operators
-- =============================================
-- Examples:
-- EXEC rt.[Operator_GetAll]
-- =============================================
CREATE PROCEDURE [rt].[Operator_GetAll]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT o.CountryISO2alpha, c.CountryName, o.OperatorId, o.OperatorName 
	FROM mno.Operator o
		INNER JOIN mno.Country c ON o.CountryISO2alpha = c.CountryISO2alpha
	ORDER BY o.CountryISO2alpha, o.OperatorId
END
