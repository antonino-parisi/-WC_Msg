-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-07-25
-- =============================================
-- SELECT TOP 100 * FROM [sms].[vwStatUrlShorten]
CREATE VIEW [sms].[vwStatUrlShorten]
AS
	SELECT sl.StatEntryId
	  ,CAST(TimeFrom AS date) AS Date
	  ,DATEPART(YEAR, TimeFrom) AS Year
	  ,DATEPART(MONTH, TimeFrom) AS Month
	  ,DATEPART(DAY, TimeFrom) AS Day
      ,DATEPART(HOUR, TimeFrom) AS Hour
      ,sl.TimeFrom
      ,sl.SubAccountUid, a.SubAccountId
      ,a.AccountId
	  ,ISNULL(meta.CustomerType, 'L') AS CustomerType
	  ,sl.BaseUrlId
	  ,ub.BaseUrl
      ,sl.MsgTotal
	  ,sl.MsgDelivered
	  ,sl.UrlCreated
	  ,sl.UrlClicked
  FROM sms.StatUrlShorten sl
	LEFT JOIN dbo.Account a ON sl.SubAccountUid = a.SubAccountUid
	LEFT JOIN ms.AccountMeta meta ON a.AccountId = meta.AccountId
	LEFT JOIN sms.UrlShortenBaseUrl ub ON sl.BaseUrlId = ub.BaseUrlId
