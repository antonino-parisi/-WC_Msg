CREATE TABLE [dbo].[Account] (
    [AccountId]                 VARCHAR (50)   NOT NULL,
    [SubAccountId]              VARCHAR (50)   NOT NULL,
    [Description]               VARCHAR (1000) NOT NULL,
    [TrafficRecording]          BIT            NOT NULL,
    [Active]                    BIT            NOT NULL,
    [Default]                   BIT            NULL,
    [Date]                      DATETIME       NULL,
    [IsTrafficReport]           BIT            NULL,
    [StandardRouteId]           VARCHAR (50)   NULL,
    [PricingFormula]            VARCHAR (50)   NULL,
    [IsPriceChangeAlert]        BIT            CONSTRAINT [DF_Account_IsPriceChangeAlert] DEFAULT ((0)) NULL,
    [BlockedRoutes]             VARCHAR (2000) NULL,
    [IsBalanceOrOverdraftAlert] BIT            NULL,
    [SubAccountUid]             INT            IDENTITY (1, 1) NOT NULL,
    [UpdatedAt]                 DATETIME2 (2)  CONSTRAINT [DF_Account_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Deleted]                   BIT            CONSTRAINT [DF_Account_Deleted] DEFAULT ((0)) NOT NULL,
    [QueueType]                 CHAR (1)       CONSTRAINT [DF_Account_QueueType] DEFAULT ('M') NOT NULL,
    [QueueKey]                  VARCHAR (55)   NULL,
    [PriceNotifiedAt]           DATETIME2 (2)  NULL,
    CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED ([SubAccountId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Account_AccountId]
    ON [dbo].[Account]([AccountId] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_Account_SubAccountUid]
    ON [dbo].[Account]([SubAccountUid] ASC)
    INCLUDE([AccountId], [SubAccountId]);


GO
CREATE NONCLUSTERED INDEX [IX_Account_Active_Deleted]
    ON [dbo].[Account]([Active] ASC, [Deleted] ASC)
    INCLUDE([SubAccountId], [SubAccountUid]);


GO

CREATE TRIGGER [dbo].[Account_InsteadOfDELETE]
	ON [dbo].[Account] INSTEAD OF DELETE
AS
BEGIN

	--TODO: Trigger supports delete of 1 record at once only. It's not designed to support bulk delete yet

	-- if there is stats for SubAccount, we don't hard delete record, only mark as deleted.
	IF EXISTS (SELECT 1 FROM Deleted WHERE Deleted = 0)
	BEGIN
		UPDATE a SET Deleted = 1, UpdatedAt = SYSUTCDATETIME()
		FROM dbo.Account a INNER JOIN Deleted d ON a.SubAccountUid = d.SubAccountUid

		UPDATE sa SET Active = 0, UpdatedAt = SYSUTCDATETIME()
		FROM ms.SubAccount sa INNER JOIN Deleted d ON sa.SubAccountUid = d.SubAccountUid

	END
	ELSE IF NOT EXISTS (
		SELECT TOP (1) 1 
		FROM sms.StatSmsLogDaily s 
			INNER JOIN Deleted d ON s.SubAccountUid = d.SubAccountUid
		WHERE D.Deleted = 1
		)
	BEGIN
		DELETE FROM a FROM dbo.Account a INNER JOIN Deleted d ON a.SubAccountUid = d.SubAccountUid WHERE a.Deleted = 1
		DELETE FROM sa FROM ms.SubAccount sa INNER JOIN Deleted d ON sa.SubAccountUid = d.SubAccountUid WHERE sa.Active = 0
	END
END

GO
DISABLE TRIGGER [dbo].[Account_InsteadOfDELETE]
    ON [dbo].[Account];


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [dbo].[Account_DataChanged]
   ON  [dbo].[Account]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN

	IF NOT UPDATE(UpdatedAt)
		UPDATE a
		SET UpdatedAt = SYSUTCDATETIME()
		FROM dbo.Account a
			INNER JOIN inserted AS i ON a.SubAccountId = i.SubAccountId

	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.SubAccount'
END

GO
CREATE TRIGGER updateServer_Account ON
 dbo.Account
 FOR INSERT,UPDATE,DELETE
 AS
 EXECUTE  sp_configurationChanged;
