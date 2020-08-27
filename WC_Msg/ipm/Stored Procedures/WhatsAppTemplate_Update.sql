
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-09-05
-- Description:	Update WhatsApp template
-- =============================================
CREATE PROCEDURE [ipm].[WhatsAppTemplate_Update]	
	@TemplateId	int,
	@Text		nvarchar(2000),
	@CategoryId	int,
	@Language	varchar(5),
	@StatusId	int,
	@Components nvarchar(4000) NULL
AS
BEGIN
	UPDATE ipm.WhatsAppTemplate
	SET 
		[Text] = @Text, 
		CategoryId = @CategoryId, 
		[Language] = @Language, 
		StatusId = @StatusId,
		UpdatedAt = SYSUTCDATETIME(),
		Components = @Components
	WHERE Id = @TemplateId
END