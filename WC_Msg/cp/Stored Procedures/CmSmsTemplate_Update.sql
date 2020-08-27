-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-01-18
-- =============================================
-- EXEC cp.CmSmsTemplate_Update @AccountUid='499250FE-E2E5-E611-813F-06B9B96CA965', @TemplateId = 1, @TemplateName='Welcome sms', @SenderId = 'INFO123', @MessageBody = 'Hello2 {Firstname}'
CREATE PROCEDURE [cp].[CmSmsTemplate_Update]
	@AccountUid uniqueidentifier,
	@TemplateId int,
	@TemplateName nvarchar(50),
	@SenderId varchar(16),
	@MessageBody nvarchar(1600)
AS
BEGIN
	
	UPDATE cp.CmSmsTemplate 
	SET TemplateName = @TemplateName, SenderId = @SenderId, MessageBody = @MessageBody, LastUpdatedAt = SYSUTCDATETIME()
	OUTPUT inserted.TemplateId
	WHERE AccountUid = @AccountUid AND TemplateId = @TemplateId

END
