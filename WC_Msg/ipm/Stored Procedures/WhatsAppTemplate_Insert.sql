
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-09-05
-- Description:	Add WhatsApp template
-- =============================================
CREATE PROCEDURE [ipm].[WhatsAppTemplate_Insert]	
	@WhatsAppId		uniqueidentifier,
	@TemplateName	varchar(200),
	@Text			nvarchar(2000),
	@TemplateId		bigint,
	@CategoryId		int,
	@Language		varchar(5),
	@StatusId		int,
	@Components     nvarchar(4000) NULL
AS
BEGIN		
	INSERT INTO ipm.WhatsAppTemplate
		(ChannelId, TemplateName, [Text], TemplateId, CategoryId, [Language], StatusId, Components)
	VALUES
		(@WhatsAppId, @TemplateName, @Text, @TemplateId, @CategoryId, @Language, @StatusId, @Components)
END
