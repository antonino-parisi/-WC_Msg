---
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-12-10
-- Description:	Add Account webhooks by Webhook Management API
-- =============================================
-- GRANT EXECUTE ON [ms].[CustomerWebhook_Add] TO role_app_smsapi
CREATE PROCEDURE [ms].[CustomerWebhook_Add]
	@AccountUid uniqueidentifier,
	@SubAccountUid int,
	@Type varchar(5),
	@Url nvarchar(500),
	@Version tinyint,
	@HttpAuthorizationHeader nvarchar(1024),
	@Active bit,
	@HttpContentType varchar(50)
AS
BEGIN
	
	INSERT INTO ms.CustomerWebhook (AccountUid, SubAccountUid, [Type], [Url], [Version],
		HttpAuthorizationHeader, Active, HttpContentType)
	VALUES (@AccountUid, @SubAccountUid, @Type, @Url, @Version,
		@HttpAuthorizationHeader, @Active, @HttpContentType)
		
END
