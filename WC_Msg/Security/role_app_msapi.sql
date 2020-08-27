CREATE ROLE [role_app_msapi]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_msapi] ADD MEMBER [app_msapi];

