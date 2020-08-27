CREATE ROLE [role_app_reportingapi]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_reportingapi] ADD MEMBER [app_reportingapi];

