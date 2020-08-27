CREATE TABLE [dbo].[CustomerConnections] (
    [CustomerConnectionId] NVARCHAR (50)  NOT NULL,
    [Description]          NVARCHAR (MAX) NULL,
    [ConnectionType]       VARCHAR (50)   NOT NULL,
    [AssemblyName]         NVARCHAR (MAX) NOT NULL,
    [ClassName]            NVARCHAR (MAX) NOT NULL,
    [Connection_MO_Queue]  NVARCHAR (MAX) NOT NULL,
    [Connection_DR_Queue]  NVARCHAR (MAX) NOT NULL,
    [MOThreadCount]        INT            NOT NULL,
    [DRThreadCount]        INT            NOT NULL,
    [TrashOnFail]          BIT            NOT NULL,
    [LogFolder]            NVARCHAR (MAX) NULL,
    [LogLevel]             INT            NOT NULL,
    [Active]               BIT            NOT NULL,
    CONSTRAINT [PK_CustomerConnections] PRIMARY KEY CLUSTERED ([CustomerConnectionId] ASC)
);


GO


-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-01-11
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [dbo].[CustomerConnections_DataChanged]
   ON  [dbo].[CustomerConnections]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
	BEGIN
		EXEC ms.DbDependency_DataChanged @Key = 'dbo.CustomerConnections'
		EXEC ms.DbDependency_DataChanged @Key = 'dbo.CustomerConnectionParameters'
	END
END
