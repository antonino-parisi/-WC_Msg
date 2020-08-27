CREATE TABLE [ipm].[QueueConfig] (
    [ConnectionName]          VARCHAR (20) CONSTRAINT [DF_QueueConfig_ConnectionName] DEFAULT ('default') NOT NULL,
    [QueueName]               VARCHAR (60) NOT NULL,
    [ClusterGroupId_Consumer] VARCHAR (20) CONSTRAINT [DF_QueueConfig_ClusterGroupId] DEFAULT ('ANY') NOT NULL,
    [ClusterGroupId_Publish]  VARCHAR (20) CONSTRAINT [DF_QueueConfig_ClusterGroupId_Publish] DEFAULT ('ANY') NOT NULL,
    [QueueRole]               VARCHAR (6)  NOT NULL,
    [ChannelTypeId]           TINYINT      NULL,
    [SubAccountUid]           INT          NULL,
    [Priority]                TINYINT      CONSTRAINT [DF_QueueConfig_Priority] DEFAULT ((30)) NOT NULL,
    [BufferSize]              SMALLINT     CONSTRAINT [DF_QueueConfig_BufferSize] DEFAULT ((50)) NOT NULL,
    [ThreadCount]             SMALLINT     CONSTRAINT [DF_QueueConfig_ThreadCount] DEFAULT ((5)) NOT NULL,
    [ThrottlingRate]          REAL         CONSTRAINT [DF_QueueConfig_ThrottlingRate] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_QueueConfig] PRIMARY KEY CLUSTERED ([ConnectionName] ASC, [QueueName] ASC, [ClusterGroupId_Consumer] ASC, [ClusterGroupId_Publish] ASC),
    CONSTRAINT [CK_QueueConfig_BufferSize] CHECK ([BufferSize]>=(0) AND [BufferSize]<=(1000)),
    CONSTRAINT [CK_QueueConfig_Priority] CHECK ([Priority]>=(0) AND [Priority]<=(100)),
    CONSTRAINT [CK_QueueConfig_QueueRole] CHECK ([QueueRole]='FBWEB' OR [QueueRole]='MSGOUT' OR [QueueRole]='MSGIN' OR [QueueRole]='EVOUT' OR [QueueRole]='EVIN' OR [QueueRole]='IPMIN' OR [QueueRole]='IPMOUT' OR [QueueRole]='FLBMT' OR [QueueRole]='FLBIPM'),
    CONSTRAINT [FK_QueueConfig_ChannelType] FOREIGN KEY ([ChannelTypeId]) REFERENCES [ipm].[ChannelType] ([ChannelTypeId])
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-05-17
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ipm].[QueueConfig_DataChanged]
   ON  ipm.QueueConfig
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.QueueConfig'
END
