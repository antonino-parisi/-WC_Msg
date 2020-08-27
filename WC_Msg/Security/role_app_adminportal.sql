CREATE ROLE [role_app_adminportal]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_adminportal] ADD MEMBER [app_web_adminportal];

