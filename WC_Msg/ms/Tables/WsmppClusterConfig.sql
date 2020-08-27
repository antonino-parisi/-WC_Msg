CREATE TABLE [ms].[WsmppClusterConfig] (
    [FilterId]       INT          IDENTITY (1, 1) NOT NULL,
    [Priority]       TINYINT      CONSTRAINT [DF_WsmppClusterConfig_Priority] DEFAULT ((0)) NOT NULL,
    [SubAccountId]   VARCHAR (50) NULL,
    [UseMainCluster] BIT          CONSTRAINT [DF_WsmppClusterConfig_UseMainCluster] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_WsmppClusterConfig] PRIMARY KEY CLUSTERED ([FilterId] ASC),
    CONSTRAINT [IX_WsmppClusterConfig] UNIQUE NONCLUSTERED ([SubAccountId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-11-21
-- Description:	Table update tracker trigger
-- =============================================
CREATE TRIGGER [ms].[WsmppClusterConfig_DataChanged] 
   ON [ms].[WsmppClusterConfig]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		exec ms.DbDependency_DataChanged @Key = 'ms.WsmppClusterConfig'
END
