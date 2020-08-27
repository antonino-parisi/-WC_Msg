CREATE TABLE [dbo].[AccountCredit] (
    [AccountId]   VARCHAR (50)    NOT NULL,
    [CreditEuro]  DECIMAL (14, 5) NOT NULL,
    [ValidCredit] BIT             CONSTRAINT [DF_AccountCredit_ValidCredit] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountCredit] PRIMARY KEY CLUSTERED ([AccountId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'C44193E1-0E58-4B2A-9001-F7D6E7BC1373', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountCredit', @level2type = N'COLUMN', @level2name = N'CreditEuro';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Financial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountCredit', @level2type = N'COLUMN', @level2name = N'CreditEuro';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountCredit', @level2type = N'COLUMN', @level2name = N'CreditEuro';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountCredit', @level2type = N'COLUMN', @level2name = N'CreditEuro';

