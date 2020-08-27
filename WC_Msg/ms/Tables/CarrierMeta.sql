CREATE TABLE [ms].[CarrierMeta] (
    [RouteId]                      VARCHAR (50)  NOT NULL,
    [ConnectionType]               VARCHAR (4)   NOT NULL,
    [RouteType]                    VARCHAR (3)   NOT NULL,
    [Country]                      CHAR (2)      NOT NULL,
    [IsActive]                     BIT           NOT NULL,
    [Systemid]                     VARCHAR (50)  NOT NULL,
    [PriceChanges]                 BIT           NOT NULL,
    [Currency]                     CHAR (3)      NOT NULL,
    [SupportEmail]                 VARCHAR (50)  NOT NULL,
    [SupportCCEmails]              VARCHAR (250) NULL,
    [SupportSkype]                 VARCHAR (50)  NULL,
    [SupportPhone]                 VARCHAR (50)  NULL,
    [PortalURL]                    VARCHAR (100) NULL,
    [PortalLogin]                  VARCHAR (50)  NULL,
    [PortalPassword]               VARCHAR (25)  NULL,
    [AccountManagerName]           VARCHAR (50)  NULL,
    [AccountManagerEmail]          VARCHAR (50)  NULL,
    [AccountManagerSkype]          VARCHAR (50)  NULL,
    [AccountManagerPhone]          VARCHAR (50)  NULL,
    [DLRSupported]                 BIT           CONSTRAINT [DF_CarrierMeta_DLRSupported] DEFAULT ((0)) NOT NULL,
    [SupplierSMSCDLR]              BIT           CONSTRAINT [DF_CarrierMeta_SupplierSMSCDLR] DEFAULT ((0)) NOT NULL,
    [WavecellSMSCDLR]              BIT           CONSTRAINT [DF_CarrierMeta_WavecellSMSCDLR] DEFAULT ((0)) NOT NULL,
    [SenderIdRegRequired]          BIT           NOT NULL,
    [SenderIdRegDetails]           VARCHAR (250) NULL,
    [SmppSmscId]                   VARCHAR (50)  NULL,
    [ReconnectionGracePeriodInSec] INT           CONSTRAINT [DF_CarrierMeta_ReconnectionGracePeriodInSec] DEFAULT ((300)) NOT NULL,
    [VPN]                          BIT           NULL,
    [CompanyEntity]                VARCHAR (10)  CONSTRAINT [DF_CarrierMeta_CompanyEntity] DEFAULT ('WSG') NOT NULL,
    CONSTRAINT [PK_CarrierMeta] PRIMARY KEY CLUSTERED ([RouteId] ASC),
    CONSTRAINT [CK_CarrierMeta_Currency] CHECK (len([Currency])=(3)),
    CONSTRAINT [FK_CarrierMeta_Country] FOREIGN KEY ([Country]) REFERENCES [mno].[Country] ([CountryISO2alpha]),
    CONSTRAINT [FK_CarrierMeta_Currency] FOREIGN KEY ([Currency]) REFERENCES [mno].[Currency] ([Currency]),
    CONSTRAINT [FK_CarrierMeta_DimCompanyEntity] FOREIGN KEY ([CompanyEntity]) REFERENCES [ms].[DimCompanyEntity] ([CompanyEntity])
);


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = '5c503e21-22c6-81fa-620b-f369b8ec38d1', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'SupportEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Contact Info', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'SupportEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '684a0db2-d514-49d8-8c0c-df84a7b083eb', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'SupportEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'General', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'SupportEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = '5c503e21-22c6-81fa-620b-f369b8ec38d1', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'SupportCCEmails';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Contact Info', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'SupportCCEmails';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '684a0db2-d514-49d8-8c0c-df84a7b083eb', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'SupportCCEmails';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'General', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'SupportCCEmails';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = '5c503e21-22c6-81fa-620b-f369b8ec38d1', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'SupportPhone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Contact Info', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'SupportPhone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'SupportPhone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'SupportPhone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c64aba7b-3a3e-95b6-535d-3bc535da5a59', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'PortalPassword';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Credentials', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'PortalPassword';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'PortalPassword';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'PortalPassword';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'57845286-7598-22F5-9659-15B24AEB125E', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Name', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'5C503E21-22C6-81FA-620B-F369B8EC38D1', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Contact Info', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'989ADC05-3F3F-0588-A635-F475B994915B', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential - GDPR', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'5C503E21-22C6-81FA-620B-F369B8EC38D1', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerSkype';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Contact Info', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerSkype';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerSkype';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerSkype';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'5C503E21-22C6-81FA-620B-F369B8EC38D1', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerPhone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Contact Info', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerPhone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'989ADC05-3F3F-0588-A635-F475B994915B', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerPhone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential - GDPR', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CarrierMeta', @level2type = N'COLUMN', @level2name = N'AccountManagerPhone';

