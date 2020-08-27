CREATE TABLE [ms].[ApplicationSettings2] (
    [ParameterName]  NVARCHAR (50)  NOT NULL,
    [ClusterGroupId] VARCHAR (20)   NOT NULL,
    [ParameterValue] NVARCHAR (500) NOT NULL,
    CONSTRAINT [PK_ApplicationSettings2] PRIMARY KEY CLUSTERED ([ParameterName] ASC, [ClusterGroupId] ASC),
    CONSTRAINT [IX_ApplicationSettings2] UNIQUE NONCLUSTERED ([ParameterName] ASC, [ClusterGroupId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-29
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[ApplicationSettings2_DataChanged]
   ON  [ms].[ApplicationSettings2]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.ApplicationSettings2'
END
