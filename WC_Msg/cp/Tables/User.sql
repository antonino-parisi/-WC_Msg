CREATE TABLE [cp].[User] (
    [UserId]                       UNIQUEIDENTIFIER NOT NULL,
    [Login]                        NVARCHAR (255)   NOT NULL,
    [PasswordHash]                 VARBINARY (1024) NOT NULL,
    [AccountUid]                   UNIQUEIDENTIFIER NOT NULL,
    [UserStatus]                   CHAR (1)         CONSTRAINT [DF_User_UserStatus] DEFAULT ('A') NOT NULL,
    [AccessLevel]                  CHAR (1)         CONSTRAINT [DF_User_Role] DEFAULT ('U') NOT NULL,
    [Firstname]                    NVARCHAR (255)   NULL,
    [Lastname]                     NVARCHAR (255)   NULL,
    [Phone]                        VARCHAR (20)     NULL,
    [MSISDN]                       BIGINT           NULL,
    [PhoneVerified]                BIT              CONSTRAINT [DF_User_PhoneVerified] DEFAULT ((0)) NOT NULL,
    [TimeZoneId]                   SMALLINT         NULL,
    [UserStatusId]                 TINYINT          CONSTRAINT [DF_User_StatusId] DEFAULT ((1)) NOT NULL,
    [SecretKey]                    VARCHAR (100)    NOT NULL,
    [CreatedAt]                    DATETIME2 (2)    CONSTRAINT [DF_User_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]                    DATETIME2 (2)    CONSTRAINT [DF_User_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [DeletedAt]                    DATETIME2 (2)    NULL,
    [LastLoginAt]                  DATETIME2 (2)    NULL,
    [PasswordResetToken]           VARCHAR (100)    NULL,
    [PasswordResetExpiresAt]       DATETIME2 (2)    NULL,
    [PasswordResetForce]           BIT              CONSTRAINT [DF_User_PasswordResetRequest] DEFAULT ((0)) NOT NULL,
    [InvitedByUser]                UNIQUEIDENTIFIER NULL,
    [NeedMigrationFromV1]          BIT              CONSTRAINT [DF_User_NeedMigrationFromV1] DEFAULT ((0)) NOT NULL,
    [LimitSubAccounts]             BIT              CONSTRAINT [DF_User_LimitSubAccounts] DEFAULT ((0)) NOT NULL,
    [LimitRoles]                   BIT              CONSTRAINT [DF_User_LimitRoles] DEFAULT ((0)) NOT NULL,
    [OptIn_Marketing]              BIT              CONSTRAINT [DF_User_OptIn_Marketing] DEFAULT ((0)) NULL,
    [SiteVersion_MigrationEnabled] BIT              CONSTRAINT [DF_User_SiteVersion_MigrationEnabled] DEFAULT ((0)) NOT NULL,
    [SiteVersion_Current]          VARCHAR (5)      NULL,
    [InvitedByMapUser]             SMALLINT         NULL,
    [PasswordHashAlgorithm]        VARCHAR (20)     NULL,
    [PasswordExpiresAt]            SMALLDATETIME    NULL,
    CONSTRAINT [PK_cp_User] PRIMARY KEY CLUSTERED ([UserId] ASC),
    CONSTRAINT [FK_cp_User_Account] FOREIGN KEY ([AccountUid]) REFERENCES [cp].[Account] ([AccountUid]),
    CONSTRAINT [FK_User_InvitedByMapUser] FOREIGN KEY ([InvitedByMapUser]) REFERENCES [map].[User] ([UserId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_cp_User_Login]
    ON [cp].[User]([Login] ASC) WHERE ([DeletedAt] IS NULL);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_cp_User_PasswordResetToken]
    ON [cp].[User]([PasswordResetToken] ASC) WHERE ([PasswordResetToken] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_User_AccountUid]
    ON [cp].[User]([AccountUid] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'C64ABA7B-3A3E-95B6-535D-3BC535DA5A59', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordHash';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Credentials', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordHash';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordHash';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordHash';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'57845286-7598-22F5-9659-15B24AEB125E', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Firstname';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Name', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Firstname';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'989ADC05-3F3F-0588-A635-F475B994915B', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Firstname';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential - GDPR', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Firstname';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'57845286-7598-22F5-9659-15B24AEB125E', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Lastname';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Name', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Lastname';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'989ADC05-3F3F-0588-A635-F475B994915B', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Lastname';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential - GDPR', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Lastname';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'5C503E21-22C6-81FA-620B-F369B8EC38D1', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Contact Info', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'989ADC05-3F3F-0588-A635-F475B994915B', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential - GDPR', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c64aba7b-3a3e-95b6-535d-3bc535da5a59', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetToken';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Credentials', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetToken';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetToken';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetToken';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c64aba7b-3a3e-95b6-535d-3bc535da5a59', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetExpiresAt';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Credentials', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetExpiresAt';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetExpiresAt';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'PasswordResetExpiresAt';

