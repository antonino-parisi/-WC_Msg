CREATE TABLE [cp].[Account] (
    [AccountUid]         UNIQUEIDENTIFIER CONSTRAINT [DF_Account_AccountUid] DEFAULT (newsequentialid()) NOT NULL,
    [AccountId]          VARCHAR (50)     NOT NULL,
    [AccountName]        VARCHAR (40)     NOT NULL,
    [CompanyName]        NVARCHAR (255)   NULL,
    [Country]            CHAR (2)         NULL,
    [CompanyAddress]     NVARCHAR (500)   NULL,
    [InvoiceEmails]      NVARCHAR (500)   NULL,
    [AccountCurrency]    CHAR (3)         CONSTRAINT [DF_Account_AccountCurrency] DEFAULT ('EUR') NOT NULL,
    [CreatedAt]          DATETIME2 (2)    CONSTRAINT [DF_Account_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]          DATETIME2 (2)    CONSTRAINT [DF_Account_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [DeletedAt]          DATETIME2 (2)    NULL,
    [Deleted]            BIT              CONSTRAINT [DF_Account_Active] DEFAULT ((0)) NOT NULL,
    [Billing_StripeId]   VARCHAR (100)    NULL,
    [Billing_PaypalId]   VARCHAR (100)    NULL,
    [FreeCreditsOffer]   DECIMAL (12, 4)  CONSTRAINT [DF_Account_FreeCreditsOffer] DEFAULT ((0)) NOT NULL,
    [IsV2Allowed]        BIT              CONSTRAINT [DF_Account_IsV2Allowed] DEFAULT ((1)) NOT NULL,
    [SmsToSurveyEnabled] BIT              CONSTRAINT [DF_Account_SmsToSurveyEnabled] DEFAULT ((0)) NOT NULL,
    [Flag_ShowBalance]   BIT              CONSTRAINT [DF_Account_Flag_ShowBalance] DEFAULT ((1)) NOT NULL,
    [Product_SMS]        BIT              CONSTRAINT [DF_Account_Product_SMS] DEFAULT ((1)) NOT NULL,
    [Product_CA]         BIT              CONSTRAINT [DF_Account_Product_CA] DEFAULT ((0)) NOT NULL,
    [Product_VI]         BIT              CONSTRAINT [DF_Account_Product_VI] DEFAULT ((0)) NOT NULL,
    [Product_VO]         BIT              CONSTRAINT [DF_Account_Product_VO] DEFAULT ((0)) NOT NULL,
    [MapUpdatedBy]       SMALLINT         NULL,
    [MapUpdatedAt]       SMALLDATETIME    NULL,
    CONSTRAINT [PK_cp_Account] PRIMARY KEY CLUSTERED ([AccountUid] ASC),
    CONSTRAINT [UIX_cp_Account_AccountId] UNIQUE NONCLUSTERED ([AccountId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-09-30
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [cp].[Account_DataChanged]
   ON  [cp].[Account]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'cp.Account'
END

GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'5C503E21-22C6-81FA-620B-F369B8EC38D1', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccountName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Contact Info', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccountName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccountName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccountName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = '5c503e21-22c6-81fa-620b-f369b8ec38d1', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'CompanyAddress';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Contact Info', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'CompanyAddress';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '684a0db2-d514-49d8-8c0c-df84a7b083eb', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'CompanyAddress';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'General', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'CompanyAddress';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'5C503E21-22C6-81FA-620B-F369B8EC38D1', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'InvoiceEmails';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Contact Info', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'InvoiceEmails';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'InvoiceEmails';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'InvoiceEmails';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'C44193E1-0E58-4B2A-9001-F7D6E7BC1373', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccountCurrency';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Financial', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccountCurrency';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccountCurrency';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccountCurrency';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'C44193E1-0E58-4B2A-9001-F7D6E7BC1373', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'Billing_PaypalId';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Financial', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'Billing_PaypalId';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'Billing_PaypalId';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'Billing_PaypalId';

