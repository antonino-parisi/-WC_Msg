CREATE ROLE [role_app_puppetvalidator]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_puppetvalidator] ADD MEMBER [app_puppetvalidator];

