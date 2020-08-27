CREATE ROLE [role_app_smpp]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_smpp] ADD MEMBER [app_smpp];

