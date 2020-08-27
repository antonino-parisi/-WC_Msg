-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-10
-- =============================================
-- EXEC cp.CmSmsTemplate_Save @AccountUid='499250FE-E2E5-E611-813F-06B9B96CA965', @TemplateName='Welcome sms', @SenderId = 'INFO123', @MessageBody = 'Hello2 {Firstname}'
CREATE PROCEDURE [cp].[CmSmsTemplate_Save]
	@AccountUid uniqueidentifier, 
	@TemplateName nvarchar(50),
	@SenderId varchar(16),
	@MessageBody nvarchar(1600)
AS
BEGIN
	
	IF EXISTS (SELECT 1 FROM cp.CmSmsTemplate WHERE AccountUid = @AccountUid AND TemplateName = @TemplateName)
		UPDATE cp.CmSmsTemplate 
		SET SenderId = @SenderId, MessageBody = @MessageBody, LastUpdatedAt = SYSUTCDATETIME()
		OUTPUT inserted.TemplateId
		WHERE AccountUid = @AccountUid AND TemplateName = @TemplateName
	ELSE
		INSERT INTO cp.CmSmsTemplate (AccountUid, TemplateName, SenderId, MessageBody, LastUpdatedAt)
		OUTPUT inserted.TemplateId
		VALUES (@AccountUid, @TemplateName, @SenderId, @MessageBody, SYSUTCDATETIME())

END
