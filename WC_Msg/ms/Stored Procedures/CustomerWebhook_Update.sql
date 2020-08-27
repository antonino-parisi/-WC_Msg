
---
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-12-10
-- Description:	Update Account webhooks by Webhook Management API
-- =============================================
-- GRANT EXECUTE ON [ms].[CustomerWebhook_Update] TO role_app_smsapi
CREATE PROCEDURE [ms].[CustomerWebhook_Update]
	@WebHookId int,
	@Url nvarchar(500),
	@Version tinyint,
	@HttpAuthorizationHeader nvarchar(1024),
	@Active bit,
	@HttpContentType varchar(50)
AS
BEGIN
	
	UPDATE ms.CustomerWebhook SET 
		[Url] = @Url,
		[Version] = @Version,
		HttpAuthorizationHeader = @HttpAuthorizationHeader,
		HttpContentType = @HttpContentType,
		Active = @Active,
		Deleted = 0
	WHERE WebHookId = @WebHookId
END
