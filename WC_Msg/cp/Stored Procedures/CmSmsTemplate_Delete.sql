-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-01-17
-- =============================================
-- EXEC cp.CmSmsTemplate_Delete @AccountUid='499250FE-E2E5-E611-813F-06B9B96CA965', @TemplateId=123
CREATE PROCEDURE [cp].[CmSmsTemplate_Delete]
	@AccountUid uniqueidentifier, 
	@TemplateId int
AS
BEGIN
	
	DELETE FROM cp.CmSmsTemplate 
	WHERE AccountUid = @AccountUid AND TemplateId = @TemplateId

END
