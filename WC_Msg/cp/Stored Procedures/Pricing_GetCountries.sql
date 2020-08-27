-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-07-20
-- List of countries, where account has coverage
-- =============================================
-- EXEC cp.Pricing_GetCountries @AccountUid = '0FC250D4-6182-E711-8143-02D85F55FCE7'
CREATE PROCEDURE [cp].[Pricing_GetCountries]
	@AccountUid uniqueidentifier
WITH EXECUTE AS OWNER
AS
BEGIN

	-- prepare list of SubAccountUids as it used multiple times
	DECLARE @SubAccountT TABLE (SubAccountUid int UNIQUE)
    INSERT INTO @SubAccountT (SubAccountUid) 
	SELECT sa.SubAccountUid
	FROM 
		cp.Account ca
		INNER JOIN dbo.Account sa ON sa.AccountId = ca.AccountId
	WHERE ca.AccountUid = @AccountUid
		AND ca.Deleted = 0
		AND sa.Active = 1 AND sa.Deleted = 0
	

	SELECT c.CountryISO2alpha, c.CountryName
	FROM 	
		(	
			-- member routing
			SELECT cgcS.Country
			FROM 
				@SubAccountT sa
				INNER JOIN rt.CustomerGroupCoverage cgcS ON 
					sa.SubAccountUid = cgcS.SubAccountUid AND cgcS.Deleted = 0 -- filter subaccounts
	
			UNION 
	
			-- group routing
			SELECT cgcD.Country
			FROM 
				@SubAccountT sa
				INNER JOIN rt.CustomerGroupSubAccount cgs ON 
					cgs.SubAccountUid = sa.SubAccountUid AND
					cgs.Deleted = 0
				INNER JOIN rt.CustomerGroupCoverage cgcD ON 
					cgcD.CustomerGroupId = cgs.CustomerGroupId AND
					cgcD.SubAccountUid IS NULL AND 
					cgcD.Deleted = 0
			
			UNION 
	
			-- default routing
			SELECT ppc.Country
			FROM 
				@SubAccountT sa
				INNER JOIN rt.SubAccount_Default sd ON 
					sd.SubAccountUid = sa.SubAccountUid AND
					sd.Deleted = 0
				INNER JOIN rt.PricingPlanCoverage ppc ON 
					ppc.PricingPlanId = sd.PricingPlanId_Default AND
					ppc.Deleted = 0
	
		) l
		INNER JOIN mno.Country c ON l.Country = c.CountryISO2alpha
	ORDER BY c.CountryName
END
