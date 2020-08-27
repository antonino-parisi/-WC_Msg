-- =============================================
-- Author:		Igor Valyansky
-- Created date: 2019-09-05
-- Description:	Get mediaId of uploaded content
-- =============================================
CREATE PROCEDURE [ipm].[WhatsAppMedia_Get]
	@WhatsAppId uniqueidentifier,
	@Url nvarchar(1000)
AS
BEGIN
	SELECT Id AS MediaId, CreatedAt
	FROM ipm.WhatsAppMedia 
	WHERE ChannelId = @WhatsAppId AND [Url] = @Url AND SetInProcessAt IS NULL
END
