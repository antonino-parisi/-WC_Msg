-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-01-18
-- =============================================
-- EXEC cp.CmSmsTemplate_Insert @AccountUid='499250FE-E2E5-E611-813F-06B9B96CA965', @TemplateName='Welcome sms', @SenderId = 'INFO123', @MessageBody = 'Hello2 {Firstname}'
CREATE PROCEDURE [cp].[CmSmsTemplate_Insert]
	@AccountUid uniqueidentifier, 
	@TemplateName nvarchar(50),
	@SenderId varchar(16),
	@MessageBody nvarchar(1600)
AS
BEGIN
	
	INSERT INTO cp.CmSmsTemplate (AccountUid, TemplateName, SenderId, MessageBody, LastUpdatedAt)
	OUTPUT inserted.TemplateId
	VALUES (@AccountUid, @TemplateName, @SenderId, @MessageBody, SYSUTCDATETIME())

END
