CREATE TABLE [dbo].[CustomerRouting] (
    [Id]                   INT          IDENTITY (1, 1) NOT NULL,
    [AccountId]            VARCHAR (50) NOT NULL,
    [SubAccountUid]        INT          NULL,
    [CustomerConnectionId] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_CustomerRouting] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UX_CustomerRouting] UNIQUE NONCLUSTERED ([AccountId] ASC, [SubAccountUid] ASC)
);


GO

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-29
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [dbo].[CustomerRouting_DataChanged]
   ON  [dbo].[CustomerRouting]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
	BEGIN
		EXEC ms.DbDependency_DataChanged @Key = 'dbo.CustomerRouting'
		EXEC ms.DbDependency_DataChanged @Key = 'dbo.CustomerConnections'
		EXEC ms.DbDependency_DataChanged @Key = 'dbo.CustomerConnectionParameters'
	END
END
