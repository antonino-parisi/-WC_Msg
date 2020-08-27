CREATE TABLE [ms].[UrlShortenDomainSubAccount] (
    [SubAccountUid]        INT      NOT NULL,
    [DomainId]             SMALLINT NOT NULL,
    [ExpiryDurationInDays] SMALLINT CONSTRAINT [DF_msUrlShortenDomainSubAccount_ExpiryDurationInDays] DEFAULT ((60)) NOT NULL,
    [IncludeUmid]          BIT      CONSTRAINT [DF_UrlShortenDomainSubAccount_IncludeUmid] DEFAULT ((0)) NOT NULL,
    [IsActive]             BIT      CONSTRAINT [DF_UrlShortenDomainSubAccount_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_msUrlShortenDomainSubAccount] PRIMARY KEY CLUSTERED ([SubAccountUid] ASC),
    CONSTRAINT [FK_UrlShortenDomainSubAccount_SubAccount] FOREIGN KEY ([SubAccountUid]) REFERENCES [ms].[SubAccount] ([SubAccountUid]),
    CONSTRAINT [FK_UrlShortenDomainSubAccount_UrlShortenDomain] FOREIGN KEY ([DomainId]) REFERENCES [ms].[UrlShortenDomain] ([DomainId]),
    CONSTRAINT [FK_UrlShortenDomainSubAccount_UrlShortenDomainSubAccount] FOREIGN KEY ([DomainId]) REFERENCES [ms].[UrlShortenDomain] ([DomainId])
);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-21
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[UrlShortenDomainSubAccount_DataChanged]
   ON  [ms].[UrlShortenDomainSubAccount]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.UrlShortenDomain'
END
