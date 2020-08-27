CREATE ROLE [role_app_modeanalytics]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_modeanalytics] ADD MEMBER [app_modeanalytics];

