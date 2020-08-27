CREATE ROLE [role_app_smpplogins]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_smpplogins] ADD MEMBER [app_smpplogins];

