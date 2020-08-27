CREATE TABLE [cp].[BillingTransaction] (
    [TrxId]            INT              IDENTITY (1, 1) NOT NULL,
    [CreatedAt]        DATETIME2 (2)    CONSTRAINT [DF_BillingTransaction_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]        DATETIME2 (2)    CONSTRAINT [DF_BillingTransaction_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Type]             VARCHAR (10)     CONSTRAINT [DF_BillingTransaction_Type] DEFAULT ('CARD') NOT NULL,
    [TrxIntStatus]     VARCHAR (7)      CONSTRAINT [DF_BillingTransaction_TrxIntStatus] DEFAULT ('UNDEF') NOT NULL,
    [TrxExtStatus]     VARCHAR (7)      CONSTRAINT [DF_BillingTransaction_PaymentApprovalStatusId] DEFAULT ('UNDEF') NOT NULL,
    [InvoiceNumber]    VARCHAR (20)     NOT NULL,
    [Currency]         CHAR (3)         NOT NULL,
    [Amount]           DECIMAL (18, 6)  NOT NULL,
    [AmountEUR]        DECIMAL (18, 6)  NULL,
    [AmountWithoutFee] DECIMAL (18, 6)  NULL,
    [AccountUid]       UNIQUEIDENTIFIER NOT NULL,
    [UserId]           UNIQUEIDENTIFIER NULL,
    [PaymentProvider]  VARCHAR (20)     NOT NULL,
    [PaymentRef]       VARCHAR (50)     NULL,
    [PaymentError]     VARCHAR (50)     NULL,
    [Description]      NVARCHAR (500)   NULL,
    [InvoiceDate]      DATE             NULL,
    [PaymentDate]      DATE             NULL,
    [MapUserId]        SMALLINT         NULL,
    CONSTRAINT [PK_BillingTransaction] PRIMARY KEY CLUSTERED ([TrxId] ASC),
    CONSTRAINT [CK_BillingTransaction_TrxExtStatus] CHECK ([TrxExtStatus]='EXPIRED' OR [TrxExtStatus]='FAILED' OR [TrxExtStatus]='SUCCESS' OR [TrxExtStatus]='UNDEF'),
    CONSTRAINT [CK_BillingTransaction_TrxIntStatus] CHECK ([TrxIntStatus]='REJECT' OR [TrxIntStatus]='EXPIRED' OR [TrxIntStatus]='FAILED' OR [TrxIntStatus]='SUCCESS' OR [TrxIntStatus]='REVIEW' OR [TrxIntStatus]='UNDEF')
);


GO
CREATE NONCLUSTERED INDEX [IX_BillingTransaction_AccountUid]
    ON [cp].[BillingTransaction]([AccountUid] ASC)
    INCLUDE([TrxId]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Internal status. Allowed values: UNDEF, REVIEW, SUCCESS, FAILED, REJECT, EXRIRED', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'TrxIntStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'External status. Allowed values: UNDEF, SUCCESS, FAILED, EXRIRED', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'TrxExtStatus';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'InvoiceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Financial', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'InvoiceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'InvoiceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'InvoiceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'C44193E1-0E58-4B2A-9001-F7D6E7BC1373', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'Currency';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Financial', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'Currency';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'Currency';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'Currency';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'C44193E1-0E58-4B2A-9001-F7D6E7BC1373', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Financial', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'AmountEUR';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Financial', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'AmountEUR';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'AmountEUR';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'AmountEUR';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'C44193E1-0E58-4B2A-9001-F7D6E7BC1373', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'AmountWithoutFee';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Financial', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'AmountWithoutFee';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'AmountWithoutFee';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'AmountWithoutFee';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Reference Id of transaction (from provider)', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'PaymentRef';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'PaymentRef';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Financial', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'PaymentRef';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'PaymentRef';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'PaymentRef';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'PaymentError';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Financial', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'PaymentError';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'PaymentError';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'PaymentError';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'InvoiceDate';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Financial', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'InvoiceDate';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'InvoiceDate';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'InvoiceDate';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'PaymentDate';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Financial', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'PaymentDate';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'PaymentDate';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'BillingTransaction', @level2type = N'COLUMN', @level2name = N'PaymentDate';

