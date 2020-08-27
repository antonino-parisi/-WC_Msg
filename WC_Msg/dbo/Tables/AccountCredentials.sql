CREATE TABLE [dbo].[AccountCredentials] (
    [AccountId]           VARCHAR (50)     NOT NULL,
    [AccountUid]          UNIQUEIDENTIFIER NULL,
    [Password]            NVARCHAR (50)    NOT NULL,
    [isEncrypted]         BIT              NOT NULL,
    [Description]         NVARCHAR (100)   NULL,
    [date]                DATETIME         NULL,
    [overdraftAuthorized] DECIMAL (18, 5)  NOT NULL,
    [ValidationTag]       NVARCHAR (50)    NULL,
    [AlertValue]          DECIMAL (18, 5)  CONSTRAINT [DF_AccountCredentials_AlertValue] DEFAULT ((1)) NOT NULL,
    [OutOfCredit]         BIT              CONSTRAINT [DF_AccountCredentials_OutOfCredit] DEFAULT ((0)) NOT NULL,
    [IsVerified]          BIT              NULL,
    [Validate]            AS               (CONVERT([bit],NULL)),
    [PrivateMTQueue]      AS               ('deprecated'),
    CONSTRAINT [PK_AccountCredentials] PRIMARY KEY CLUSTERED ([AccountId] ASC)
);


GO
​
​
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [dbo].[AccountCredentials_DataChanged]
   ON  [dbo].[AccountCredentials]
   AFTER INSERT, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
	BEGIN
		EXEC ms.DbDependency_DataChanged @Key = 'ms.SubAccount'
		EXEC ms.DbDependency_DataChanged @Key = 'dbo.AccountCredentials'
	END
END
GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'C64ABA7B-3A3E-95B6-535D-3BC535DA5A59', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountCredentials', @level2type = N'COLUMN', @level2name = N'Password';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Credentials', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountCredentials', @level2type = N'COLUMN', @level2name = N'Password';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountCredentials', @level2type = N'COLUMN', @level2name = N'Password';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountCredentials', @level2type = N'COLUMN', @level2name = N'Password';

