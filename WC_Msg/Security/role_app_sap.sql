CREATE ROLE [role_app_sap]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_sap] ADD MEMBER [app_sap];


GO
ALTER ROLE [role_app_sap] ADD MEMBER [user_ext_sap];

