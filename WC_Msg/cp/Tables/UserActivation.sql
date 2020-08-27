CREATE TABLE [cp].[UserActivation] (
    [Email]     NVARCHAR (255) NOT NULL,
    [Token]     VARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [Activated] BIT            CONSTRAINT [DF_UserActivation_Activated] DEFAULT ((0)) NOT NULL,
    [AccountId] VARCHAR (50)   NULL,
    [CreatedAt] DATETIME2 (2)  CONSTRAINT [DF_UserActivation_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt] DATETIME2 (2)  CONSTRAINT [DF_UserActivation_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [ExpiresAt] DATETIME2 (2)  NOT NULL,
    [Attempt]   INT            CONSTRAINT [DF_UserActivation_Attempt] DEFAULT ((1)) NOT NULL,
    [ClientIP]  VARCHAR (50)   NULL,
    CONSTRAINT [PK_UserActivation] PRIMARY KEY CLUSTERED ([Email] ASC),
    CONSTRAINT [CK_UserActivation_AccountId] CHECK (NOT [AccountId] like '% %')
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserActivation_Token]
    ON [cp].[UserActivation]([Token] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'5C503E21-22C6-81FA-620B-F369B8EC38D1', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'UserActivation', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Contact Info', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'UserActivation', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'989ADC05-3F3F-0588-A635-F475B994915B', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'UserActivation', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential - GDPR', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'UserActivation', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'd22fa6e9-5ee4-3bde-4c2b-a409604c4646', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'UserActivation', @level2type = N'COLUMN', @level2name = N'ExpiresAt';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Credit Card', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'UserActivation', @level2type = N'COLUMN', @level2name = N'ExpiresAt';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'UserActivation', @level2type = N'COLUMN', @level2name = N'ExpiresAt';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'UserActivation', @level2type = N'COLUMN', @level2name = N'ExpiresAt';

