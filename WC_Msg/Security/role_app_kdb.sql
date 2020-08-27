CREATE ROLE [role_app_kdb]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_kdb] ADD MEMBER [app_kdb];

