
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-25
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 26/11/2018  Rebecca  Modified the sql for insert into #UrlStat
-- 4/5/2020	   Rebecca  Modified to add in converted sms
-- 
-- INSERT INTO sms.JobCalculate (TimeframeStart, TimeframeEnd, SubAccountUid, Country, OperatorId) VALUES ('2019-07-24', '2018-07-25 03:30:00', NULL, NULL, NULL)
-- EXEC sms.job_SmsLog_CalculateStats
-- SELECT TOP 100 * FROM sms.vwStatSmsLog ORDER BY TimeFrom DESC
-- SELECT TOP 100 * FROM sms.vwStatUrlShorten ORDER BY TimeFrom DESC
-- SELECT * FROM sms.JobCalculate WHERE CompletedAt IS NOT NULL ORDER BY StartedAt DESC
CREATE PROCEDURE [sms].[job_SmsLog_CalculateStats]
AS
BEGIN

	SET NOCOUNT ON

	/* KEY CONST */	
	DECLARE @TimeIntervalInMinsSms smallint = 15
	DECLARE @TimeIntervalInMinsUrl smallint = 60
	DECLARE @JobsLimitPerCall smallint = 100
	DECLARE @ConstRefDate smalldatetime = '2017/01/01' -- static value, just for basic of calculations

	/************************/
	/*   Step 1: PLAN JOBS  */
	/************************/
	-- add generic task to recalc last X minutes of traffic
	EXEC sms.job_SmsLog_AddJob @PastMinutes = 30

	/************************/
	/* Step 2: CLEANUP JOBS */
	/************************/
	-- Step 2.1: Cleanup of duplicated jobs
	DELETE FROM t1
	--SELECT *
	FROM sms.JobCalculate t1 INNER JOIN sms.JobCalculate t2
		ON ISNULL(t1.SubAccountUid, 0) = ISNULL(t2.SubAccountUid, 0)
			AND ISNULL(t1.Country,'') = ISNULL(t2.Country,'')
			AND ISNULL(t1.OperatorId, 0) = ISNULL(t2.OperatorId, 0)
	WHERE t1.CompletedAt IS NULL AND t2.CompletedAt IS NULL 
		AND t1.StartedAt IS NULL AND t2.StartedAt IS NULL
		AND t1.TimeframeStart >= t2.TimeframeStart AND t1.TimeframeEnd <= t2.TimeframeEnd
		AND t1.JobId <> t2.JobId
	PRINT dbo.Log_ROWCOUNT ('Cleanup of duplicated jobs in JobCalculate')

	-- Step 2.2: Optimization using grouping of jobs with crossing periods
	DECLARE @JobsToGroup AS TABLE (
		JobId int NOT NULL,
		TimeFrom smalldatetime NOT NULL,
		TimeTill smalldatetime NOT NULL,
		SubAccountUid int NULL,
		Country char(2) NULL,
		OperatorId int NULL
	)

	-- find jobs with crossing periods
	INSERT INTO @JobsToGroup (JobId, TimeFrom, TimeTill, SubAccountUid, Country, OperatorId)
	SELECT t1.JobId, t1.TimeframeStart, t1.TimeframeEnd, t1.SubAccountUid, t1.Country, t1.OperatorId
	--SELECT *
	FROM sms.JobCalculate t1 INNER JOIN sms.JobCalculate t2
		ON ISNULL(t1.SubAccountUid, 0) = ISNULL(t2.SubAccountUid, 0)
			AND ISNULL(t1.Country,'') = ISNULL(t2.Country,'')
			AND ISNULL(t1.OperatorId, 0) = ISNULL(t2.OperatorId, 0)
	WHERE t1.CompletedAt IS NULL AND t2.CompletedAt IS NULL 
		AND t1.StartedAt IS NULL AND t2.StartedAt IS NULL
		AND t1.TimeframeStart <= t2.TimeframeStart 
		AND t1.TimeframeEnd <= t2.TimeframeEnd
		AND t1.TimeframeEnd > t2.TimeframeStart
		AND t1.JobId <> t2.JobId
		AND t1.SubAccountUid IS NULL

	INSERT INTO sms.JobCalculate (TimeframeStart, TimeframeEnd, SubAccountUid, Country, OperatorId)
	SELECT 
		MIN(TimeFrom) AS TimeframeStart, 
		MAX(TimeTill) AS TimeframeEnd,
		SubAccountUid, Country, OperatorId
	FROM @JobsToGroup
	GROUP BY SubAccountUid, Country, OperatorId

	DELETE FROM j
	FROM sms.JobCalculate j
		INNER JOIN @JobsToGroup g ON j.JobId = g.JobId

	PRINT dbo.Log_ROWCOUNT ('Optimization: Grouping of similar jobs in JobCalculate in case of higher queue of jobs, slow processing')

	-- Step 2.3: Cleanup of old completed jobs
	DELETE FROM t1
	FROM sms.JobCalculate t1
	WHERE t1.CompletedAt < DATEADD(DAY, -10, SYSUTCDATETIME())
	PRINT dbo.Log_ROWCOUNT ('Cleanup of old completed jobs in JobCalculate')

	/************************/
	/* Step 3: EXECUTE JOBS */
	/************************/

	DECLARE @RecordUpdated TABLE (Id int)
	DECLARE @JobId int, @SubAccountUid int, @Country char(2), @OperatorId int, @TimeCounter datetime
	DECLARE @TimeframeStart smalldatetime, @TimeframeEnd smalldatetime
	DECLARE @SubAccountId varchar(50) ;

	--IF OBJECT_ID('tempdb..#SmsLogStat') IS NOT NULL DROP TABLE #SmsLogStat
	---- Starting Sql Server 2016 we can use
	----DROP TABLE IF EXISTS tempdb.dbo.#SmsLogStat
	CREATE TABLE #SmsLogStat
	(
		Id int IDENTITY (1,1) PRIMARY KEY,
		fRecordSynced bit NOT NULL DEFAULT(0),
		/* Grouping columns */
		TimeFrom smalldatetime NOT NULL,
		TimeTill smalldatetime NOT NULL,
		AccountUid uniqueidentifier NOT NULL,
		SubAccountUid int NOT NULL,
		Country char(2),
		OperatorId int,
		SmsTypeId tinyint NOT NULL,
		ConnUid int,
		CostContractCurrency char(3) NULL,
		PriceContractCurrency char(3) NULL,
		/* Aggregation columns */
		--Cost real NOT NULL,		--depricated
		--Price real NOT NULL,		--depricated
		CostContract decimal(18,6) NULL,
		PriceContract decimal(18,6) NULL,
		CostEUR decimal(18,6) NOT NULL,
		PriceEUR decimal(18,6) NOT NULL,
		SmsCountTotal int NOT NULL,
		SmsCountDelivered int NOT NULL,
		SmsCountUndelivered int NOT NULL,
		SmsCountRejected int NOT NULL,
		SmsCountProcessingWavecell int NOT NULL,
		SmsCountProcessingSupplier int NOT NULL,
		SmsCountConverted int,
		MsgCountTotal int NOT NULL,
		MsgCountDelivered int NOT NULL,
		MsgCountUndelivered int NOT NULL,
		MsgCountRejected int NOT NULL,
		MsgCountProcessingWavecell int NOT NULL,
		MsgCountProcessingSupplier int NOT NULL,
		MsgCountConverted int
	)

	--IF OBJECT_ID('tempdb..#SmsLogStatDaily') IS NOT NULL DROP TABLE #SmsLogStatDaily
	---- Starting Sql Server 2016 we can use
	----DROP TABLE IF EXISTS tempdb.dbo.#SmsLogStatDaily
	CREATE TABLE #SmsLogStatDaily
	(
		Id int IDENTITY (1,1) PRIMARY KEY,
		fRecordSynced bit NOT NULL DEFAULT(0),
		/* Grouping columns */
		Date date NOT NULL,
		AccountUid uniqueidentifier NOT NULL,
		SubAccountUid int NOT NULL,
		Country char(2),
		OperatorId int,
		SmsTypeId tinyint NOT NULL,
		ConnUid int,
		CostContractCurrency char(3) NULL,
		PriceContractCurrency char(3) NULL,
		/* Aggregation columns */
		--Cost real NOT NULL,		--depricated
		--Price real NOT NULL,		--depricated
		CostContract decimal(18,6) NULL,
		PriceContract decimal(18,6) NULL,
		CostEUR decimal(18,6) NOT NULL,
		PriceEUR decimal(18,6) NOT NULL,
		SmsCountTotal int NOT NULL,
		SmsCountDelivered int NOT NULL,
		SmsCountUndelivered int NOT NULL,
		SmsCountRejected int NOT NULL,
		SmsCountProcessingWavecell int NOT NULL,
		SmsCountProcessingSupplier int NOT NULL,
		SmsCountConverted int,
		MsgCountTotal int NOT NULL,
		MsgCountDelivered int NOT NULL,
		MsgCountUndelivered int NOT NULL,
		MsgCountRejected int NOT NULL,
		MsgCountProcessingWavecell int NOT NULL,
		MsgCountProcessingSupplier int NOT NULL,
		MsgCountConverted int
	)

	--IF OBJECT_ID('tempdb..#UrlStat') IS NOT NULL DROP TABLE #UrlStat
	---- Starting Sql Server 2016 we can use
	----DROP TABLE IF EXISTS tempdb.dbo.#UrlStat
	CREATE TABLE #UrlStat
	(
		Id int IDENTITY (1,1) PRIMARY KEY,
		fRecordSynced bit NOT NULL DEFAULT(0),
		/* Grouping columns */
		TimeFrom smalldatetime NOT NULL,
		SubAccountUid int NOT NULL,
		BaseUrlId int NOT NULL,
		/* Aggregation columns */
		MsgTotal int NOT NULL,
		MsgDelivered int NOT NULL,
		UrlCreated int NOT NULL,
		UrlClicked int NOT NULL
	)

	-- table to store list of processed Jobs
	DECLARE @JobsProcessed AS TABLE (JobId int)

	-- table to store list of filters to recalc sms.SmsLogStatDaily
	DECLARE @SmsLogStatDailyToRecalc AS TABLE (
		[Date] date, 
		SubAccountUid int, 
		Country char(2), 
		OperatorId int,
		SmsTypeId tinyint,
		ConnUid int
	)

	/* CURSOR - List of Jobs to process */
	DECLARE task_cursor CURSOR LOCAL FOR   
		--SELECT JobId, TimeframeStart, TimeframeEnd, SubAccountUid, Country, OperatorId FROM @JobsBatch
		-- default job for all subaccounts is in priority, we should do it first
		SELECT JobId, TimeframeStart, TimeframeEnd, SubAccountUid, Country, OperatorId
		FROM sms.JobCalculate
		WHERE CompletedAt IS NULL AND (StartedAt IS NULL OR StartedAt < DATEADD(HOUR, -2, SYSUTCDATETIME()))
			AND SubAccountUid IS NULL
		UNION ALL
		-- micro tasks by SubAccounts goes in limited set, by batches
		SELECT TOP (@JobsLimitPerCall) 
			JobId, TimeframeStart, TimeframeEnd, SubAccountUid, Country, OperatorId
		FROM sms.JobCalculate
		WHERE CompletedAt IS NULL AND (StartedAt IS NULL OR StartedAt < DATEADD(HOUR, -2, SYSUTCDATETIME()))
			AND SubAccountUid IS NOT NULL
			--AND CreatedAt >= '2019-02-01'
			--AND TimeframeStart >= '2019-02-01'
		ORDER BY TimeframeStart ASC
		--ORDER BY SubAccountUid /* to process NULL(=ALL) value first */, JobId
		
	OPEN task_cursor  

	FETCH NEXT FROM task_cursor   
	INTO @JobId, @TimeframeStart, @TimeframeEnd, @SubAccountUid, @Country, @OperatorId

	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Adjust time intervals according to @TimeIntervalInMinsSms
		SET @TimeframeStart = dbo.fnTimeRountdown(@TimeframeStart, @TimeIntervalInMinsSms)
		SET @TimeframeEnd = dbo.fnTimeRountdown(DATEADD(MINUTE, @TimeIntervalInMinsSms-1, @TimeframeEnd), @TimeIntervalInMinsSms)

		-- Mark task as started and adjust timeslots
		UPDATE sms.JobCalculate
		SET StartedAt = SYSUTCDATETIME(), TimeframeStart = @TimeframeStart, TimeframeEnd = @TimeframeEnd 
		WHERE JobId = @JobId
	
		PRINT dbo.CURRENT_TIMESTAMP_STR() + '***********************'
		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'JobId=' + CAST(@JobId AS varchar(10)) + ' PERIOD: ' + CONVERT(varchar(50), @TimeframeStart, 20) + ' - ' + CONVERT(varchar(50), @TimeframeEnd, 20)
		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'FILTER: SubAccountUid=' + ISNULL(CAST(@SubAccountUid AS varchar(10)),'NULL') + ' AND Country=' + ISNULL(CAST(@Country as varchar(4)),'NULL') + ' AND OperatorId=' + ISNULL(CAST(@OperatorId as varchar(10)),'NULL')
		SET @ConstRefDate = @TimeframeStart
		SET @TimeCounter = CURRENT_TIMESTAMP

		IF @SubAccountUid IS NOT NULL
			SELECT @SubAccountId = SubAccountId
			FROM ms.SubAccount
			WHERE SubAccountUid = @SubAccountUid ;

		-- clean table before starting next iteration of aggregating data
		TRUNCATE TABLE #SmsLogStat

		INSERT INTO #SmsLogStat (
			TimeFrom, TimeTill, 
			AccountUid, SubAccountUid, 
			Country, OperatorId, 
			SmsTypeId, ConnUid, 
			CostContractCurrency, CostContract, CostEUR,
			PriceContractCurrency, PriceContract,PriceEUR,  
			SmsCountTotal, SmsCountDelivered, SmsCountUndelivered, SmsCountRejected, SmsCountProcessingWavecell, SmsCountProcessingSupplier, SmsCountConverted,
			MsgCountTotal, MsgCountDelivered, MsgCountUndelivered, MsgCountRejected, MsgCountProcessingWavecell, MsgCountProcessingSupplier, MsgCountConverted)
		SELECT TimeFrom,
				DATEADD(MINUTE, @TimeIntervalInMinsSms, TimeFrom) as TimeTill,
				a.AccountUid,
				sl.SubAccountUid,
				sl.Country,
				sl.OperatorId,
				sl.SmsTypeId,
				sl.ConnUid,
				sl.CostContractCurrency,
				SUM(IIF(sl.StatusId = 21, 0, sl.SegmentsReceived * sl.CostContractPerSms)) as CostContract,
				SUM(IIF(sl.StatusId = 21, 0, sl.SegmentsReceived * ISNULL(sl.CostEURPerSms, sl.Cost))) as CostEUR,
				sl.PriceContractCurrency, 
				--SUM(sl.SegmentsReceived * sl.Price) as Price,
				SUM(IIF(sl.StatusId = 21, 0, sl.SegmentsReceived * sl.PriceContractPerSms)) as PriceContract,
				SUM(IIF(sl.StatusId = 21, 0, sl.SegmentsReceived * ISNULL(sl.PriceEURPerSms, sl.Price))) as PriceEUR,
				/* SmsCounts */
				SUM(sl.SegmentsReceived) as SmsCountTotal,
				SUM(CASE WHEN sl.StatusId IN (40, 50) /* DELIVERED TO DEVICE, READ */ THEN sl.SegmentsReceived ELSE 0 END) as SmsCountDelivered,
				SUM(CASE WHEN sl.StatusId IN (31, 41) /* REJECTED TO CARRIER, REJECTED TO DEVICE */ THEN sl.SegmentsReceived ELSE 0 END) as SmsCountUndelivered,
				SUM(CASE WHEN sl.StatusId = 21 /* TRASHED */ THEN sl.SegmentsReceived ELSE 0 END) as SmsCountRejected,
				SUM(CASE WHEN sl.StatusId IN (0, 10, 11, 20) /* Final=0 */ THEN sl.SegmentsReceived ELSE 0 END) as SmsCountProcessingWavecell,
				SUM(CASE WHEN sl.StatusId = 30 /* DELIVERED TO CARRIER */ THEN sl.SegmentsReceived ELSE 0 END) as SmsCountProcessingSupplier,
				SUM(CASE WHEN sl.Converted = 1 /* Read */ THEN sl.SegmentsReceived ELSE 0 END) as SmsCountConverted,
				/* MsgCounts */
				COUNT(1) as MsgCountTotal,
				SUM(CASE WHEN sl.StatusId IN (40, 50) /* DELIVERED TO DEVICE, READ */ THEN 1 ELSE 0 END) as MsgCountDelivered,
				SUM(CASE WHEN sl.StatusId IN (31, 41) /* REJECTED TO CARRIER, REJECTED TO DEVICE */ THEN 1 ELSE 0 END) as MsgCountUndelivered,
				SUM(CASE WHEN sl.StatusId = 21 /* TRASHED */ THEN 1 ELSE 0 END) as MsgCountRejected,
				SUM(CASE WHEN sl.StatusId IN (0, 10, 11, 20) /* Final=0 */ THEN 1 ELSE 0 END) as MsgCountProcessingWavecell,
				SUM(CASE WHEN sl.StatusId = 30 /* DELIVERED TO CARRIER */ THEN 1 ELSE 0 END) as MsgCountProcessingSupplier,
				SUM(sl.Converted) as MsgCountConverted
		FROM
			(SELECT s.*, 
				dbo.fnTimeRounddown(s.CreatedTime, @TimeIntervalInMinsSms) as TimeFrom,
				IIF(s.StatusId <> 21 AND dlRead.UMID IS NOT NULL, 1, 0) AS Converted -- Status 50 (READ) found in dlrlog
			--SELECT TOP 100 DATEDIFF(minute, '2017/01/01', sl.CreatedTime) / @TimeIntervalInMinsSms, *
			FROM sms.SmsLog s WITH (NOLOCK, INDEX(IX_SmsLog_CreatedTime))
				OUTER APPLY (SELECT TOP 1 UMID FROM sms.DlrLog WITH (NOLOCK, FORCESEEK) WHERE UMID = s.UMID AND StatusId = 50) dlRead
				--LEFT JOIN sms.DlrLog dlRead WITH (NOLOCK, FORCESEEK) ON s.UMID = dlRead.UMID AND dlRead.StatusId = 50 /* READ */
				--INNER JOIN dbo.Account a ON sl.SubAccountId = a.SubAccountId
				--INNER JOIN cp.Account ca ON ca.AccountId = a.AccountId
			WHERE 
				(CreatedTime >= @TimeframeStart AND CreatedTime < @TimeframeEnd)
				/* TODO: rewrite filters to dynamic query */
				AND (@SubAccountUid IS NULL OR s.SubAccountId = @SubAccountId)
				AND (@Country IS NULL OR s.Country = @Country)
				AND (@OperatorId IS NULL OR s.OperatorId = @OperatorId)
				--sl.SmsTypeId = 1 /* MT */
			) sl
			INNER JOIN ms.SubAccount a ON sl.SubAccountId = a.SubAccountId
		GROUP BY
			a.AccountUid,
			sl.SubAccountUid, 
			sl.Country, 
			sl.OperatorId, 
			sl.SmsTypeId, 
			sl.ConnUid,
			sl.CostContractCurrency,
			sl.PriceContractCurrency,
			sl.TimeFrom ;
		--ORDER BY TimeFrom, AccountUid, SubAccountUid

		PRINT dbo.Log_ROWCOUNT ('Temp table #SmsLogStat populated')
		
		--SELECT * FROM #SmsLogStat
		
		-- Calc Url Shorten analytics
		IF (@SubAccountUid IS NULL) OR
			(@SubAccountUid IS NOT NULL
				AND NOT EXISTS (SELECT 1 FROM ms.UrlShortenDomainSubAccount WHERE SubAccountUid = @SubAccountUid))
			GOTO SkipUrlStat

		-- clean table before starting next iteration of aggregating data
		TRUNCATE TABLE #UrlStat

		DECLARE @UrlStartTime SMALLDATETIME, @UrlEndTime SMALLDATETIME ;

		SET @UrlStartTime = dbo.fnTimeRoundDown(@TimeframeStart, @TimeIntervalInMinsUrl) ;
		SET @UrlEndTime = dbo.fnTimeRoundUp(@TimeframeEnd, @TimeIntervalInMinsUrl) ;

		PRINT dbo.CURRENT_TIMESTAMP_STR() + CAST(@TimeframeStart AS VARCHAR(20)) + ' to ' + CAST(@TimeframeEnd AS VARCHAR(20)) ;

		--SELECT @SubAccountId = SubAccountId
		--FROM dbo.Account
		--WHERE SubAccountUid = @SubAccountUid ;

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'SubAccountId = ' + ISNULL(@SubAccountId, '<NULL>')

		INSERT INTO #UrlStat (
			TimeFrom, 
			SubAccountUid,
			BaseUrlId,
			MsgTotal, 
			MsgDelivered,
			UrlCreated, 
			UrlClicked)
		SELECT A.TimeFrom, @SubAccountUid, B.BaseUrlId,
			COUNT(DISTINCT A.UMID) MsgTotal,
			SUM(CASE WHEN A.StatusId IN (30, 40, 50) THEN 1 ELSE 0 END) AS MsgDelivered,
			COUNT(1) UrlCreated,
			SUM(CASE WHEN B.Hits > 0 THEN 1 ELSE 0 END) AS UrlClicked
		FROM
			(SELECT UMID, CreatedTime, StatusId, dbo.fnTimeRoundDown(CreatedTime, @TimeIntervalInMinsUrl) TimeFrom
			FROM sms.SmsLog WITH (NOLOCK, INDEX(IX_SmsLog_SubAccount_CreatedTime))
			WHERE SubAccountId = @SubAccountId
				AND CreatedTime >= @UrlStartTime
				AND CreatedTime < @UrlEndTime
			) A JOIN
			sms.UrlShorten B WITH (NOLOCK, INDEX(IX_smsUrlShorten_UMID))
		ON A.UMID = B.UMID
		GROUP BY A.TimeFrom, B.BaseUrlId ;

