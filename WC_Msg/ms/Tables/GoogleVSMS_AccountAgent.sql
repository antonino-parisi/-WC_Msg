CREATE TABLE [ms].[GoogleVSMS_AccountAgent] (
    [ConfigId]      INT              IDENTITY (1, 1) NOT NULL,
    [AccountUid]    UNIQUEIDENTIFIER NOT NULL,
    [SubAccountUid] INT              NULL,
    [AgentId]       INT              NOT NULL,
    CONSTRAINT [PK_GoogleVSMS_AccountAgent] PRIMARY KEY CLUSTERED ([ConfigId] ASC),
    CONSTRAINT [FK_GoogleVSMS_AccountAgent_Account] FOREIGN KEY ([AccountUid]) REFERENCES [cp].[Account] ([AccountUid]),
    CONSTRAINT [FK_GoogleVSMS_AccountAgent_GoogleVSMS_Agent] FOREIGN KEY ([AgentId]) REFERENCES [ms].[GoogleVSMS_Agent] ([AgentId]),
    CONSTRAINT [FK_GoogleVSMS_AccountAgent_SubAccount] FOREIGN KEY ([SubAccountUid]) REFERENCES [ms].[SubAccount] ([SubAccountUid]),
    CONSTRAINT [UX_GoogleVSMS_AccountAgent] UNIQUE NONCLUSTERED ([AccountUid] ASC, [SubAccountUid] ASC, [AgentId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-06-29
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[GoogleVSMS_AccountAgent_DataChanged]
   ON  [ms].[GoogleVSMS_AccountAgent]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.GoogleVSMS_AccountAgent'
END
