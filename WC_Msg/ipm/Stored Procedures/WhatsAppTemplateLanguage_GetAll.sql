
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-08-20
-- Description:	Load WhatsApp template maps
-- =============================================
CREATE PROCEDURE [ipm].[WhatsAppTemplateLanguage_GetAll]
AS
BEGIN
	SELECT LanguageCode, UserFriendlyName
	FROM ipm.WhatsAppTemplateLanguage
END
