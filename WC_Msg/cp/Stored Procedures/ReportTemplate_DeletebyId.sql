-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-05-19
-- =============================================
-- EXEC cp.[ReportTemplate_DeletebyId] @AccountUid = '619250fe-e2e5-e611-813f-06b9b96ca965', @TemplateId=123, @UserId = '619250fe-e2e5-e611-813f-06b9b96ca965'
CREATE PROCEDURE [cp].[ReportTemplate_DeletebyId]
	@AccountUid uniqueidentifier,
	@TemplateId int,
	@UserId uniqueidentifier -- designed for possible future usage
AS
BEGIN
	DECLARE @ReportId smallint = 1

	--UPDATE cp.ReportTemplate
	--SET DeletedAt = GETUTCDATE()
	--WHERE TemplateId = @TemplateId 
	--	AND AccountUid = @AccountUid AND ReportId = @ReportId 
	--	AND DeletedAt IS NULL

	DELETE FROM cp.ReportTemplate
	WHERE TemplateId = @TemplateId 
		AND AccountUid = @AccountUid AND ReportId = @ReportId 
		AND DeletedAt IS NULL
END
