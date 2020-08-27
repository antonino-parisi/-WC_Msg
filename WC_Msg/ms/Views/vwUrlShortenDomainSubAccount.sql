
-- SELECT * FROM ms.vwUrlShortenDomainSubAccount
CREATE VIEW [ms].[vwUrlShortenDomainSubAccount]
AS
	SELECT u.*, a.SubAccountId, a.AccountId, d.DomainName
	FROM ms.UrlShortenDomainSubAccount u
		LEFT JOIN dbo.Account a ON a.SubAccountUid = u.SubAccountUid
		LEFT JOIN ms.UrlShortenDomain d ON u.DomainId = d.DomainId
