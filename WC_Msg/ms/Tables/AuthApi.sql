CREATE TABLE [ms].[AuthApi] (
    [ApiKey]          VARCHAR (100)  NOT NULL,
    [AccountId]       VARCHAR (50)   NOT NULL,
    [SubAccountId]    VARCHAR (50)   NULL,
    [Name]            NVARCHAR (100) NOT NULL,
    [Active]          BIT            NOT NULL,
    [DefaultSenderId] VARCHAR (20)   NULL,
    [CreatedAt]       DATETIME       CONSTRAINT [DF_AuthApi_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    [LastUsedAt]      DATETIME       NULL,
    [DeletedAt]       SMALLDATETIME  NULL,
    CONSTRAINT [PK_AuthApi] PRIMARY KEY CLUSTERED ([ApiKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_AuthApi_AccountId]
    ON [ms].[AuthApi]([AccountId] ASC);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-05-18
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[AuthApi_DataChanged]
   ON  [ms].[AuthApi]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.AuthApi'
END

GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AuthApi', @level2type = N'COLUMN', @level2name = N'AccountId';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Financial', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AuthApi', @level2type = N'COLUMN', @level2name = N'AccountId';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AuthApi', @level2type = N'COLUMN', @level2name = N'AccountId';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AuthApi', @level2type = N'COLUMN', @level2name = N'AccountId';

