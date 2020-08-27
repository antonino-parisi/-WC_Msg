-- =============================================
-- Author:        Shchekalov Anton
-- Create date: 2017-05-19
-- =============================================
-- EXEC cp.[ReportTemplate_GetAll] @AccountUid = '619250fe-e2e5-e611-813f-06b9b96ca965', @UserId = '619250fe-e2e5-e611-813f-06b9b96ca965'
CREATE PROCEDURE [cp].[ReportTemplate_GetAll]
    @AccountUid uniqueidentifier,
    @UserId uniqueidentifier -- designed for possible future usage
AS
BEGIN
    SELECT rt.TemplateId, rt.TemplateName, rt.SettingsJson
    FROM cp.ReportTemplate rt
    WHERE rt.AccountUid = @AccountUid AND rt.DeletedAt IS NULL 
        AND rt.ReportId = 1 /* hardcoded, designed for future usage */
    ORDER BY rt.TemplateName ASC
END
