CREATE ROLE [role_app_voice_api]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_voice_api] ADD MEMBER [app_voice_api];


GO
ALTER ROLE [role_app_voice_api] ADD MEMBER [app_voice_msg_api];

