-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-06-20
-- =============================================
-- EXEC cp.UrlShorten_GetReport @DateFrom='2018-06-01', @DateTo='2018-06-20', @SubAccountId='PRAKSMOL-4yY8D_hq'
CREATE PROCEDURE [cp].[UrlShorten_GetReport_Deprecated]
	@DateFrom date,
	@DateTo date,
	@SubAccountId varchar(50)
AS
BEGIN	
	SELECT 
		CONVERT(date, CreatedTime) AS [Date]
		,b.BaseUrl AS BaseUrl
		,COUNT(urlid) AS Total
		,SUM(IIF(l.StatusId = 40, 1, 0)) AS Delivered
		,SUM(IIF(Hits > 0, 1, 0)) AS ClicksCount
		,SUM(IIF(Hits > 0, 1, 0)) * 100 / COUNT(urlid) AS Clicks
	FROM sms.UrlShorten s
		INNER JOIN sms.UrlShortenBaseUrl b ON b.BaseUrlId = s.BaseUrlId
		INNER JOIN sms.SmsLog l ON l.UMID = s.UMID
	WHERE 
		CreatedTime >= @DateFrom AND 
		CreatedAt <= @DateTo AND 
		SubAccountId = @SubAccountId AND
		s.UMID IS NOT NULL
	GROUP BY CONVERT(date, CreatedTime), b.BaseUrl, l.SubAccountId	
	ORDER BY [Date]
END
