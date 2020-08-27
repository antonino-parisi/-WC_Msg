
---
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-12-10
-- Description:	Get Account webhooks for Webhook Management API
-- =============================================
-- EXEC [ms].[CustomerWebhook_Get] @AccountUid = 'E923F695-189D-E711-8141-06B9B96CA965'
-- GRANT EXECUTE ON [ms].[CustomerWebhook_Get] TO role_app_smsapi
CREATE PROCEDURE [ms].[CustomerWebhook_Get]
	@AccountUid uniqueidentifier
AS
BEGIN
	
	SELECT
		w.WebHookId,
		IIF(sa.SubAccountId IS NULL, '*', sa.SubAccountId) AS SubAccountId,
		w.[Type], 
		w.[Url], 
		w.[Version],
		w.HttpAuthorizationHeader,
		w.Active,
		w.HttpContentType,
		w.Deleted
	FROM ms.CustomerWebhook w
		LEFT JOIN ms.SubAccount sa ON w.SubAccountUid = sa.SubAccountUid AND sa.Active = 1
	WHERE w.AccountUid = @AccountUid 
END
