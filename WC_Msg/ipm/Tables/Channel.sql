CREATE TABLE [ipm].[Channel] (
    [ChannelId]              UNIQUEIDENTIFIER CONSTRAINT [DF_Channel_ChannelId] DEFAULT (newsequentialid()) NOT NULL,
    [AccountUid]             UNIQUEIDENTIFIER NOT NULL,
    [ChannelType]            CHAR (2)         NOT NULL,
    [StatusId]               CHAR (1)         NOT NULL,
    [Name]                   NVARCHAR (36)    NOT NULL,
    [Comment]                NVARCHAR (1024)  NULL,
    [Deleted]                BIT              CONSTRAINT [DF_Channel_Deleted] DEFAULT ((0)) NOT NULL,
    [CreatedAt]              DATETIME2 (2)    CONSTRAINT [DF_Channel_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]              DATETIME2 (2)    CONSTRAINT [DF_Channel_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [AccountName]            NVARCHAR (50)    NULL,
    [PhoneNumber]            BIGINT           NULL,
    [Address]                NVARCHAR (1024)  NULL,
    [Email]                  NVARCHAR (250)   NULL,
    [Description]            NVARCHAR (1024)  NULL,
    [IconUrl]                VARCHAR (1024)   NULL,
    [AccountUrl]             VARCHAR (1024)   NULL,
    [ServiceUrl]             VARCHAR (1024)   NULL,
    [ServiceId]              VARCHAR (200)    NULL,
    [ServiceSecret]          VARBINARY (6000) NULL,
    [ServiceTag]             VARCHAR (1024)   NULL,
    [WebhookValidationToken] VARCHAR (36)     NULL,
    [OneWayMessaging]        BIT              CONSTRAINT [DF_Channel_OneWayMessaging] DEFAULT ((0)) NOT NULL,
    [WebhookSubAccountUid]   INT              NULL,
    CONSTRAINT [PK_Channel] PRIMARY KEY CLUSTERED ([ChannelId] ASC),
    CONSTRAINT [FK_Channel_Account] FOREIGN KEY ([AccountUid]) REFERENCES [cp].[Account] ([AccountUid]),
    CONSTRAINT [FK_Channel_ChannelStatus] FOREIGN KEY ([StatusId]) REFERENCES [ipm].[ChannelStatus] ([StatusId]),
    CONSTRAINT [FK_Channel_ChannelType] FOREIGN KEY ([ChannelType]) REFERENCES [ipm].[ChannelType] ([ChannelType]),
    CONSTRAINT [FK_Channel_SubAccount] FOREIGN KEY ([WebhookSubAccountUid]) REFERENCES [ms].[SubAccount] ([SubAccountUid])
);


GO

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-01-16
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ipm].[Channel_DataChanged]
   ON  ipm.Channel
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN

	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
	BEGIN
		IF NOT UPDATE(UpdatedAt)
			UPDATE ch
				SET UpdatedAt = SYSUTCDATETIME()
			FROM ipm.Channel ch 
			INNER JOIN inserted AS i ON ch.ChannelId = i.ChannelId

		EXEC ms.DbDependency_DataChanged @Key = 'ipm.Channel'

		-- temporal update tokens for compatibility with old MS
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.FacebookConfig'
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.LineConfig'
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.RcsConfig'
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.ViberConfig'
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.WeChatConfig'
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.WhatsAppConfig'
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.ZaloConfig'

	END
END

GO

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-02-05
-- Description:	Set StatusId = 'S' (Stopped) on Deleted = 1
-- =============================================
CREATE TRIGGER [ipm].[Channel_DeactivateOnDeleted]
   ON  ipm.Channel
   AFTER UPDATE
AS 
BEGIN
  
  	IF EXISTS (SELECT 1 FROM inserted)
	UPDATE ipm.Channel
		SET StatusId = 'S'
	FROM inserted
	WHERE 
		ipm.Channel.ChannelId = inserted.ChannelId AND 
		inserted.Deleted = 1
END

GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = '5c503e21-22c6-81fa-620b-f369b8ec38d1', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'AccountName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Contact Info', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'AccountName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '1866ca45-1973-4c28-9d12-04d407f147ad', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'AccountName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Public', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'AccountName';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = '5c503e21-22c6-81fa-620b-f369b8ec38d1', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'PhoneNumber';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Contact Info', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'PhoneNumber';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '1866ca45-1973-4c28-9d12-04d407f147ad', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'PhoneNumber';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Public', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'PhoneNumber';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = '5c503e21-22c6-81fa-620b-f369b8ec38d1', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Contact Info', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '1866ca45-1973-4c28-9d12-04d407f147ad', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Public', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = '5c503e21-22c6-81fa-620b-f369b8ec38d1', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Contact Info', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '1866ca45-1973-4c28-9d12-04d407f147ad', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Public', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = '5c503e21-22c6-81fa-620b-f369b8ec38d1', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'AccountUrl';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Contact Info', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'AccountUrl';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '1866ca45-1973-4c28-9d12-04d407f147ad', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'AccountUrl';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Public', @level0type = N'SCHEMA', @level0name = N'ipm', @level1type = N'TABLE', @level1name = N'Channel', @level2type = N'COLUMN', @level2name = N'AccountUrl';

