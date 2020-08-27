
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-03-10
-- =============================================
-- EXEC cp.CmSmsTemplate_GetAll @AccountUid='499250FE-E2E5-E611-813F-06B9B96CA965'
CREATE PROCEDURE [cp].[CmSmsTemplate_GetAll]
	@AccountUid uniqueidentifier
AS
BEGIN
	
	DECLARE @ResultT TABLE (TemplateId int, TemplateName nvarchar(50), SenderId varchar(16), MessageBody nvarchar(1600))

	INSERT INTO @ResultT (TemplateId, TemplateName, SenderId, MessageBody)
	SELECT TOP (200) TemplateId, TemplateName, SenderId, MessageBody
	FROM cp.CmSmsTemplate
	WHERE AccountUid = @AccountUid
	ORDER BY TemplateName
	
	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO @ResultT (TemplateId, TemplateName, SenderId, MessageBody) VALUES (0, 'Demo', 'Demo', 'Greetings from SMS Sender!')
	END

	SELECT TemplateId, TemplateName, SenderId, MessageBody FROM @ResultT
END

