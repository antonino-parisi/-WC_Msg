-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-06-20
-- =============================================
-- EXEC cp.UrlShorten_ExportLog @Date='2018-06-05', @SubAccountId='wavecell_test3'
CREATE PROCEDURE [cp].[UrlShorten_ExportLog_Deprecated]
	@Date date,
	@SubAccountId varchar(50)
AS
BEGIN
	SELECT 
		 l.CreatedTime AS SentAt
		,s.FirstAccessedAt AS ClickedAt
		,l.MSISDN AS Destination
		,l.Body AS [Message]
		,s.OriginalUrl AS [Url]
		,IIF(s.Hits > 0, 1, 0) AS Clicked
	FROM sms.UrlShorten s
		INNER JOIN sms.SmsLog l (NOLOCK) ON l.UMID = s.UMID
	WHERE 
		l.SubAccountId = @SubAccountId AND
		CONVERT(date, l.CreatedTime) = @Date AND
		s.UMID IS NOT NULL
	--ORDER BY l.CreatedTime
END
