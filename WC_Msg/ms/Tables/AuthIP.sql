CREATE TABLE [ms].[AuthIP] (
    [id]            INT              IDENTITY (1, 1) NOT NULL,
    [AccountUid]    UNIQUEIDENTIFIER NOT NULL,
    [SubAccountUid] INT              NULL,
    [CIDR]          VARCHAR (50)     NOT NULL,
    [Description]   NVARCHAR (250)   NULL,
    CONSTRAINT [PK_AuthIP] PRIMARY KEY NONCLUSTERED ([id] ASC),
    CONSTRAINT [UIX_AuthIP_Cluster] UNIQUE CLUSTERED ([AccountUid] ASC, [SubAccountUid] ASC, [CIDR] ASC)
);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-05-18
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[AuthIP_DataChanged]
   ON  [ms].[AuthIP]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.AuthIP'
END
