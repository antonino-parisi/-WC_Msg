-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-05-19
-- Updated By:  Nathanael Hinay
-- Date Updated: 2018-07-03
-- Changes: Factor in UserManagement LimitSubAccounts 
-- =============================================
-- EXEC cp.[SmsLog_GetManyByFilter] @AccountUid = '0FC250D4-6182-E711-8143-02D85F55FCE7', @Limit = 50, @MSISDN = NULL, @TimeframeStart = '2018-07-01 15:00', @TimeframeEnd = '2018-07-02 15:00', @ShortenStatusId = 4, @OutputTotals = 1
-- EXEC cp.[SmsLog_GetManyByFilter] @AccountUid = '29C250D4-6182-E711-8143-02D85F55FCE7', @Limit = 50, @MSISDN = NULL, @TimeframeStart = '2018-07-05 00:00', @TimeframeEnd = '2018-07-06 15:00', @CampaignId = 25505, @OutputTotals = 0
-- EXEC cp.[SmsLog_GetManyByFilter] @AccountUid = '55272080-6282-E711-8143-02D85F55FCE7', @Limit = 50, @MSISDN = 6587093459, @TimeframeStart = '2017-08-10 15:00', @TimeframeEnd = '2017-08-17 15:00', @OutputTotals = 1
CREATE PROCEDURE [cp].[SmsLog_GetManyByFilter]
	@TimeframeStart datetime,
	@TimeframeEnd datetime,
	@AccountUid uniqueidentifier,
    @UserId uniqueidentifier = NULL,
	@SubAccountId varchar(50) = NULL,
	@MSISDN bigint = NULL,
	@SenderId varchar(20) = NULL,
	@UMID uniqueidentifier = NULL,
	@Country char(2) = NULL,
	@OperatorId int = NULL,
	@ShortenStatusId tinyint = NULL,
	@CampaignId int = NULL,
	@Offset int = 0,
	@Limit int = 100,
	@OutputTotals bit = 0
