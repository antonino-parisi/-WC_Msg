
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-31
-- Description:	Return Numbering plan countries to MessageSphere cache. Special case when one CountryCode is used by few countries.
-- =============================================
CREATE PROCEDURE [dbo].[sp_RoutingMatrix_PopulateCountriesWithIntersectingCode]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT LEFT(Prefix,LEN(CountryCode)+3) AS Prefix, Country 
	FROM dbo.NumberingPlan 
	WHERE CountryCode IN ('1', '7', '44', '252', '90', '262', '64', '358', '373', '374', '377')
		AND LEN(Prefix) > 1
	ORDER BY Prefix
END