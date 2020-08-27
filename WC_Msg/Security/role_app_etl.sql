CREATE ROLE [role_app_etl]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_etl] ADD MEMBER [app_etl];

