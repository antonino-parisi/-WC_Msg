---
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-12-10
-- Description:	Delete Account webhook by Webhook Management API
-- =============================================
-- GRANT EXECUTE ON [ms].[CustomerWebhook_Delete] TO role_app_smsapi
CREATE PROCEDURE [ms].[CustomerWebhook_Delete]
	@WebHookId int
AS
BEGIN
	
	UPDATE ms.CustomerWebhook
		SET Deleted = 1, Active = 0
	WHERE WebHookId = @WebHookId
		
END
