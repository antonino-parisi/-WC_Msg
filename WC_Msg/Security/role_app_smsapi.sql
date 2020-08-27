CREATE ROLE [role_app_smsapi]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_smsapi] ADD MEMBER [app_smsapi];

