CREATE ROLE [role_app_map]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_map] ADD MEMBER [app_map];

