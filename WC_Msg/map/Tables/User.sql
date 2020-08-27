CREATE TABLE [map].[User] (
    [UserId]                 SMALLINT         IDENTITY (1, 1) NOT NULL,
    [Email]                  VARCHAR (255)    NOT NULL,
    [PasswordHash]           VARBINARY (1024) NOT NULL,
    [FirstName]              NVARCHAR (255)   NOT NULL,
    [LastName]               NVARCHAR (255)   NOT NULL,
    [TimeZoneId]             SMALLINT         NULL,
    [UserStatusId]           TINYINT          CONSTRAINT [DF_User_StatusId] DEFAULT ((1)) NOT NULL,
    [CreatedAt]              DATETIME         CONSTRAINT [DF_User_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    [UpdatedAt]              DATETIME         CONSTRAINT [DF_User_UpdatedAt] DEFAULT (getutcdate()) NOT NULL,
    [DeletedAt]              DATETIME         NULL,
    [LastLoginAt]            DATETIME         NULL,
    [PasswordResetToken]     VARCHAR (100)    NULL,
    [PasswordResetExpiresAt] DATETIME         NULL,
    CONSTRAINT [PK_map_User] PRIMARY KEY CLUSTERED ([UserId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_map_User_Email]
    ON [map].[User]([Email] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_map_User_PasswordResetToken]
    ON [map].[User]([PasswordResetToken] ASC) WHERE ([PasswordResetToken] IS NOT NULL);


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'5C503E21-22C6-81FA-620B-F369B8EC38D1', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Contact Info', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'989ADC05-3F3F-0588-A635-F475B994915B', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential - GDPR', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'C64ABA7B-3A3E-95B6-535D-3BC535DA5A59', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordHash';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Credentials', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordHash';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordHash';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordHash';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'57845286-7598-22F5-9659-15B24AEB125E', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Name', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'989ADC05-3F3F-0588-A635-F475B994915B', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential - GDPR', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'57845286-7598-22F5-9659-15B24AEB125E', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Name', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'989ADC05-3F3F-0588-A635-F475B994915B', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential - GDPR', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'C64ABA7B-3A3E-95B6-535D-3BC535DA5A59', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetToken';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Credentials', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetToken';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetToken';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetToken';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c64aba7b-3a3e-95b6-535d-3bc535da5a59', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetExpiresAt';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Credentials', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetExpiresAt';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetExpiresAt';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'map', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetExpiresAt';

