-- =============================================
-- Author:		Rebecca
-- Create date: 2020-03-19
-- =============================================
-- EXEC cp.[SmsLog_GetManyByFilter_v3] @AccountUid = '0FC250D4-6182-E711-8143-02D85F55FCE7', @UserId = '55272080-6282-E711-8143-02D85F55FCE7', @Limit = 50, @MSISDN = NULL, @TimeframeStart = '2018-07-01 15:00', @TimeframeEnd = '2018-07-02 15:00', @ShortenStatusId = 4, @OutputTotals = 1
-- EXEC cp.[SmsLog_GetManyByFilter_v3] @AccountUid = '29C250D4-6182-E711-8143-02D85F55FCE7', @UserId = '55272080-6282-E711-8143-02D85F55FCE7', @Limit = 50, @MSISDN = NULL, @TimeframeStart = '2018-07-05 00:00', @TimeframeEnd = '2018-07-06 15:00', @CampaignId = 25505, @OutputTotals = 0
-- EXEC cp.[SmsLog_GetManyByFilter_v3] @AccountUid = '55272080-6282-E711-8143-02D85F55FCE7', @UserId = '55272080-6282-E711-8143-02D85F55FCE7', @Limit = 50, @MSISDN = 6587093459, @TimeframeStart = '2017-08-10 15:00', @TimeframeEnd = '2017-08-17 15:00', @OutputTotals = 1

CREATE PROCEDURE [cp].[SmsLog_GetManyByFilter_v2]
	@TimeframeStart datetime,		-- mandatory
	@TimeframeEnd datetime,			-- mandatory
	@AccountUid uniqueidentifier,	-- mandatory
    @UserId uniqueidentifier,		-- mandatory
	@SubAccountId varchar(50) = NULL,
	@SubAccountUid int = NULL,
	@MSISDN bigint = NULL,
	@SenderId varchar(20) = NULL,
	@UMID uniqueidentifier = NULL,
	@Country char(2) = NULL,
	@OperatorId int = NULL,
	@ShortenStatusId tinyint = NULL,
	@SmsTypeId tinyint = NULL,
	@CampaignId int = NULL,
	@Offset int = 0,
	@Limit int = 100,
	@OutputTotals bit = 0
WITH EXECUTE AS OWNER
/*
	WARNING: 
	SP executes with OWNER permission and uses dynamic SQL query execution based on user's inputs.
	Be careful and smart in code change to avoid SQL injection. 
	Customer-created values must be passed as @parameters.
*/
AS
BEGIN
	DECLARE @OutputCount int = 0 ;
	DECLARE @sql AS NVARCHAR(MAX), @StatSmsLog_sql AS NVARCHAR(MAX) ;
	DECLARE @where AS NVARCHAR(3000) ;
	DECLARE @i int = 1, @TimeFrom smalldatetime, @TimeTo smalldatetime, @cnt int ;

print getutcdate() ;
	IF @Limit < 1 SET @Limit = 1 ELSE IF @LIMIT > 100 SET @Limit = 100 ;
print '@Limit = ' + CAST(@Limit AS VARCHAR(50)) ;

	-- to fix the moment of permanently adding records
	IF @TimeframeEnd > SYSUTCDATETIME() SET @TimeframeEnd = SYSUTCDATETIME()

	-- to be removed subsequently
	IF @SubAccountId IS NOT NULL AND @SubAccountUid IS NULL
		SELECT @SubAccountUid = SubAccountUid
		FROM ms.SubAccount
		WHERE SubAccountId = @SubAccountId ;

	CREATE TABLE #SubAccounts (SubAccountUid int, SubAccountId varchar(50)) ;

	INSERT INTO #SubAccounts
	SELECT SubAccountUid, SubAccountId
	FROM cp.fnSubAccount_GetByUser (@AccountUid, @UserId, @SubAccountUid, 1, NULL, NULL, NULL) ;
