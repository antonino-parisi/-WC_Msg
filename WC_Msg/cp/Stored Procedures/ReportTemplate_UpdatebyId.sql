-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-05-19
-- =============================================
-- EXEC cp.[ReportTemplate_UpdatebyId] @AccountUid = '619250fe-e2e5-e611-813f-06b9b96ca965', @UserId = '619250fe-e2e5-e611-813f-06b9b96ca965', ...
CREATE PROCEDURE [cp].[ReportTemplate_UpdatebyId]
	@AccountUid uniqueidentifier,
	@TemplateId int = NULL, -- nullable, pass NULL if add new Template or value, if it's update for existing one
	@TemplateName nvarchar(50),
	@SettingsJson nvarchar(4000),
	@UserId uniqueidentifier -- designed for possible future usage
AS
BEGIN
	DECLARE @ReportId smallint = 1

	IF @TemplateId IS NULL
	BEGIN
		INSERT INTO cp.ReportTemplate (AccountUid, ReportId, TemplateName, SettingsJson, CreatedBy, UpdatedBy)
		OUTPUT inserted.TemplateId
		VALUES (@AccountUid, @ReportId, @TemplateName, @SettingsJson, @UserId, @UserId)
	END
	ELSE
	BEGIN
		UPDATE cp.ReportTemplate
		SET TemplateName = @TemplateName, SettingsJson = @SettingsJson,
			UpdatedAt = GETUTCDATE(), UpdatedBy = @UserId
		WHERE TemplateId = @TemplateId 
			AND AccountUid = @AccountUid AND ReportId = @ReportId 
			AND DeletedAt IS NULL
	END
END
