CREATE ROLE [role_app_dbchanges]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_dbchanges] ADD MEMBER [app_messagesphere2];


GO
ALTER ROLE [role_app_dbchanges] ADD MEMBER [app_morpheus];


GO
ALTER ROLE [role_app_dbchanges] ADD MEMBER [app_smsapi];


GO
ALTER ROLE [role_app_dbchanges] ADD MEMBER [app_smpp];


GO
ALTER ROLE [role_app_dbchanges] ADD MEMBER [app_reportingapi];

