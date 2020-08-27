CREATE TABLE [dbo].[CPCallingIP] (
    [AccountId]    NVARCHAR (50)  NOT NULL,
    [SubAccountId] NVARCHAR (50)  NOT NULL,
    [IPAddress]    NVARCHAR (MAX) NULL,
    [DateTime]     DATETIME       NULL,
    CONSTRAINT [PK_CPCallingIP] PRIMARY KEY CLUSTERED ([AccountId] ASC, [SubAccountId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'B40AD280-0F6A-6CA8-11BA-2F1A08651FCF', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CPCallingIP', @level2type = N'COLUMN', @level2name = N'IPAddress';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Networking', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CPCallingIP', @level2type = N'COLUMN', @level2name = N'IPAddress';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CPCallingIP', @level2type = N'COLUMN', @level2name = N'IPAddress';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CPCallingIP', @level2type = N'COLUMN', @level2name = N'IPAddress';

