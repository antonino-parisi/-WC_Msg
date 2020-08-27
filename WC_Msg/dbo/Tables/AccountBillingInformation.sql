CREATE TABLE [dbo].[AccountBillingInformation] (
    [AccountId]          NVARCHAR (50)  NOT NULL,
    [AccountInformation] NVARCHAR (MAX) NOT NULL,
    [SubscriptionDate]   DATETIME       NULL,
    [NextBillingDate]    DATETIME       NULL,
    [Plan]               INT            NULL,
    [NameContact]        NVARCHAR (MAX) NULL,
    [CompanyName]        NVARCHAR (MAX) NULL,
    [Website]            NVARCHAR (MAX) NULL,
    [Address]            NVARCHAR (MAX) NULL,
    [PostCode]           DECIMAL (18)   NULL,
    [Country]            NVARCHAR (50)  NULL,
    [Phone]              NVARCHAR (MAX) NULL,
    [BillingEmail]       NVARCHAR (MAX) NULL,
    [TechnicalEmail]     NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AccountBillingInformation] PRIMARY KEY CLUSTERED ([AccountId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'5C503E21-22C6-81FA-620B-F369B8EC38D1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'AccountInformation';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Contact Info', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'AccountInformation';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'AccountInformation';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'AccountInformation';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = '5c503e21-22c6-81fa-620b-f369b8ec38d1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Contact Info', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '684a0db2-d514-49d8-8c0c-df84a7b083eb', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'General', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'5C503E21-22C6-81FA-620B-F369B8EC38D1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Contact Info', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'989ADC05-3F3F-0588-A635-F475B994915B', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential - GDPR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'5C503E21-22C6-81FA-620B-F369B8EC38D1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'BillingEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Contact Info', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'BillingEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'BillingEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'BillingEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'5C503E21-22C6-81FA-620B-F369B8EC38D1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'TechnicalEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Contact Info', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'TechnicalEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'989ADC05-3F3F-0588-A635-F475B994915B', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'TechnicalEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential - GDPR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBillingInformation', @level2type = N'COLUMN', @level2name = N'TechnicalEmail';

