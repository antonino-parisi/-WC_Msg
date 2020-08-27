CREATE TABLE [dbo].[Invoices] (
    [Amount]        DECIMAL (18, 5) NOT NULL,
    [DatePublished] DATE            NOT NULL,
    [DatePaid]      DATE            NULL,
    [Status]        NVARCHAR (80)   NOT NULL,
    [AccountId]     NVARCHAR (50)   NOT NULL,
    [refCode]       NVARCHAR (50)   NULL,
    [paymentType]   NVARCHAR (50)   NULL,
    [InvoiceId]     INT             IDENTITY (10000, 1) NOT NULL,
    [bankRef]       NVARCHAR (50)   NULL,
    [TaxAmount]     DECIMAL (18, 5) NOT NULL,
    [NetAmount]     DECIMAL (18, 5) NOT NULL,
    [PaypalToken]   VARCHAR (MAX)   NULL,
    [ExtraInfo]     NVARCHAR (4000) NULL,
    [Currency]      CHAR (3)        CONSTRAINT [DF_Invoices_Currency] DEFAULT ('EUR') NOT NULL,
    CONSTRAINT [PK_Invoices] PRIMARY KEY CLUSTERED ([InvoiceId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Financial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'paymentType';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Financial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'paymentType';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'paymentType';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'paymentType';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'InvoiceId';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Financial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'InvoiceId';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'InvoiceId';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'InvoiceId';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'TaxAmount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Financial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'TaxAmount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'TaxAmount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'TaxAmount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'NetAmount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Financial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'NetAmount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'NetAmount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'NetAmount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'PaypalToken';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Financial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'PaypalToken';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'PaypalToken';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Invoices', @level2type = N'COLUMN', @level2name = N'PaypalToken';

