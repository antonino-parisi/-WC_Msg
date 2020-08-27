-- =============================================
-- Author:		RAUL TORREFIEL
-- Create date: 2020-05-14
-- Get SMS Engage Subaccounts survey forms
-- =============================================
-- EXEC cp.SMS_Engage_SubAccounts_GetAll @AccountUid='2318BDEB-C250-E711-8141-06B9B96CA965', @UserId='2A793B40-1E23-47F4-9A95-7662822EE5DC'
CREATE PROCEDURE [cp].[SMS_Engage_SubAccounts_GetAll]
    @AccountUid uniqueidentifier,
    @UserId uniqueidentifier
AS
BEGIN

    SELECT DISTINCT
        sa.SubAccountUid,
		sa.SubAccountId,
        sa.Product_SMS
    FROM ms.SubAccount sa
	    INNER JOIN ms.Survey s ON s.SubAccountUid = sa.SubAccountUid 
		-- Get accessible subaccounts
		INNER JOIN cp.fnSubAccount_GetByUser (@AccountUid, @UserId, NULL, NULL, NULL, NULL, NULL) su 
			ON su.SubAccountUid = sa.SubAccountUid
	WHERE
		s.Active = 1 AND
        sa.Product_SMS = 1;
END
