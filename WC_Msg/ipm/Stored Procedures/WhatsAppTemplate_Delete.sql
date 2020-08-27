

-- =============================================
-- Author:        Igor Valyansky
-- Create date:   2019-09-05
-- Description:   Delete WhatsApp template
-- =============================================
CREATE PROCEDURE [ipm].[WhatsAppTemplate_Delete]	
	@WhatsAppId    uniqueidentifier,
    @TemplateId    bigint,
    @Language      varchar(5)
AS
BEGIN
    DELETE ipm.WhatsAppTemplate
    WHERE ChannelId = @WhatsAppId AND 
        TemplateId = @TemplateId AND 
        [Language] = @Language
END
