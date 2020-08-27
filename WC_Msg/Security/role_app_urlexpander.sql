CREATE ROLE [role_app_urlexpander]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_urlexpander] ADD MEMBER [app_urlexpander];

