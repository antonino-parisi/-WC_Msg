
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-08-21
-- Description:	WhatsApp template view
-- =============================================
CREATE VIEW [ipm].[vwWhatsAppTemplate]
AS
	SELECT 
		t.Id AS TemplateId,
		a.AccountUid, 
		a.AccountId,
		ch.[Name] AS WhatsAppInstance,
		t.TemplateName,
		t.[Text],
		l.LanguageCode,
		l.UserFriendlyName AS [Language],		
		c.UserFriendlyName AS Category,		
		s.UserFriendlyName AS [Status],
		t.CreatedAt,
		t.UpdatedAt
	FROM ipm.WhatsAppTemplate t
		INNER JOIN ipm.Channel ch on t.ChannelId = ch.ChannelId
		INNER JOIN cp.Account a on ch.AccountUid = a.AccountUid
		LEFT JOIN ipm.WhatsAppTemplateCategory c ON t.CategoryId = c.CategoryId
		LEFT JOIN ipm.WhatsAppTemplateLanguage l ON t.Language = l.LanguageCode
		LEFT JOIN ipm.WhatsAppTemplateStatus s ON t.StatusId = s.StatusId
