-- =============================================
-- Author:		legacy
-- Create date: 2014-10-11
-- Author:		Anton Shchekalov
-- Updated date: 2018-10-11 - converted from MessageStats to StatSmsLogDaily
-- =============================================
-- SAMPLE:
-- EXEC [dbo].[sp_Customer_Daily_Traffic_Report] @AccountId='Silverstreet', @SubAccountId=NULL, @StartDate = '2018-10-01', @EndDate = '2018-10-02'
CREATE PROCEDURE [dbo].[sp_Customer_Daily_Traffic_Report]
	@AccountId nvarchar(50),
	@SubAccountId nvarchar(50),
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	--SELECT [AccountId]
	--	,[SubAccountId]
	--	,[TotalMessage]
	--	,[OperatorName]         
	--	,[Price],[country]                    
	--FROM [dbo].[MessageStats] 
	--where date between @StartDate AND @EndDate
	--	AND AccountId=@AccountId 
	
	IF LEN(@SubAccountId) = 0 SET @SubAccountId = NULL

	/* Note: app is sensitive to order of columns */
	SELECT --date,
		sa.AccountId, 
		sa.SubAccountId, 
		SUM(SmsCountTotal-SmsCountRejected) AS [TotalMessage],
		ISNULL(o.OperatorName, 'unknown') AS OperatorName, 
		ROUND(SUM(Price),5) AS Price,
		ISNULL(c.CountryName, '') AS country
	FROM sms.StatSmsLogDaily s (NOLOCK)
		INNER JOIN ms.vwSubAccount sa ON sa.SubAccountUid = s.SubAccountUid
		LEFT JOIN mno.Operator o ON s.OperatorId = o.OperatorId
		LEFT JOIN mno.Country c ON s.Country = c.CountryISO2alpha
	WHERE s.SmsTypeId = 1 /* MT */
		--AND s.date between '20181001' AND '20181001'
		--AND sa.AccountId='eatigo'
		AND s.Date >= @StartDate
		AND s.Date < @EndDate
		AND sa.AccountId = @AccountId
		AND sa.SubAccountId = ISNULL(@SubAccountId, sa.SubAccountId)
	GROUP BY sa.AccountId, sa.SubAccountId, c.CountryName, o.OperatorName
	HAVING SUM(SmsCountTotal-SmsCountRejected) > 0
	ORDER BY sa.AccountId, sa.SubAccountId,c.CountryName,  o.OperatorName
END
