-- =============================================
-- Author:		RAUL TORREFIEL
-- Create date: 2020-01-16
-- Based from map.Account_SubAccount_GetAll
-- =============================================
-- EXEC cp.Account_SubAccount_GetAll @AccountUid='5C9250FE-E2E5-E611-813F-06B9B96CA965'
CREATE PROCEDURE [cp].[Account_SubAccount_GetAll]
	@AccountUid uniqueidentifier
AS
BEGIN

	SELECT 
        s.SubAccountUid,
        s.SubAccountId,
		a.Product_SMS,
        a.Product_CA,
        a.Product_VI,
        a.Product_VO,
        ISNULL(shrt.IsActive, 0) AS UrlShortenerEnabled
	FROM  ms.SubAccount s
		LEFT JOIN cp.Account a
			ON a.AccountUid = s.AccountUid
        LEFT JOIN ms.UrlShortenDomainSubAccount shrt ON s.SubAccountUid = shrt.SubAccountUid
        
	WHERE s.AccountUid = @AccountUid AND s.Active = 1 ;
END
