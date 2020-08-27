-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-05-19
-- =============================================
-- EXEC cp.[Report_SmsTraffic_GetCountries] @AccountUid = '6B6C6F99-2486-E711-8143-02D85F55FCE7', @TimeframeStart = '2020-01-01 15:00', @TimeframeEnd = '2020-01-13 15:00'
CREATE PROCEDURE [cp].[Report_SmsTraffic_GetCountries]
	@AccountUid uniqueidentifier,
	@TimeframeStart datetime,
	@TimeframeEnd datetime,	
	@SubAccountId varchar(50) = NULL
AS
BEGIN
	/*
	SELECT DISTINCT cc.Country, c.CountryName
	FROM sms.CacheSubaccountCountryLog cc
		INNER JOIN dbo.Account a ON cc.SubAccountUid = a.SubAccountUid
		INNER JOIN cp.Account ca ON ca.AccountId = a.AccountId
		LEFT JOIN mno.Country c ON cc.Country = c.CountryISO2alpha
	WHERE
		cc.CreatedAt BETWEEN @TimeframeStart AND @TimeframeEnd
		AND ca.AccountUid = @AccountUid
		AND a.SubAccountId = COALESCE(@SubAccountId, a.SubAccountId)
	ORDER BY c.CountryName ASC
	*/

	DECLARE @FromDate date = @TimeframeStart, @ToDate date ;
	DECLARE @CountryTab TABLE (Country char(2)) ;
	DECLARE @SubAccountUid int ;

	IF @SubAccountId IS NOT NULL
		SELECT @SubAccountUid = SubAccountUid FROM dbo.Account WHERE SubAccountId = @SubAccountId ;

	WHILE @FromDate <= @TimeframeEnd
		BEGIN
			SET @ToDate = IIF(@TimeframeEnd > EOMONTH(@FromDate), EOMONTH(@FromDate), @TimeframeEnd) ;
			
			INSERT INTO @CountryTab
			SELECT DISTINCT COUNTRY
			FROM sms.StatSmsLogDaily WITH (NOLOCK)
			WHERE	[Date] BETWEEN @FromDate AND @ToDate
				AND AccountUid = @AccountUid
				AND (@SubAccountUid IS NULL OR SubAccountUid = @SubAccountUid) ;

			SET @FromDate = DATEADD(dd, 1, @ToDate) ;
		END ;

	SELECT t.Country, c.CountryName
	FROM
		(SELECT DISTINCT COUNTRY FROM @CountryTab) t
			LEFT JOIN mno.Country c ON t.Country = c.CountryISO2alpha ;

END
