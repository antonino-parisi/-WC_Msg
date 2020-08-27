CREATE ROLE [role_app_supplier]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_supplier] ADD MEMBER [app_supplier];

