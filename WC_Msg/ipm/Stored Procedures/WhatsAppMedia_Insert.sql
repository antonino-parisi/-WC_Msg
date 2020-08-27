

-- =============================================
-- Author:		Igor Valyansky
-- Created date: 2019-09-05
-- Description:	Add mediaId of uploaded content
-- =============================================
CREATE PROCEDURE [ipm].[WhatsAppMedia_Insert]
	@MediaId uniqueidentifier,
	@WhatsAppId uniqueidentifier,
	@Url nvarchar(1000)
AS
BEGIN		
	INSERT INTO ipm.WhatsAppMedia (Id, ChannelId, [Url]) 
	VALUES (@MediaId, @WhatsAppId, @Url)
END
