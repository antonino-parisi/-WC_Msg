CREATE ROLE [role_app_currencyuploader]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_app_currencyuploader] ADD MEMBER [app_currencyuploader];

