CREATE TABLE [ms].[GoogleVSMS_Agent] (
    [AgentId]                      INT              IDENTITY (1, 1) NOT NULL,
    [AgentName]                    VARCHAR (50)     NOT NULL,
    [GoogleBrandId]                VARCHAR (50)     NOT NULL,
    [GoogleAgentId]                VARCHAR (50)     NOT NULL,
    [GoogleAgentPrivateKey]        VARBINARY (6000) NOT NULL,
    [ServiceCredentialClientEmail] VARCHAR (100)    NOT NULL,
    [ServiceCredentialPrivateKey]  VARBINARY (6000) NOT NULL,
    [Active]                       BIT              CONSTRAINT [DF_GoogleVSMS_Agent_Active] DEFAULT ((1)) NOT NULL,
    [UpdatedAt]                    DATETIME2 (2)    CONSTRAINT [DF_GoogleVSMS_Agent_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_GoogleVSMS_Agent] PRIMARY KEY CLUSTERED ([AgentId] ASC),
    CONSTRAINT [UX_GoogleVSMS_AgentName] UNIQUE NONCLUSTERED ([AgentName] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-06-29
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[GoogleVSMS_Agents_DataChanged]
   ON  ms.GoogleVSMS_Agent
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	IF NOT UPDATE(UpdatedAt)
		UPDATE a
		SET UpdatedAt = SYSUTCDATETIME()
		FROM ms.GoogleVSMS_Agent a
			INNER JOIN inserted AS i ON a.AgentId = i.AgentId

	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.GoogleVSMS_Agent'
END
