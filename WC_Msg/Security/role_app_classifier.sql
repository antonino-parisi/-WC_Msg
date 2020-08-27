CREATE ROLE [role_app_classifier]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_classifier] ADD MEMBER [app_classifier];

