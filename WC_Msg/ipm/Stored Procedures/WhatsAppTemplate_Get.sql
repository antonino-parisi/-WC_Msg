
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-08-30
-- Description:	Load WhatsApp templates
-- =============================================
-- EXEC ipm.WhatsAppTemplate_Get @AccountUid = 'E923F695-189D-E711-8141-06B9B96CA965'
-- EXEC ipm.WhatsAppTemplate_Get @AccountUid = 'E923F695-189D-E711-8141-06B9B96CA965', @WhatsAppId = 'EA4D001F-87CF-E911-8156-06B9B96CA965'
-- =============================================
CREATE PROCEDURE [ipm].[WhatsAppTemplate_Get]
	@AccountUid uniqueidentifier,
	@WhatsAppId uniqueidentifier = NULL
AS
BEGIN

	SELECT 
		t.Id,
		t.ChannelId AS WhatsAppId,
		c.[Name] AS WhatsAppName,
		t.TemplateName,
		t.[Text],
		t.[Language],
		t.TemplateId,
		t.CategoryId,		
		t.StatusId,
		t.CreatedAt,
		t.UpdatedAt,
		t.Components
	FROM ipm.WhatsAppTemplate t
		INNER JOIN ipm.Channel c ON t.ChannelId = c.ChannelId
	WHERE c.AccountUid = @AccountUid AND 
		(@WhatsAppId IS NULL OR t.ChannelId = @WhatsAppId)
END
