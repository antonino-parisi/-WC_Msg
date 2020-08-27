CREATE TABLE [dbo].[AccountMODRConfig] (
    [SubAccountId]    NVARCHAR (50) NOT NULL,
    [TPDA_ToMatch]    VARCHAR (50)  NOT NULL,
    [Keyword_ToMatch] NVARCHAR (50) NOT NULL
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-01-22
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [dbo].[AccountMODRConfig_DataChanged]
   ON  [dbo].[AccountMODRConfig]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'dbo.AccountMODRConfig'
END