/*
	-- Check LimitSubAccounts
	DECLARE @LimitSubAccounts bit = 0;
	IF @UserId IS NOT NULL
		SELECT @LimitSubAccounts = cu.LimitSubAccounts 
		FROM cp.[User] cu
		WHERE cu.AccountUid = @AccountUid
			AND cu.UserId = @UserId ;

print '@LimitSubAccounts = ' + CAST(@LimitSubAccounts AS VARCHAR(10)) ;

	INSERT INTO #SubAccounts
	SELECT mss.SubAccountUid, mss.SubAccountId
	FROM ms.SubAccount mss WITH (NOLOCK)
		LEFT JOIN cp.UserSubAccount usa WITH (NOLOCK) ON usa.SubAccountUid = mss.SubAccountUid
	WHERE mss.AccountUid = @AccountUid
		AND (@SubAccountId IS NULL OR mss.SubAccountId = @SubAccountId)
		AND (@LimitSubAccounts = 0 OR usa.UserId = @UserId) ;
*/

	-- prepare SQL query
	IF @UMID IS NOT NULL
		SET @where = 'WHERE sl.UMID = @UMID ' ;
	ELSE
		SET @where = 'WHERE (CreatedTime BETWEEN @TimeframeStart AND @TimeframeEnd) '
			+' AND SubAccountId IN (SELECT SubAccountId FROM #SubAccounts) '
			+ CASE WHEN @MSISDN IS NOT NULL THEN ' AND MSISDN = @MSISDN' ELSE '' END
			+ CASE WHEN @SenderId IS NOT NULL THEN ' AND Source = @SenderId' ELSE '' END
			+ CASE WHEN @Country IS NOT NULL AND @MSISDN IS NULL THEN ' AND Country = @Country' ELSE '' END
			+ CASE WHEN @OperatorId IS NOT NULL THEN ' AND OperatorId = @OperatorId' ELSE '' END
			+ CASE WHEN @ShortenStatusId IS NOT NULL THEN ' AND StatusId IN (SELECT StatusId FROM sms.DimSmsStatus dss WHERE dss.ShortenStatusId = @ShortenStatusId)' ELSE '' END
			+ CASE WHEN @SmsTypeId IS NOT NULL THEN ' AND SmsTypeId = @SmsTypeId ' ELSE '' END

	IF @ShortenStatusId IS NOT NULL
		BEGIN
			DECLARE @Status_Str varchar(1000) = '' ;

			SELECT @Status_Str = @Status_Str + IIF(@Status_Str='', '', ',') + CAST(StatusId AS varchar(10))
			FROM sms.DimSmsStatus dss WHERE dss.ShortenStatusId = @ShortenStatusId ;

			SELECT @where = @where + ' AND StatusId IN (' + @Status_Str + ')' ;
		END ;

	IF @CampaignId IS NOT NULL
		BEGIN
			DECLARE @BatchId_Str varchar(2000) = '' ;

			SELECT @BatchId_Str =  @BatchId_Str + IIF(@BatchId_Str='', '', ',') + '''' + CAST(cb.BatchId AS VARCHAR(40)) + ''''
			FROM cp.CmCampaign c INNER JOIN cp.CmCampaignBatchIds cb ON c.CampaignId = cb.CampaignId
			WHERE c.CampaignId = @CampaignId ;

			SELECT @where = @where + ' AND BatchId IN (' + @BatchId_Str + ')' ;
		END ;
print @where ;
		SET @sql = 'SELECT UMID, CAST(CreatedTime as smalldatetime) CreatedTime, SubAccountId, SmsTypeId, Country,
							OperatorId, MSISDN, SourceOriginal, Source, StatusId, ConnTypeId, EncodingTypeId,
							Body, SegmentsReceived, (SegmentsReceived * PriceContractPerSms) AS [Price],
							PriceContractCurrency, ClientMessageId, IIF(BatchId IS NULL, NULL, ClientBatchId) AS ClientBatchId
						FROM sms.SmsLog WITH (NOLOCK) '
						+ @where ;
					
print @sql
--RETURN ;

	CREATE TABLE #StatSmsLog
		(rowno int IDENTITY(1,1),
		TimeFrom smalldatetime
		) ;

	SET @StatSmsLog_sql = 'SELECT DISTINCT TimeFrom '
						+'FROM sms.StatSmsLog WITH (NOLOCK) '
						+'WHERE TimeFrom BETWEEN @TimeframeStart AND @TimeframeEnd '
						+'AND SubAccountUid IN (SELECT SubAccountUid FROM #SubAccounts) '
						+ CASE WHEN @Country IS NOT NULL AND @MSISDN IS NULL THEN 'AND Country = @Country ' ELSE '' END
						+ CASE WHEN @OperatorId IS NOT NULL THEN 'AND OperatorId = @OperatorId ' ELSE '' END
						+ CASE WHEN @SmsTypeId IS NOT NULL THEN 'AND SmsTypeId = @SmsTypeId ' ELSE '' END
						+'ORDER BY 1 DESC' ;
