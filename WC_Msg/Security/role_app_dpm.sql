CREATE ROLE [role_app_dpm]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_dpm] ADD MEMBER [app_dpm];

