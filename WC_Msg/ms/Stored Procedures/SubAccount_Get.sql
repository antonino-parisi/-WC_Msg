---
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-09-30
-- Description:	Load SubAccount configuration
-- =============================================
-- EXEC [ms].[SubAccount_Get] @AccountUid = 'CE23F695-189D-E711-8141-06B9B96CA965'
-- EXEC [ms].[SubAccount_Get] @SubAccountUid = 1186
-- EXEC [ms].[SubAccount_Get] @SubAccountUid = 1186, @AccountUid = 'CE23F695-189D-E711-8141-06B9B96CA965'
CREATE PROCEDURE [ms].[SubAccount_Get]
	@SubAccountUid INT = NULL,			-- @SubAccountUid OR @AccountUid must be set
	@AccountUid UNIQUEIDENTIFIER = NULL	-- @SubAccountUid OR @AccountUid must be set
AS
BEGIN
	SELECT 
		a.AccountUid,
		a.AccountId,
		sa.SubAccountUid,
		sa.SubAccountId,		
		sa.Product_SMS AS SmsEnabled,
		sa.Product_CA AS ChatAppsEnabled
	FROM ms.SubAccount sa
		INNER JOIN cp.Account a on sa.AccountUid = a.AccountUid
	WHERE 
		(sa.SubAccountUid = @SubAccountUid OR sa.AccountUid = @AccountUid) 
		AND sa.Active = 1
END