print @StatSmsLog_sql

	INSERT INTO #StatSmsLog
	EXEC sp_executesql @StatSmsLog_sql,
		  N'	@TimeframeStart datetime,
				@TimeframeEnd datetime,
				@Country char(2),
				@OperatorId int,
				@SmsTypeId tinyint',
			@TimeframeStart = @TimeframeStart,
			@TimeframeEnd = @TimeframeEnd,
			@Country = @Country,
			@OperatorId = @OperatorId,
			@SmsTypeId = @SmsTypeId ;

	SET @cnt = @@ROWCOUNT ;
print 'No of statsmslog records = ' + cast(@cnt as varchar(10)) ;
--RETURN ;

	CREATE TABLE #tmp
		(UMID uniqueidentifier,
		CreatedTime datetime,
		SubAccountId varchar(50),
		SmsTypeId tinyint,
		Country varchar(50),
		OperatorId int,
		MSISDN bigint,
		SourceOriginal varchar(50),
		[Source] varchar(50),
		StatusId tinyint,
		ConnTypeId tinyint,
		EncodingTypeId tinyint,
		[Body] nvarchar(1600),
		SegmentsReceived tinyint,
		[Price] decimal(12,6),
		PriceContractCurrency char(3),
		ClientMessageId varchar(50),
		ClientBatchId varchar(50)
		) ;

	WHILE @i <= @cnt
		BEGIN
			PRINT @i ;

			SELECT @TimeFrom = TimeFrom FROM #StatSmsLog WHERE rowno = @i ;
			SET @TimeTo = DATEADD(minute, 15, @TimeFrom) ;

			INSERT INTO #tmp
			EXEC sp_executesql @sql,
				  N'	@TimeframeStart datetime,
						@TimeframeEnd datetime,
						@AccountUid uniqueidentifier,
						@UserId uniqueidentifier,
						@MSISDN bigint,
						@SenderId varchar(20),
						@UMID uniqueidentifier,
						@Country char(2),
						@OperatorId int,
						@ShortenStatusId tinyint,
						@SmsTypeId tinyint,
						@CampaignId int',
					@TimeframeStart = @TimeFrom,
					@TimeframeEnd = @TimeTo,
					@AccountUid = @AccountUid,
					@UserId = @UserId,
					@UMID = @UMID,
					@MSISDN = @MSISDN,
					@SenderId = @SenderId,
					@Country = @Country,
					@OperatorId = @OperatorId,
					@ShortenStatusId = @ShortenStatusId,
					@SmsTypeId = @SmsTypeId,
					@CampaignId = @CampaignId ;

			SET @OutputCount = @OutputCount + @@ROWCOUNT ;

			IF @OutputCount >= @Offset + @Limit
				BREAK ;

			SET @i = @i + 1 ;
		END ;

	SELECT sl.UMID, sl.CreatedTime, sl.SubAccountId, sl.SmsTypeId, sl.Country,
			sl.OperatorId, sl.MSISDN, sl.SourceOriginal, sl.Source, sl.[Body],
			sl.SegmentsReceived, sl.[Price], sl.PriceContractCurrency, sl.ClientMessageId,
			sl.ClientBatchId, o.OperatorName, st.ShortenStatusId AS StatusId, st.Final,
			st.ShortenStatusName AS [Status], dct.ConnectionType, det.EncodingType
	FROM
		(SELECT * FROM #tmp
		ORDER BY CreatedTime DESC
		OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY
		) sl
		LEFT JOIN mno.Operator o ON sl.OperatorId = o.OperatorId
		LEFT JOIN sms.DimSmsStatus st ON sl.StatusId = st.StatusId
		LEFT JOIN sms.DimConnType dct ON sl.ConnTypeId = dct.ConnTypeId
		LEFT JOIN sms.DimEncodingType det ON sl.EncodingTypeId = det.EncodingTypeId ;

	SET @OutputCount = @@ROWCOUNT ;

	-- returns totals
	SELECT @OutputCount TotalCount ;

END
