-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-31
-- Description:	Return all Numbering plan countries to MessageSphere cache
-- =============================================

CREATE PROCEDURE [dbo].[sp_RoutingMatrix_PopulateCountries]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT CountryCode, Country
	FROM NumberingPlan
	ORDER BY CountryCode

END
