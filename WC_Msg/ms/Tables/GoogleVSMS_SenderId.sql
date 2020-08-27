CREATE TABLE [ms].[GoogleVSMS_SenderId] (
    [ConfigId] INT          IDENTITY (1, 1) NOT NULL,
    [AgentId]  INT          NOT NULL,
    [SenderId] VARCHAR (16) NOT NULL,
    [Country]  CHAR (2)     NOT NULL,
    CONSTRAINT [PK_GoogleVSMS_SenderId] PRIMARY KEY CLUSTERED ([ConfigId] ASC),
    CONSTRAINT [FK_GoogleVSMS_SenderId_GoogleVSMS_Agent] FOREIGN KEY ([AgentId]) REFERENCES [ms].[GoogleVSMS_Agent] ([AgentId]),
    CONSTRAINT [UX_GoogleVSMS_SenderId] UNIQUE NONCLUSTERED ([SenderId] ASC, [Country] ASC)
);


GO

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-06-29
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[GoogleVSMS_SenderId_DataChanged]
   ON  [ms].[GoogleVSMS_SenderId]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.GoogleVSMS_SenderId'
END