/*
		SELECT 
			dbo.fnTimeRountdown(MIN(sl.CreatedTime), @TimeIntervalInMinsUrl) as TimeFrom,
			sl.SubAccountUid,
			u.BaseUrlId,
			COUNT(DISTINCT sl.UMID) MsgTotal, 
			COUNT(DISTINCT (CASE WHEN sl.StatusId IN (30, 40) THEN sl.UMID END)) AS MsgDelivered,
			COUNT(1) AS UrlCreated,
			SUM(CASE WHEN u.Hits > 0 THEN 1 ELSE 0 END) AS UrlClicked
		FROM sms.SmsLog sl WITH (NOLOCK, INDEX(IX_SmsLog_SubAccount_CreatedTime))
			INNER JOIN sms.UrlShorten u (NOLOCK) ON u.UMID = sl.UMID
			INNER JOIN dbo.Account sa ON sl.SubAccountId = sa.SubAccountId
			INNER JOIN ms.UrlShortenDomainSubAccount f ON f.SubAccountUid = sa.SubAccountUid
		WHERE sl.CreatedTime >= @UrlStartTime
			AND sl.CreatedTime < @UrlEndTime
			AND (@SubAccountUid IS NULL OR (@SubAccountUid IS NOT NULL AND sa.SubAccountUid = @SubAccountUid))
		GROUP BY 
			sl.SubAccountUid,
			u.BaseUrlId,
			DATEDIFF(MINUTE, @ConstRefDate, sl.CreatedTime) / @TimeIntervalInMinsUrl
*/
		PRINT dbo.Log_ROWCOUNT ('Temp table #UrlStat populated')

		--if exists(
		--	select TimeFrom, SubAccountUid, BaseUrlId
		--	from #UrlStat
		--	group by TimeFrom, SubAccountUid, BaseUrlId
		--	having count(1) > 1
		--)
		--BEGIN
		--	insert into tempdb.dbo.tmp20180906_UrlShortenLog
		--	SELECT @JobId as JobId,
		--		DATEDIFF(MINUTE, '2017-01-01', sl.CreatedTime) / 60 as Step,
		--		dbo.fnTimeRountdown(sl.CreatedTime, 60) as TimeFrom,
		--		sl.*, u.BaseUrlId
		--	FROM sms.SmsLog sl WITH (NOLOCK, INDEX(IX_SmsLog_SubAccount_CreatedTime))
		--		INNER JOIN sms.UrlShorten u (NOLOCK) ON u.UMID = sl.UMID
		--		INNER JOIN dbo.Account sa ON sl.SubAccountId = sa.SubAccountId
		--		INNER JOIN ms.UrlShortenDomainSubAccount f ON f.SubAccountUid = sa.SubAccountUid
		--	WHERE sl.CreatedTime >= dbo.fnTimeRountdown(@TimeframeStart, @TimeIntervalInMinsUrl)
		--		AND sl.CreatedTime < dbo.fnTimeRountup(@TimeframeEnd, @TimeIntervalInMinsUrl)
		--		AND (@SubAccountUid IS NULL OR (@SubAccountUid IS NOT NULL AND sa.SubAccountUid = @SubAccountUid))
		--END

		DELETE FROM @RecordUpdated

		UPDATE sl
		SET MsgTotal = t.MsgTotal,
			MsgDelivered = t.MsgDelivered,
			UrlCreated = t.UrlCreated,
			UrlClicked = t.UrlClicked
			--LastUpdatedAt = SYSUTCDATETIME()
		OUTPUT t.Id INTO @RecordUpdated (Id)
		FROM sms.StatUrlShorten sl
			INNER JOIN #UrlStat t 
					ON	t.TimeFrom = sl.TimeFrom 
						AND t.SubAccountUid = sl.SubAccountUid
						AND t.BaseUrlId = sl.BaseUrlId
						
		PRINT dbo.Log_ROWCOUNT ('Update existing records in sms.StatUrlShorten')

		--DELETE FROM t FROM #UrlStat t INNER JOIN @RecordUpdated i ON t.Id = i.Id
		UPDATE t SET fRecordSynced = 1 
		FROM #UrlStat t INNER JOIN @RecordUpdated i ON t.Id = i.Id

		--troubleshooting
		--insert into tempdb.dbo.UrlStat (
		--	fRecordSynced,
		--	TimeFrom,
		--	SubAccountUid,
		--	BaseUrlId,
		--	MsgTotal,
		--	MsgDelivered,
		--	UrlCreated,
		--	UrlClicked,
		--	JobId)
		--select 
		--	fRecordSynced,
		--	TimeFrom,
		--	SubAccountUid,
		--	BaseUrlId,
		--	MsgTotal,
		--	MsgDelivered,
		--	UrlCreated,
		--	UrlClicked,
		--	@JobId AS JobId
		--from #UrlStat

		-- workaround for mistery MSSQL bug with incorrect grouping
		DELETE FROM u1
		FROM #UrlStat u1
			INNER JOIN (
				SELECT Id, 
					ROW_NUMBER() OVER(PARTITION BY TimeFrom, BaseUrlId, SubAccountUid ORDER BY fRecordSynced DESC) AS RowNum
				FROM #UrlStat
			) u2 ON u1.Id = u2.Id
		WHERE u2.RowNum > 1 AND u1.fRecordSynced = 0
		PRINT dbo.Log_ROWCOUNT ('Bug fixing of duplicated records in #UrlStat')

		INSERT INTO sms.StatUrlShorten (
			TimeFrom, 
			SubAccountUid, 
			BaseUrlId,
			MsgTotal, MsgDelivered,
			UrlCreated, UrlClicked)
		SELECT 
			TimeFrom, 
			SubAccountUid, 
			BaseUrlId, 
			MsgTotal, MsgDelivered,
			UrlCreated, UrlClicked
		FROM #UrlStat t 
		WHERE t.fRecordSynced = 0

		PRINT dbo.Log_ROWCOUNT ('Insert new records to sms.StatUrlShorten')
	--tag 
	SkipUrlStat:

		-- Save data to StatSmsLog
		DELETE FROM sl 
		OUTPUT CAST(deleted.TimeFrom AS date), deleted.SubAccountUid, deleted.Country, deleted.OperatorId, deleted.SmsTypeId, deleted.ConnUid
		INTO @SmsLogStatDailyToRecalc ([Date], SubAccountUid, Country, OperatorId, SmsTypeId, ConnUid)
		--select *
		FROM sms.StatSmsLog sl
			LEFT JOIN #SmsLogStat t 
					ON t.TimeFrom = sl.TimeFrom AND t.TimeTill = sl.TimeTill AND t.SubAccountUid = sl.SubAccountUid
						AND ISNULL(t.Country, '') = ISNULL(sl.Country, '')
						AND ISNULL(t.OperatorId, -1) = ISNULL(sl.OperatorId, -1)
						AND t.SmsTypeId = sl.SmsTypeId
						AND ISNULL(t.ConnUid, '') = ISNULL(sl.ConnUid, '')
						AND ISNULL(t.CostContractCurrency,'') = ISNULL(sl.CostContractCurrency, '')
						AND ISNULL(t.PriceContractCurrency, '') = ISNULL(sl.PriceContractCurrency, '')
		WHERE sl.TimeFrom >= @TimeframeStart AND sl.TimeFrom < @TimeframeEnd
			AND (@SubAccountUid IS NULL OR sl.SubAccountUid = @SubAccountUid)
			AND (@Country IS NULL OR sl.Country = @Country)
			AND (@OperatorId IS NULL OR sl.OperatorId = @OperatorId)
			AND t.TimeFrom IS NULL
			--AND NOT EXISTS (
			--	SELECT 1 FROM sl INNER JOIN #SmsLogStat t 
			--		ON t.TimeFrom = sl.TimeFrom AND t.TimeTill = sl.TimeTill AND t.SubAccountUid = sl.SubAccountUid
			--			AND ISNULL(t.Country,'') = ISNULL(sl.Country, '')
			--			AND ISNULL(t.OperatorId,'') = ISNULL(sl.OperatorId, '')
			--			AND t.SmsTypeId = sl.SmsTypeId
			--			AND t.ConnUid = sl.ConnUid)

		PRINT dbo.Log_ROWCOUNT ('Delete old records from sms.StatSmsLog')

		DELETE FROM @RecordUpdated

		UPDATE sl
		SET Cost = t.CostEUR, 
			CostEUR = t.CostEUR, 
			CostContract = t.CostContract,
			Price = t.PriceEUR,
			PriceEUR = t.PriceEUR,
			PriceContract = t.PriceContract,
			SmsCountTotal = t.SmsCountTotal, 
			SmsCountDelivered = t.SmsCountDelivered, 
			SmsCountUndelivered = t.SmsCountUndelivered, 
			SmsCountRejected = t.SmsCountRejected, 
			SmsCountProcessingWavecell = t.SmsCountProcessingWavecell, 
			SmsCountProcessingSupplier = t.SmsCountProcessingSupplier,
			SmsCountConverted = t.SmsCountConverted,
			MsgCountTotal = t.MsgCountTotal, 
			MsgCountDelivered = t.MsgCountDelivered, 
			MsgCountUndelivered = t.MsgCountUndelivered, 
			MsgCountRejected = t.MsgCountRejected, 
			MsgCountProcessingWavecell = t.MsgCountProcessingWavecell, 
			MsgCountProcessingSupplier = t.MsgCountProcessingSupplier,
			MsgCountConverted = t.MsgCountConverted,
			LastUpdatedAt = SYSUTCDATETIME()
		OUTPUT t.Id INTO @RecordUpdated (Id)
		FROM sms.StatSmsLog sl
			INNER JOIN #SmsLogStat t 
					ON		t.TimeFrom = sl.TimeFrom 
						AND t.TimeTill = sl.TimeTill 
						AND t.SubAccountUid = sl.SubAccountUid
						AND ISNULL(t.Country, '') = ISNULL(sl.Country, '')
						AND ISNULL(t.OperatorId, -1) = ISNULL(sl.OperatorId, -1)
						AND t.SmsTypeId = sl.SmsTypeId
						AND ISNULL(t.ConnUid, '') = ISNULL(sl.ConnUid, '')
						AND ISNULL(t.CostContractCurrency,'') = ISNULL(sl.CostContractCurrency, '')
						AND ISNULL(t.PriceContractCurrency,'') = ISNULL(sl.PriceContractCurrency, '')

		PRINT dbo.Log_ROWCOUNT ('Update existing records in sms.StatSmsLog')

		--DELETE FROM t FROM #SmsLogStat t INNER JOIN @RecordUpdated i ON t.Id = i.Id
		UPDATE t SET fRecordSynced = 1 FROM #SmsLogStat t INNER JOIN @RecordUpdated i ON t.Id = i.Id
		
		INSERT INTO sms.StatSmsLog (
			TimeFrom, TimeTill, 
			AccountUid, SubAccountUid, Country, OperatorId, 
			SmsTypeId, ConnUid, 
			CostCurrency, Cost, CostEUR, CostContractCurrency, CostContract, 
			PriceCurrency, Price, PriceEUR, PriceContractCurrency, PriceContract,
			SmsCountTotal, SmsCountDelivered, SmsCountUndelivered, SmsCountRejected, SmsCountProcessingWavecell, SmsCountProcessingSupplier, SmsCountConverted,
			MsgCountTotal, MsgCountDelivered, MsgCountUndelivered, MsgCountRejected, MsgCountProcessingWavecell, MsgCountProcessingSupplier, MsgCountConverted)
		SELECT 
			TimeFrom, TimeTill, 
			AccountUid, SubAccountUid, Country, OperatorId, 
			SmsTypeId, ConnUid, 
			'EUR', CostEUR, CostEUR, CostContractCurrency, CostContract, 
			'EUR', PriceEUR, PriceEUR, PriceContractCurrency, PriceContract,
			SmsCountTotal, SmsCountDelivered, SmsCountUndelivered, SmsCountRejected, SmsCountProcessingWavecell, SmsCountProcessingSupplier, SmsCountConverted,
			MsgCountTotal, MsgCountDelivered, MsgCountUndelivered, MsgCountRejected, MsgCountProcessingWavecell, MsgCountProcessingSupplier, MsgCountConverted
		FROM #SmsLogStat t 
		WHERE t.fRecordSynced = 0

		PRINT dbo.Log_ROWCOUNT ('Insert new records to sms.StatSmsLog')
		
		-- log modified traffic filters to update Daily table later
		INSERT INTO @SmsLogStatDailyToRecalc ([Date], SubAccountUid, Country, OperatorId, SmsTypeId, ConnUid)
		SELECT DISTINCT CAST(t.TimeFrom AS date) AS Date, SubAccountUid, Country, OperatorId, SmsTypeId, ConnUid
		FROM #SmsLogStat t

		-- log processed job to update status later
		INSERT INTO @JobsProcessed VALUES (@JobId)

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'JobId=' + CAST(@JobId AS varchar(10)) + ' updated sms.StatSmsLog in ' + CAST(DATEDIFF(millisecond, @TimeCounter, CURRENT_TIMESTAMP) as varchar(30)) + ' ms'

		FETCH NEXT FROM task_cursor
		INTO @JobId, @TimeframeStart, @TimeframeEnd, @SubAccountUid, @Country, @OperatorId
	END
	CLOSE task_cursor;
	DEALLOCATE task_cursor;

	PRINT dbo.CURRENT_TIMESTAMP_STR() + '*** Recalc of short intervals is finished. Starting daily table recalc ***'

	-- DEBUG
	--SELECT * FROM @SmsLogStatDailyToRecalc
	--SELECT DISTINCT Date, SubAccountUid, Country, OperatorId, SmsTypeId, ConnUid FROM @SmsLogStatDailyToRecalc
	--SELECT * FROM @JobsProcessed

	----------------------------
	-- Sync to Daily table
	----------------------------
	SET @TimeCounter = CURRENT_TIMESTAMP
	
	TRUNCATE TABLE #SmsLogStatDaily

	INSERT INTO #SmsLogStatDaily (
		[Date], 
		AccountUid, SubAccountUid, 
		Country, OperatorId, SmsTypeId, 
		ConnUid,
		CostContractCurrency, CostContract, CostEUR, 
		PriceContractCurrency, PriceContract, PriceEUR,  
		SmsCountTotal, 
		SmsCountDelivered, 
		SmsCountUndelivered, 
		SmsCountRejected, 
		SmsCountProcessingWavecell, 
		SmsCountProcessingSupplier,
		SmsCountConverted,
		MsgCountTotal, 
		MsgCountDelivered, 
		MsgCountUndelivered, 
		MsgCountRejected, 
		MsgCountProcessingWavecell, 
		MsgCountProcessingSupplier,
		MsgCountConverted)
	SELECT 
		-- filters
		CAST(sl.TimeFrom AS Date) AS [Date], 
		sl.AccountUid, sl.SubAccountUid, 
		sl.Country, sl.OperatorId, 
		sl.SmsTypeId, sl.ConnUid,
		-- cost
		sl.CostContractCurrency,
		SUM(sl.CostContract) AS CostContract, 
		SUM(ISNULL(sl.CostEUR, sl.Cost)) AS CostEUR, 
		-- price
		sl.PriceContractCurrency,
		SUM(sl.PriceContract) AS PriceContract, 
		SUM(ISNULL(sl.PriceEUR, sl.Price)) AS PriceEUR,
		-- volumes
		SUM(sl.SmsCountTotal) AS SmsCountTotal, 
		SUM(sl.SmsCountDelivered) AS SmsCountDelivered, 
		SUM(sl.SmsCountUndelivered) AS SmsCountUndelivered, 
		SUM(sl.SmsCountRejected) AS SmsCountRejected, 
		SUM(sl.SmsCountProcessingWavecell) AS SmsCountProcessingWavecell, 
		SUM(sl.SmsCountProcessingSupplier) AS SmsCountProcessingSupplier,
		SUM(sl.SmsCountConverted) AS SmsCountConverted,
		SUM(sl.MsgCountTotal) AS MsgCountTotal, 
		SUM(sl.MsgCountDelivered) AS MsgCountDelivered, 
		SUM(sl.MsgCountUndelivered) AS MsgCountUndelivered, 
		SUM(sl.MsgCountRejected) AS MsgCountRejected, 
		SUM(sl.MsgCountProcessingWavecell) AS MsgCountProcessingWavecell, 
		SUM(sl.MsgCountProcessingSupplier) AS MsgCountProcessingSupplier,
		SUM(sl.MsgCountConverted) AS MsgCountConverted
	FROM sms.StatSmsLog sl WITH (FORCESEEK)
		INNER JOIN (
			SELECT DISTINCT Date, SubAccountUid, Country, OperatorId
				--, SmsTypeId, ConnUid
			FROM @SmsLogStatDailyToRecalc
			-- NOTE: we can't go on more granular level, cause small 15mins windows of recalc can miss some SmsTypeId, ConnUid => this records will be deleted later by Daily table sync query
			-- NB: this filter must be in sync with filter within next DELETE operation
		) t	ON
			sl.TimeFrom >= t.Date
			AND sl.TimeFrom < DATEADD(DAY, 1, t.Date)
			--AND t.TimeTill > sl.TimeTill 
			AND t.SubAccountUid = sl.SubAccountUid
			AND ISNULL(t.Country, '') = ISNULL(sl.Country, '')
			AND ISNULL(t.OperatorId, -1) = ISNULL(sl.OperatorId, -1)
			--AND t.SmsTypeId = sl.SmsTypeId
			--AND ISNULL(t.ConnUid, -1) = ISNULL(sl.ConnUid, -1)
			--AND ISNULL(t.CostContractCurrency,'') = ISNULL(sl.CostContractCurrency,'')
			--AND ISNULL(t.PriceContractCurrency,'') = ISNULL(sl.PriceContractCurrency,'')
	GROUP BY 
		CAST(sl.TimeFrom AS Date), 
		sl.AccountUid, sl.SubAccountUid,
		sl.Country, sl.OperatorId, 
		sl.SmsTypeId, sl.ConnUid, 
		sl.CostContractCurrency, sl.PriceContractCurrency

	PRINT dbo.Log_ROWCOUNT ('Temp table #SmsLogStatDaily populated')

	--------------
	-- Apply changes to StatSmsLogDaily table
	--------------

	-- delete removed records 
	
	--troubleshooting
	--DECLARE @tmstmp datetime2(2) = SYSUTCDATETIME()
	--INSERT INTO [sms].[StatSmsLogDaily_tmp]
	--SELECT sl.*, @Tmstmp AS CreatedAt
	
	DELETE FROM sl 
	--select *
	FROM sms.StatSmsLogDaily sl WITH (FORCESEEK)
		INNER JOIN (
			-- filtering scope of changes, where full dataset exists
			SELECT DISTINCT Date, SubAccountUid, Country, OperatorId
			FROM #SmsLogStatDaily
		) fltr	ON
			fltr.Date = sl.Date
			AND fltr.SubAccountUid = sl.SubAccountUid
			AND ISNULL(fltr.Country, '') = ISNULL(sl.Country, '')
			AND ISNULL(fltr.OperatorId, -1) = ISNULL(sl.OperatorId, -1)
		LEFT JOIN #SmsLogStatDaily n 
				ON n.Date = sl.Date 
					AND n.SubAccountUid = sl.SubAccountUid
					AND ISNULL(n.Country, '') = ISNULL(sl.Country, '')
					AND ISNULL(n.OperatorId, -1) = ISNULL(sl.OperatorId, -1)
					AND n.SmsTypeId = sl.SmsTypeId
					AND ISNULL(n.ConnUid, -1) = ISNULL(sl.ConnUid, -1)
					AND ISNULL(n.CostContractCurrency,'') = ISNULL(sl.CostContractCurrency, '')
					AND ISNULL(n.PriceContractCurrency, '') = ISNULL(sl.PriceContractCurrency, '')
	WHERE n.Id IS NULL

	-- troubleshooting
	--IF @@RowCount > 0
	--BEGIN
	--	INSERT INTO sms.SmsLogStatDaily_dump (
	--		id, fRecordSynced, [Date], AccountUid, SubAccountUid, Country, OperatorId, 
	--		SmsTypeId, ConnUid, 
	--		CostEUR, CostContractCurrency, CostContract, 
	--		PriceEUR, PriceContractCurrency, PriceContract,
	--		SmsCountTotal, SmsCountDelivered, SmsCountUndelivered, SmsCountRejected, SmsCountProcessingWavecell, SmsCountProcessingSupplier,
	--		MsgCountTotal, MsgCountDelivered, MsgCountUndelivered, MsgCountRejected, MsgCountProcessingWavecell, MsgCountProcessingSupplier,
	--		CreatedAt)
	--	SELECT 
	--		id, fRecordSynced, [Date], AccountUid, SubAccountUid, Country, OperatorId, 
	--		SmsTypeId, ConnUid, 
	--		CostEUR, CostContractCurrency, CostContract, 
	--		PriceEUR, PriceContractCurrency, PriceContract,
	--		SmsCountTotal, SmsCountDelivered, SmsCountUndelivered, SmsCountRejected, SmsCountProcessingWavecell, SmsCountProcessingSupplier,
	--		MsgCountTotal, MsgCountDelivered, MsgCountUndelivered, MsgCountRejected, MsgCountProcessingWavecell, MsgCountProcessingSupplier,
	--		@tmstmp
	--	FROM #SmsLogStatDaily
	--END
	--PRINT dbo.Log_ROWCOUNT ('Delete old records from sms.StatSmsLogDaily')

	DELETE FROM @RecordUpdated

	UPDATE sl
	SET Cost = t.CostEUR, 
		CostEUR = t.CostEUR, 
		CostContract = t.CostContract,
		Price = t.PriceEUR,
		PriceEUR = t.PriceEUR,
		PriceContract = t.PriceContract,
		SmsCountTotal = t.SmsCountTotal, 
		SmsCountDelivered = t.SmsCountDelivered, 
		SmsCountUndelivered = t.SmsCountUndelivered, 
		SmsCountRejected = t.SmsCountRejected, 
		SmsCountProcessingWavecell = t.SmsCountProcessingWavecell, 
		SmsCountProcessingSupplier = t.SmsCountProcessingSupplier,
		SmsCountConverted = t.SmsCountConverted,
		MsgCountTotal = t.MsgCountTotal, 
		MsgCountDelivered = t.MsgCountDelivered, 
		MsgCountUndelivered = t.MsgCountUndelivered, 
		MsgCountRejected = t.MsgCountRejected, 
		MsgCountProcessingWavecell = t.MsgCountProcessingWavecell, 
		MsgCountProcessingSupplier = t.MsgCountProcessingSupplier,
		MsgCountConverted = t.MsgCountConverted,
		LastUpdatedAt = SYSUTCDATETIME()
	OUTPUT t.Id INTO @RecordUpdated (Id)
	FROM sms.StatSmsLogDaily sl WITH (FORCESEEK)
		INNER JOIN #SmsLogStatDaily t 
				ON t.[Date] = sl.[Date] 
					AND t.SubAccountUid = sl.SubAccountUid
					AND ISNULL(t.Country, '') = ISNULL(sl.Country, '')
					AND ISNULL(t.OperatorId, -1) = ISNULL(sl.OperatorId, -1)
					AND t.SmsTypeId = sl.SmsTypeId
					AND ISNULL(t.ConnUid, -1) = ISNULL(sl.ConnUid, -1)
					AND ISNULL(t.CostContractCurrency, '') = ISNULL(sl.CostContractCurrency, '')
					AND ISNULL(t.PriceContractCurrency, '') = ISNULL(sl.PriceContractCurrency, '')

	PRINT dbo.Log_ROWCOUNT ('Update existing records in sms.StatSmsLogDaily')

	UPDATE t SET fRecordSynced = 1 FROM #SmsLogStatDaily t INNER JOIN @RecordUpdated i ON t.Id = i.Id
		
	INSERT INTO sms.StatSmsLogDaily (
		[Date], AccountUid, SubAccountUid, Country, OperatorId, 
		SmsTypeId, ConnUid, 
		CostCurrency, Cost, CostEUR, CostContractCurrency, CostContract, 
		PriceCurrency, Price, PriceEUR, PriceContractCurrency, PriceContract,
		SmsCountTotal, SmsCountDelivered, SmsCountUndelivered, SmsCountRejected, SmsCountProcessingWavecell, SmsCountProcessingSupplier, SmsCountConverted,
		MsgCountTotal, MsgCountDelivered, MsgCountUndelivered, MsgCountRejected, MsgCountProcessingWavecell, MsgCountProcessingSupplier, MsgCountConverted)
	SELECT 
		[Date], AccountUid, SubAccountUid, Country, OperatorId, 
		SmsTypeId, ConnUid, 
		'EUR', CostEUR, CostEUR, CostContractCurrency, CostContract, 
		'EUR', PriceEUR, PriceEUR, PriceContractCurrency, PriceContract,
		SmsCountTotal, SmsCountDelivered, SmsCountUndelivered, SmsCountRejected, SmsCountProcessingWavecell, SmsCountProcessingSupplier, SmsCountConverted,
		MsgCountTotal, MsgCountDelivered, MsgCountUndelivered, MsgCountRejected, MsgCountProcessingWavecell, MsgCountProcessingSupplier, MsgCountConverted
	FROM #SmsLogStatDaily t 
	WHERE t.fRecordSynced = 0

	PRINT dbo.Log_ROWCOUNT ('Insert new records to sms.StatSmsLogDaily')

	-----------------------------
	-- Mark tasks batch as completed  --
	-----------------------------
	UPDATE j SET CompletedAt = SYSUTCDATETIME() FROM sms.JobCalculate j JOIN @JobsProcessed t ON j.JobId = t.JobId

	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Task duration for sms.StatSmsLogDaily update = ' + CAST(DATEDIFF(millisecond, @TimeCounter, CURRENT_TIMESTAMP) as varchar(30)) + ' ms'

END