WITH EXECUTE AS OWNER	-- 'ref_smslog_read'
AS
BEGIN

	--IF @AccountUid <> '2318BDEB-C250-E711-8141-06B9B96CA965'
	--	SET @AccountUid = '619250fe-e2e5-e611-813f-06b9b96ca965' /* for testing stage 'wavecell_monitoring' */

	--SELECT * FROM cp.Account WHERE AccountId = 'garena'

	--DECLARE @MSISDN bigint = NULL --6282112713591
	--DECLARE @UMID uniqueidentifier = NULL
	--DECLARE @Country char(2) = NULL --'ID'
	--DECLARE @OperatorId int = NULL
	--DECLARE @SenderId varchar(20) = NULL
	--DECLARE @ShortenStatusId tinyint = 4--NULL
	--DECLARE @OutputTotals bit = 0
	--DECLARE @Offset int = 0
	--DECLARE @Limit int = 100
	--DECLARE @AccountUid uniqueidentifier = '619250fe-e2e5-e611-813f-06b9b96ca965' /* for testing stage 'wavecell_monitoring' */
	--DECLARE @SubAccountId varchar(50) = NULL--'wavecell_mon_1'
	--DECLARE @TimeframeStart datetime = '2017-08-18 15:00'
	--DECLARE @TimeframeEnd datetime = '2017-08-29 15:00'
	--SET @AccountUid = '0FC250D4-6182-E711-8143-02D85F55FCE7'

	IF @Limit < 1 SET @Limit = 1
	IF @Limit > 100 SET @Limit = 100

	-- create temp table
	IF OBJECT_ID('tempdb.dbo.#SmsLogOutputT', 'U') IS NOT NULL 
		DROP TABLE #SmsLogOutputT

	CREATE TABLE #SmsLogOutputT (
		UMID uniqueidentifier NOT NULL,
		SubAccountId varchar(50) NULL,
		CreatedTime smalldatetime NULL,
		SmsTypeId tinyint NOT NULL,
		Country char(2) NULL,
		OperatorId int NULL,
		OperatorName nvarchar(255) NULL,
		MSISDN bigint NOT NULL,
		SourceOriginal varchar(20) NULL,
		Source varchar(20) NOT NULL,
		Body nvarchar(1600) NOT NULL,
		SegmentsReceived tinyint NOT NULL,
		Price real NOT NULL,
		PriceCurrency char(3) NOT NULL,
		StatusId tinyint NULL,
		Final bit NULL,
		Status varchar(20) NULL,
		ClientMessageId varchar(50) NULL,
		ClientBatchId varchar(50) NULL,
		ConnectionType varchar(20) NULL,
		EncodingType varchar(20) NULL
	)

	-- prepare SQL query
	DECLARE @TotalOutputCount smallint = 0
	DECLARE @TopCount smallint --@OutputCount smallint = 0, 
	DECLARE @MaxOutputCount smallint = @Offset + @Limit
	
	DECLARE @sql AS NVARCHAR(4000);
	DECLARE @where AS NVARCHAR(3000) = 
		'WHERE (sl.CreatedTime BETWEEN @TimeframeStart AND @TimeframeEnd) AND sl.SubAccountId = @SubAccountId AND sl.SmsTypeId = 1'
		+ CASE WHEN @UMID IS NOT NULL THEN ' AND sl.UMID = @UMID' ELSE '' END
		+ CASE WHEN @MSISDN IS NOT NULL THEN ' AND sl.MSISDN = @MSISDN' ELSE '' END
		+ CASE WHEN @SenderId IS NOT NULL AND @UMID IS NULL THEN ' AND sl.Source = @SenderId' ELSE '' END
		+ CASE WHEN @Country IS NOT NULL AND @MSISDN IS NULL AND @UMID IS NULL THEN ' AND sl.Country = @Country' ELSE '' END
		+ CASE WHEN @OperatorId IS NOT NULL AND @MSISDN IS NULL AND @UMID IS NULL THEN ' AND sl.OperatorId = @OperatorId' ELSE '' END
		--+ CASE WHEN @SubAccountId IS NOT NULL THEN ' AND sl.SubAccountId = @SubAccountId' 
		--	ELSE ' AND a.AccountUid = @AccountUid' END
			--ELSE ' AND sl.SubAccountId IN (SELECT sa.SubAccountId FROM dbo.Account sa INNER JOIN cp.Account a ON sa.AccountId = a.AccountId WHERE a.AccountUid = @AccountUid)' END
		+ CASE WHEN @ShortenStatusId IS NOT NULL AND @UMID IS NULL THEN ' AND sl.StatusId IN (SELECT StatusId FROM sms.DimSmsStatus dss WHERE dss.ShortenStatusId = @ShortenStatusId)' ELSE '' END
		+ CASE WHEN @CampaignId IS NOT NULL AND @UMID IS NULL THEN ' AND EXISTS (SELECT 1 
			FROM cp.CmCampaign c
				INNER JOIN cp.CmCampaignBatchIds cb ON c.CampaignId = cb.CampaignId
				INNER JOIN dbo.Account sa ON c.SubAccountId = sa.SubAccountId AND sa.SubAccountId = @SubAccountId
			WHERE c.CampaignId = @CampaignId
				AND sl.CreatedTime BETWEEN DATEADD(MINUTE, -1, c.ScheduledAt) AND DATEADD(MINUTE, 60, c.ScheduledAt) 
				AND sl.BatchId = cb.BatchId)' ELSE '' END

	SET @sql = 
		'INSERT INTO #SmsLogOutputT (UMID, CreatedTime, SubAccountId, SmsTypeId, Country, OperatorId, OperatorName, MSISDN, SourceOriginal, Source, Body, SegmentsReceived, Price, PriceCurrency, StatusId, Final, Status, ClientMessageId, ClientBatchId, ConnectionType, EncodingType)
		SELECT TOP (@TopCount) sl.UMID, CAST(sl.CreatedTime as smalldatetime) as CreatedTime, sa.SubAccountId, sl.SmsTypeId, sl.Country, sl.OperatorId, o.OperatorName, sl.MSISDN, sl.SourceOriginal, sl.Source,
			sl.Body, sl.SegmentsReceived, (sl.SegmentsReceived * sl.PriceContractPerSms) AS Price, sl.PriceContractCurrency, st.ShortenStatusId AS StatusId, st.Final, st.ShortenStatusName AS Status, 
			sl.ClientMessageId, IIF(sl.BatchId IS NULL, NULL, sl.ClientBatchId) AS ClientBatchId, 
			dct.ConnectionType, det.EncodingType
		FROM sms.SmsLog sl  WITH (INDEX (IX_SmsLog_SubAccount_CreatedTime), NOLOCK)
			LEFT JOIN dbo.Account sa ON sl.SubAccountId = sa.SubAccountId
			LEFT JOIN mno.Operator o ON sl.OperatorId = o.OperatorId
			LEFT JOIN sms.DimSmsStatus st ON sl.StatusId = st.StatusId
			LEFT JOIN sms.DimConnType dct ON sl.ConnTypeId = dct.ConnTypeId
			LEFT JOIN sms.DimEncodingType det ON sl.EncodingTypeId = det.EncodingTypeId '
		+ @where
		+ ' ORDER BY sl.UMID DESC'
		--+ ' ORDER BY sl.UMID OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY';

	-- for debug
	--PRINT @sql

	-- get flag of filtering by allowed subaccounts for User
    DECLARE @LimitSubAccounts bit = 0	-- default if @UserId is null
	SELECT @LimitSubAccounts = cu.LimitSubAccounts 
	FROM cp.[User] cu
	WHERE cu.AccountUid = @AccountUid AND cu.UserId = @UserId
	
	/* CURSOR */
    DECLARE @task_cursor CURSOR
	SET @task_cursor = CURSOR FOR
		SELECT SubAccountId
		FROM dbo.Account sa 
			INNER JOIN cp.Account a ON sa.AccountId = a.AccountId
		WHERE a.AccountUid = @AccountUid 
			AND ISNULL(@SubAccountId, sa.SubAccountId) = sa.SubAccountId
			-- filter by allowed subaccounts for user
			AND (@LimitSubAccounts = 0 OR (@LimitSubAccounts = 1 AND
				sa.SubAccountUid IN (SELECT SubAccountUid FROM cp.UserSubAccount usa WHERE usa.UserId = @UserId)
			))

	OPEN @task_cursor  

	FETCH NEXT FROM @task_cursor   
	INTO @SubAccountId

	WHILE @@FETCH_STATUS = 0 AND @TotalOutputCount < @MaxOutputCount
	BEGIN
		SET @TopCount = @MaxOutputCount - @TotalOutputCount

		EXEC sp_executesql @sql,
		  N'	@TimeframeStart datetime,
				@TimeframeEnd datetime,
				@AccountUid uniqueidentifier,
				@SubAccountId varchar(50),
				@MSISDN bigint,
				@SenderId varchar(20),
				@UMID uniqueidentifier,
				@Country char(2),
				@OperatorId int,
				@ShortenStatusId tinyint,
				@CampaignId int,
				@Offset int,
				@Limit int,
				@TopCount smallint',
			@TimeframeStart = @TimeframeStart,
			@TimeframeEnd = @TimeframeEnd,
			@AccountUid = @AccountUid,
			@SubAccountId = @SubAccountId,
			@UMID = @UMID,
			@MSISDN = @MSISDN,
			@SenderId = @SenderId,
			@Country = @Country,
			@OperatorId = @OperatorId,
			@ShortenStatusId = @ShortenStatusId,
			@CampaignId = @CampaignId,
			@Offset = @Offset,
			@Limit = @Limit,
			@TopCount = @TopCount;

		SET @TotalOutputCount += @@ROWCOUNT
		--PRINT @SubAccountId + ', SUM = ' + cast(@TotalOutputCount as varchar(10))

		FETCH NEXT FROM @task_cursor
		INTO @SubAccountId
	END
	CLOSE @task_cursor;
	DEALLOCATE @task_cursor;

	-- returns output 
	SELECT *
	FROM #SmsLogOutputT sl
	ORDER BY sl.SubAccountId, sl.UMID DESC OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY

	-- returns totals
	IF @OutputTotals = 1
		SELECT IIF(@TotalOutputCount >= @MaxOutputCount, IIF (@TotalOutputCount >= 1000, 1000, @TotalOutputCount + @Limit), @TotalOutputCount) AS TotalCount

END
