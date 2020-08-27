-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-12-21
-- =============================================
-- EXEC map.[CustomerGroupCoverage_GetCountries] @CustomerGroupId = 70
CREATE PROCEDURE [map].[CustomerGroupCoverage_GetCountries]
	@CustomerGroupId int	--filter
AS
BEGIN

	-- Main select
	SELECT cgc.Country, c.CountryName, COUNT(cgc.CoverageId) AS RulesQty
	--SELECT *
	FROM rt.CustomerGroupCoverage cgc
		INNER JOIN mno.Country c ON cgc.Country = c.CountryISO2alpha
	WHERE cgc.CustomerGroupId = @CustomerGroupId AND cgc.Deleted = 0
		--AND ((@SubAccountUid IS NULL AND cgc.SubAccountUid IS NULL) OR 
		--	 (@SubAccountUid IS NOT NULL AND cgc.SubAccountUid = @SubAccountUid))
	GROUP BY cgc.Country, c.CountryName
	ORDER BY Country
END
