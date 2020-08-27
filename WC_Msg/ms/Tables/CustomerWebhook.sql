CREATE TABLE [ms].[CustomerWebhook] (
    [WebHookId]               INT              IDENTITY (1, 1) NOT NULL,
    [AccountUid]              UNIQUEIDENTIFIER NOT NULL,
    [SubAccountUid]           INT              NULL,
    [Type]                    VARCHAR (5)      NOT NULL,
    [Url]                     NVARCHAR (500)   NOT NULL,
    [Version]                 TINYINT          CONSTRAINT [DF_CustomerWebhook_Version] DEFAULT ((1)) NOT NULL,
    [HttpMethod]              VARCHAR (6)      CONSTRAINT [DF_CustomerWebhook_HttpMethod] DEFAULT ('POST') NOT NULL,
    [HttpAuthorizationHeader] NVARCHAR (1024)  NULL,
    [UpdatedAt]               DATETIME2 (2)    CONSTRAINT [DF_CustomerWebhook_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Active]                  BIT              CONSTRAINT [DF_CustomerWebhook_Active] DEFAULT ((1)) NOT NULL,
    [HttpContentType]         VARCHAR (50)     COLLATE SQL_Latin1_General_CP1_CS_AS CONSTRAINT [DF_CustomerWebhook_HttpContentType] DEFAULT ('application/json') NOT NULL,
    [HttpTimeoutSec]          INT              CONSTRAINT [DF_CustomerWebhook_HttpTimeoutSec] DEFAULT ((30)) NOT NULL,
    [ConnectionType]          VARCHAR (3)      CONSTRAINT [DF_CustomerWebhook_ConnectionType] DEFAULT ('STD') NOT NULL,
    [MediaUrlExpiryDays]      TINYINT          CONSTRAINT [DF_CustomerWebhook_MediaUrlExpiryDays] DEFAULT ((1)) NOT NULL,
    [CustomerConnectionId]    VARCHAR (50)     NULL,
    [Deleted]                 BIT              CONSTRAINT [DF_CustomerWebhook_Deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CustomerWebhook] PRIMARY KEY CLUSTERED ([WebHookId] ASC),
    CONSTRAINT [CK_CustomerWebhook_ConnectionType] CHECK ([ConnectionType]='NUL' OR [ConnectionType]='KAN' OR [ConnectionType]='STD'),
    CONSTRAINT [CK_CustomerWebhook_Deleted_Active] CHECK ([Deleted]=(0) OR [Deleted]=(1) AND [Active]=(0)),
    CONSTRAINT [CK_CustomerWebhook_HttpContentType] CHECK ([HttpContentType]='application/json' OR [HttpContentType]='application/xml' OR [HttpContentType]='text/xml' OR [HttpContentType]='application/x-www-form-urlencoded'),
    CONSTRAINT [CK_CustomerWebhook_HttpMethod] CHECK ([HttpMethod]='GET' OR [HttpMethod]='POST'),
    CONSTRAINT [CK_CustomerWebhook_Type] CHECK ([Type]='MO' OR [Type]='DR' OR [Type]='MSG' OR [Type]='EV'),
    CONSTRAINT [FK_CustomerWebhook_Account] FOREIGN KEY ([AccountUid]) REFERENCES [cp].[Account] ([AccountUid]),
    CONSTRAINT [FK_CustomerWebhook_SubAccount] FOREIGN KEY ([SubAccountUid]) REFERENCES [ms].[SubAccount] ([SubAccountUid]),
    CONSTRAINT [UX_CustomerWebhook_AccountUid_SubAccountUid_Type] UNIQUE NONCLUSTERED ([AccountUid] ASC, [SubAccountUid] ASC, [Type] ASC)
);


GO

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-08-13
-- Description:	Set Active = 0 on Deleted = 1
-- =============================================
CREATE TRIGGER [ms].[CustomerWebhook_DeactivateOnDeleted]
   ON  [ms].[CustomerWebhook]
   AFTER UPDATE
AS 
BEGIN

	IF EXISTS (SELECT 1 FROM inserted)
	BEGIN
		UPDATE ms.CustomerWebhook
			SET Active = 0
		FROM inserted
		WHERE 
			ms.CustomerWebhook.WebHookId = inserted.WebHookId AND 
			ms.CustomerWebhook.Deleted = 1

		UPDATE ms.CustomerWebhook
			SET UpdatedAt = SYSUTCDATETIME()
		FROM inserted
		WHERE 
			ms.CustomerWebhook.WebHookId = inserted.WebHookId
	END
	
END

GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-08-13
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[CustomerWebhook_DataChanged]
   ON  [ms].[CustomerWebhook]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.CustomerWebhook'
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'All deleted Webhooks should be inactive', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'CustomerWebhook', @level2type = N'CONSTRAINT', @level2name = N'CK_CustomerWebhook_Deleted_Active';

