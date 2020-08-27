
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-09-05
-- Description:	Load WhatsApp templates
-- =============================================
CREATE PROCEDURE [ipm].[WhatsAppTemplate_GetAll]
AS
BEGIN
	SELECT 
		Id, 
		ChannelId AS WhatsAppId, 
		TemplateName,
		[Text],
		[Language],
		TemplateId,
		CategoryId,		
		StatusId,
		CreatedAt,
		UpdatedAt,
		Components
	FROM ipm.WhatsAppTemplate
END
