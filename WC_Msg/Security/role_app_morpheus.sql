CREATE ROLE [role_app_morpheus]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_morpheus] ADD MEMBER [app_morpheus];

