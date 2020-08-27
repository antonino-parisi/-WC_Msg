-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2019-11-28
-- Description:	Get subaccounts info given AccountUid
-- =============================================
-- EXEC map.Account_SubAccount_GetAll @AccountUid='076A6104-0483-E711-8143-02D85F55FCE7'

CREATE PROCEDURE [map].[Account_SubAccount_GetAll]
	@AccountUid uniqueidentifier
AS
BEGIN

	SELECT AccountUid, Product_SMS, Product_CA, Product_VI, Product_VO
	FROM cp.Account
	WHERE AccountUid = @AccountUid ;

	SELECT
		sa.SubAccountUid, sa.SubAccountId, 
        sa.Active,  -- Added to set active or inactive sub-account specifically | https://wavecellagile.atlassian.net/browse/MAP-793
		sa.Product_SMS, sa.Product_CA, a.Product_VI, sa.Product_VO,
		cgs.CustomerGroupId, cg.CustomerGroupName -- TODO: this columns are SMS specific, not ideal place
	FROM  ms.SubAccount sa
		INNER JOIN cp.Account a
			ON a.AccountUid = sa.AccountUid
		LEFT JOIN rt.CustomerGroupSubAccount cgs
			ON sa.SubAccountUid = cgs.SubAccountUid AND cgs.Deleted = 0
		LEFT JOIN rt.CustomerGroup cg
			ON cgs.CustomerGroupId = cg.CustomerGroupId AND cg.Deleted = 0
	WHERE a.AccountUid = @AccountUid;

END
