CREATE TABLE [ms].[UrlShortenBlacklist] (
    [token] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_msUrlShortenBlacklist] PRIMARY KEY CLUSTERED ([token] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-27
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER  [ms].[UrlShortenBlacklist_DataChanged]
   ON [ms].[UrlShortenBlacklist]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.UrlShortenBlacklist'
END
