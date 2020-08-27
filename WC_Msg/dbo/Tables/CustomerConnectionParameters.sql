CREATE TABLE [dbo].[CustomerConnectionParameters] (
    [CustomerConnectionId] NVARCHAR (50)   NOT NULL,
    [ParameterName]        NVARCHAR (50)   NOT NULL,
    [ParameterValue]       NVARCHAR (1024) NOT NULL,
    CONSTRAINT [PK_CustomerConnectionParameters] PRIMARY KEY CLUSTERED ([CustomerConnectionId] ASC, [ParameterName] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-01-11
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [dbo].[CustomerConnectionParameters_DataChanged]
   ON  [dbo].[CustomerConnectionParameters]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'dbo.CustomerConnectionParameters'
END
