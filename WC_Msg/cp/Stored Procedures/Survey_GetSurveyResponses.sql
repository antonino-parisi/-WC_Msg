
-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2018-01-20
-- Updated By:  Nathanael Hinay
-- Date Updated: 2018-06-19
-- Changes: Sort sl CreatedTime instead of sl UMID
-- Description:	Get survey responses
-- =============================================
-- exec [cp].[Survey_GetSurveyResponses] @SurveyUid = 92, @OutputTotals = 1, @SubmittedAtFrom = '2018-01-10', @SubmittedAtTo = '2018-11-18', @MSISDN = 639462370155
-- exec [cp].[Survey_GetSurveyResponses] @SurveyUid = 119, @OutputTotals = 1, @SubmittedAtFrom = '2018-10-10', @SubmittedAtTo = '2018-10-18', @Offset = 390100
CREATE PROCEDURE [cp].[Survey_GetSurveyResponses]
	@SurveyUid int,
    @MSISDN bigint = NULL,	-- optional
	@Offset int = 0,
	@Limit int = 200,
	@OutputTotals bit = 0,
	@SubmittedAtFrom DATETIME = NULL,
	@SubmittedAtTo DATETIME = NULL
AS
BEGIN

	IF @Limit > 50000 SET @Limit = 50000

	IF @SubmittedAtFrom IS NOT NULL
		SET @SubmittedAtFrom = CAST(@SubmittedAtFrom AS DATE)

	IF @SubmittedAtTo IS NOT NULL
	BEGIN
		SET @SubmittedAtTo = CAST(@SubmittedAtTo AS DATE)
		SET @SubmittedAtTo = DATEADD(DAY, 1, @SubmittedAtTo)
	END

	/* version 1
	SELECT sl.UMID, sl.MSISDN, sl.CreatedTime AS SubmittedAt, ss.ShortenStatusName AS DeliveryStatus,
		u.FirstAccessedAt AS FirstClickedAt,
		DATEADD(SECOND, -sr.FillTime, sr.FinishedAt) AS SurveyStartedAt, sr.FinishedAt AS SurveyFinishedAt, 
		ISNULL(sr.ResponseJson, srv.ResponseJsonForNoAnswer) AS ResponseJson,  
		sr.FillTime
	FROM sms.SurveyBatch sb
		INNER JOIN ms.Survey srv ON sb.SurveyUid = srv.SurveyUid
		INNER JOIN dbo.Account acc ON srv.SubAccountUid = acc.SubAccountUid
		INNER JOIN sms.SmsLog sl WITH (NOLOCK, INDEX(IX_SmsLog_SubAccount_CreatedTime)) ON
			-- need SubAccountId condition to use index
			sl.SubAccountId = acc.SubAccountId AND
			sl.CreatedTime BETWEEN DATEADD(MINUTE, -2, sb.CreatedAt) AND DATEADD(MINUTE, 60, sb.CreatedAt) AND
			sl.BatchId = sb.BatchId
		INNER JOIN sms.DimSmsStatus ss ON sl.StatusId = ss.StatusId
		LEFT JOIN sms.UrlShorten u (NOLOCK) on sl.UMID = u.UMID
		LEFT JOIN sms.SurveyResponse sr (NOLOCK) ON sl.UMID = sr.UMID
	WHERE sb.SurveyUid = @SurveyUid AND 
		(@SubmittedAtFrom IS NULL OR (@SubmittedAtFrom IS NOT NULL AND sb.CreatedAt >= @SubmittedAtFrom)) AND
		(@SubmittedAtTo IS NULL OR (@SubmittedAtTo IS NOT NULL AND sb.CreatedAt <= @SubmittedAtTo)) AND 
		(@MSISDN IS NULL OR (@MSISDN IS NOT NULL AND sl.MSISDN = @MSISDN))
	ORDER BY sl.CreatedTime DESC
	OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY
	*/

	/* version 2 */
	DECLARE @SubAccountId VARCHAR(50)
	DECLARE @SubAccountUid INT

	DECLARE @SurveyBatch TABLE (
		Num int PRIMARY KEY,
		BatchId UNIQUEIDENTIFIER,
		CreatedAt DATETIME2(2),
		ComulativeOffset int
	)

	-- read SubAccountId
	SELECT @SubAccountId = sa.SubAccountId, @SubAccountUid = srv.SubAccountUid
	FROM ms.Survey srv
		INNER JOIN dbo.Account sa ON srv.SubAccountUid = sa.SubAccountUid
	WHERE srv.SurveyUid = @SurveyUid

	-- get list of SurveyBatches 
	INSERT INTO @SurveyBatch (Num, BatchId, CreatedAt, ComulativeOffset)
	SELECT 
		ROW_NUMBER() OVER (ORDER BY sb.CreatedAt DESC) AS Num, 
		sb.BatchId, 
		sb.CreatedAt, 
		SUM(sb.AcceptedCount) OVER (ORDER BY sb.CreatedAt DESC ROWS UNBOUNDED PRECEDING ) - sb.AcceptedCount AS ComulativeOffset
	FROM sms.SurveyBatch sb
	WHERE sb.SurveyUid = @SurveyUid AND 
		(@SubmittedAtFrom IS NULL OR (@SubmittedAtFrom IS NOT NULL AND sb.CreatedAt >= @SubmittedAtFrom)) AND
		(@SubmittedAtTo IS NULL OR (@SubmittedAtTo IS NOT NULL AND sb.CreatedAt <= @SubmittedAtTo))
	ORDER BY sb.CreatedAt DESC

	-- initiate variables for later rotation through logs
	DECLARE @Num int
	DECLARE @MaxNum int
	DECLARE @Counter int = 0
	DECLARE @CounterInit int = 0
	DECLARE @BatchId uniqueidentifier, @CreatedAt datetime2(2)
	DECLARE @Output TABLE (
		UMID UNIQUEIDENTIFIER,
		MSISDN bigint,
		SubmittedAt datetime2(0),
		DeliveryStatus varchar(20),
		FirstClickedAt datetime2(0),
		SurveyStartedAt datetime2(0),
		SurveyFinishedAt datetime2(0),
		ResponseJson nvarchar(3000),
		FillTime int
	)

	-- shift closer to requested offset
	SELECT TOP 1 
		@Num = Num, 
		@Counter = ComulativeOffset, 
		@CounterInit = ComulativeOffset
	FROM @SurveyBatch WHERE ComulativeOffset <= @Offset ORDER BY Num DESC
	
	SELECT @MaxNum = MAX(Num) FROM @SurveyBatch

	--print @Counter

	-- iteration for each SurveyBatch to get linked smslog records
	WHILE @MaxNum > 0 AND @Counter < @Offset + @Limit AND @Num <= @MaxNum
	BEGIN
	
		SELECT @BatchId = BatchId, @CreatedAt = CreatedAt
		FROM @SurveyBatch WHERE Num = @Num

		--print @Num
		--print @BatchId
		--print @SubaccountId
		--print @SurveyUid
		--print @CreatedAt
		--print @MSISDN

		INSERT INTO @Output (UMID, MSISDN, SubmittedAt, DeliveryStatus, FirstClickedAt, SurveyStartedAt, SurveyFinishedAt, ResponseJson, FillTime)
		SELECT TOP (@Offset + @Limit - @Counter)
			sl.UMID, 
			sl.MSISDN, 
			sl.CreatedTime AS SubmittedAt, 
			ss.ShortenStatusName AS DeliveryStatus,
			u.FirstAccessedAt AS FirstClickedAt,
			DATEADD(SECOND, -sr.FillTime, sr.FinishedAt) AS SurveyStartedAt, 
			sr.FinishedAt AS SurveyFinishedAt, 
			ISNULL(sr.ResponseJson, srv.ResponseJsonForNoAnswer) AS ResponseJson,  
			sr.FillTime
		FROM sms.SmsLog sl WITH (NOLOCK/*, INDEX(IX_SmsLog_SubAccount_CreatedTime)*/)
			INNER JOIN sms.DimSmsStatus ss ON sl.StatusId = ss.StatusId
			LEFT JOIN sms.UrlShorten u (NOLOCK) on sl.UMID = u.UMID AND u.OriginalUrl LIKE '%smstoweb.net%' /* Hardcoded BaseURL for path http://smstoweb.net */
			LEFT JOIN sms.SurveyResponse sr (NOLOCK) ON sl.UMID = sr.UMID
			CROSS JOIN ms.Survey srv
		WHERE sl.SubAccountId = @SubAccountId 
			AND sl.CreatedTime BETWEEN DATEADD(MINUTE, -2, @CreatedAt) AND DATEADD(MINUTE, 40, @CreatedAt)
			AND sl.BatchId = @BatchId
			AND srv.SurveyUid = @SurveyUid
			AND (@MSISDN IS NULL OR (@MSISDN IS NOT NULL AND sl.MSISDN = @MSISDN))
		ORDER BY sl.CreatedTime DESC

		SET @Counter += @@ROWCOUNT
		SET @Num += 1

		--print @Counter
	END

	-- final response
	SELECT *
	FROM @Output
	ORDER BY SubmittedAt DESC
	OFFSET (@Offset - @CounterInit) ROWS FETCH NEXT (@Limit) ROWS ONLY

	-- get totals value
	IF @OutputTotals = 1
	BEGIN
		IF @MSISDN IS NULL
			SELECT ISNULL(SUM(AcceptedCount), 0) AS Total
			FROM sms.SurveyBatch sb
			WHERE sb.SurveyUid = @SurveyUid AND 
				(@SubmittedAtFrom IS NULL OR (@SubmittedAtFrom IS NOT NULL AND sb.CreatedAt >= @SubmittedAtFrom)) AND
				(@SubmittedAtTo IS NULL OR (@SubmittedAtTo IS NOT NULL AND sb.CreatedAt <= @SubmittedAtTo))
		ELSE
			-- just return estimated total = current page + 1
			SELECT IIF(@Counter < @Offset + @Limit, @Counter, @Offset + 2 * @Limit) AS Total

	END
END
