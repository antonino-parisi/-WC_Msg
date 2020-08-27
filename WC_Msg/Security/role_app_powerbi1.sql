CREATE ROLE [role_app_powerbi1]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_powerbi1] ADD MEMBER [app_powerbi];

