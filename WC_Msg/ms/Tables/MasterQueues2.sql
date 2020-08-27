CREATE TABLE [ms].[MasterQueues2] (
    [AccountId]      NVARCHAR (50) NOT NULL,
    [MessageType]    VARCHAR (5)   NOT NULL,
    [ClusterGroupId] VARCHAR (20)  NOT NULL,
    [Queuename]      VARCHAR (500) NOT NULL,
    [nbThreads]      INT           NOT NULL,
    CONSTRAINT [PK_MasterQueues2] PRIMARY KEY CLUSTERED ([AccountId] ASC, [MessageType] ASC, [ClusterGroupId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-11-21
-- Description:	Table update tracker trigger
-- =============================================
CREATE TRIGGER [ms].[MasterQueues2_DataChanged] 
   ON [ms].[MasterQueues2]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		exec ms.DbDependency_DataChanged @Key = 'ms.MasterQueues2'
END
