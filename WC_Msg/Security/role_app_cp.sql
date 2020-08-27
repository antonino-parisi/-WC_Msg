CREATE ROLE [role_app_cp]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_cp] ADD MEMBER [app_cp];

