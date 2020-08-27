CREATE TABLE [ms].[QueueConfig] (
    [ConnectionName]          VARCHAR (20) CONSTRAINT [DF_QueueConfig_ConnectionName] DEFAULT ('default') NOT NULL,
    [QueueName]               VARCHAR (60) NOT NULL,
    [ClusterGroupId_Consumer] VARCHAR (20) CONSTRAINT [DF_QueueConfig_ClusterGroupId] DEFAULT ('ANY') NOT NULL,
    [ClusterGroupId_Publish]  VARCHAR (20) CONSTRAINT [DF_QueueConfig_ClusterGroupId_Publish] DEFAULT ('ANY') NOT NULL,
    [QueueRole]               VARCHAR (5)  NOT NULL,
    [Priority]                TINYINT      CONSTRAINT [DF_QueueConfig_Priority] DEFAULT ((30)) NOT NULL,
    [BufferSize]              SMALLINT     CONSTRAINT [DF_QueueConfig_BufferSize] DEFAULT ((50)) NOT NULL,
    [ThreadCount]             SMALLINT     CONSTRAINT [DF_QueueConfig_ThreadCount] DEFAULT ((5)) NOT NULL,
    [SubAccountUid]           INT          NULL,
    [ThrottlingRate]          REAL         CONSTRAINT [DF_QueueConfig_ThrottlingRate] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_QueueConfig] PRIMARY KEY CLUSTERED ([ConnectionName] ASC, [QueueName] ASC, [ClusterGroupId_Consumer] ASC, [ClusterGroupId_Publish] ASC),
    CONSTRAINT [CK_QueueConfig_Priority] CHECK ([Priority]>=(0) AND [Priority]<=(100)),
    CONSTRAINT [CK_QueueConfig_QueueRole] CHECK ([QueueRole]='MO' OR [QueueRole]='DROUT' OR [QueueRole]='MT' OR [QueueRole]='MTADD' OR [QueueRole]='MTUPD' OR [QueueRole]='MOADD' OR [QueueRole]='MOUPD' OR [QueueRole]='FDBK'),
    CONSTRAINT [CK_SubAccountQueue_BufferSize] CHECK ([BufferSize]>=(0) AND [BufferSize]<=(1000))
);


GO
CREATE NONCLUSTERED INDEX [IX_QueueConfig_Role_Publish]
    ON [ms].[QueueConfig]([QueueRole] ASC, [ClusterGroupId_Publish] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_QueueConfig_Role_Consume]
    ON [ms].[QueueConfig]([QueueRole] ASC, [ClusterGroupId_Consumer] ASC);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-21
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[QueueConfig_DataChanged]
   ON  [ms].[QueueConfig]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
	BEGIN
		EXEC ms.DbDependency_DataChanged @Key = 'ms.AuthSmpp'
		EXEC ms.DbDependency_DataChanged @Key = 'ms.AuthApi'
		EXEC ms.DbDependency_DataChanged @Key = 'ms.QueueConfig'
	END
END
