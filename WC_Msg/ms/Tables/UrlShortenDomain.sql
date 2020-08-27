CREATE TABLE [ms].[UrlShortenDomain] (
    [DomainId]   SMALLINT     NOT NULL,
    [DomainName] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_msUrlShortenDomain] PRIMARY KEY CLUSTERED ([DomainId] ASC)
);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-21
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[UrlShortenDomain_DataChanged]
   ON  [ms].[UrlShortenDomain]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.UrlShortenDomain'
END
