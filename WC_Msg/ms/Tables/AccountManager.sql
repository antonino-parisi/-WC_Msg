CREATE TABLE [ms].[AccountManager] (
    [ManagerId]     SMALLINT       NOT NULL,
    [Name]          NVARCHAR (100) NOT NULL,
    [Email]         VARCHAR (50)   NOT NULL,
    [BU]            VARCHAR (10)   NOT NULL,
    [Country]       CHAR (2)       NOT NULL,
    [CreatedAt]     DATETIME2 (2)  CONSTRAINT [DF_AccountManager_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [PowerBI_Login] VARCHAR (100)  NULL,
    CONSTRAINT [PK_AccountManager] PRIMARY KEY CLUSTERED ([ManagerId] ASC),
    CONSTRAINT [FK_AccountManager_Country] FOREIGN KEY ([Country]) REFERENCES [mno].[Country] ([CountryISO2alpha]),
    CONSTRAINT [FK_AccountManager_User] FOREIGN KEY ([ManagerId]) REFERENCES [map].[User] ([UserId]),
    CONSTRAINT [UIX_AccountManager_Email] UNIQUE NONCLUSTERED ([Email] ASC),
    CONSTRAINT [UIX_AccountManager_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = '5c503e21-22c6-81fa-620b-f369b8ec38d1', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AccountManager', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Contact Info', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AccountManager', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AccountManager', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AccountManager', @level2type = N'COLUMN', @level2name = N'Email';

