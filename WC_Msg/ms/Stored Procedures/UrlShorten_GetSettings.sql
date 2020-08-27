
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-04-20
-- Description:	UrlShorten - get settings for app
-- =============================================
CREATE PROCEDURE [ms].[UrlShorten_GetSettings]
AS
BEGIN	
	SELECT ds.SubAccountUid, a.SubAccountId, ds.DomainId, d.DomainName, ds.IncludeUmid
	FROM ms.UrlShortenDomainSubAccount ds
		INNER JOIN ms.UrlShortenDomain d ON ds.DomainId = d.DomainId
		INNER JOIN dbo.Account a ON ds.SubAccountUid = a.SubAccountUid
	WHERE ds.IsActive = 1
END
