CREATE TABLE [cp].[AccountEmail] (
    [id]              INT              IDENTITY (1, 1) NOT NULL,
    [AccountUid]      UNIQUEIDENTIFIER NOT NULL,
    [Email]           NVARCHAR (100)   NOT NULL,
    [Type]            VARCHAR (3)      CONSTRAINT [DF_AccountEmail_Type] DEFAULT ('TO') NOT NULL,
    [FlagPricing]     BIT              CONSTRAINT [DF_AccountEmail_FlagPricing] DEFAULT ((0)) NOT NULL,
    [FlagInvoice]     BIT              CONSTRAINT [DF_AccountEmail_FlagInvoice] DEFAULT ((0)) NOT NULL,
    [FlagProductNews] BIT              CONSTRAINT [DF_AccountEmail_FlagProductNews] DEFAULT ((0)) NOT NULL,
    [FlagTech]        BIT              CONSTRAINT [DF_AccountEmail_FlagTech] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountEmail] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [CK_AccountEmail_Type] CHECK ([Type]='BCC' OR [Type]='CC' OR [Type]='TO'),
    CONSTRAINT [UIX_AccountEmail_AccountUid_Email] UNIQUE NONCLUSTERED ([AccountUid] ASC, [Email] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'5C503E21-22C6-81FA-620B-F369B8EC38D1', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'AccountEmail', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Contact Info', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'AccountEmail', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'AccountEmail', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'AccountEmail', @level2type = N'COLUMN', @level2name = N'Email';

