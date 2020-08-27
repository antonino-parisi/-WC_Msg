

-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-09-18
-- =============================================
-- EXEC sms.job_SmsLog_CheckStats
-- INSERT INTO sms.JobCalculate (TimeframeStart, TimeframeEnd, SubAccountUid, Country, OperatorId) VALUES ('2017-11-14', '2017-11-15', 1931, 'ID', 510001)
CREATE PROCEDURE [sms].[job_SmsLog_CheckStats]
AS
BEGIN

	DECLARE @msg NVARCHAR(2048)
		
	/*********************/
	/*** Validation #1 ***/
	/*********************/
	
	DECLARE @LastRecordValue smalldatetime
	SELECT @LastRecordValue = MAX(sl.TimeFrom) FROM sms.StatSmsLog sl (NOLOCK)
	IF (@LastRecordValue < DATEADD(MINUTE, -30, SYSUTCDATETIME()))
	BEGIN
		SET @msg = 'sms.StatSmsLog has significant delays in update: last TimeFrom = ' + CAST(@LastRecordValue as varchar(20)) + ' GMT';
		THROW 51000, @msg, 1;
	END

	/*********************/
	/*** Validation #2 ***/
	/*********************/
	
	DECLARE @TimeframeStart smalldatetime, @TimeframeEnd smalldatetime
	SET @TimeframeStart = CAST(DATEADD(DAY, -5, SYSUTCDATETIME()) as date)
	SET @TimeframeEnd = CAST(DATEADD(DAY, 1, SYSUTCDATETIME()) as date)

	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'PERIOD: ' + CONVERT(varchar(50), @TimeframeStart, 20) + ' - ' + CONVERT(varchar(50), @TimeframeEnd, 20)
	
	IF OBJECT_ID('tempdb..#SmsLogStatDailyCheck') IS NOT NULL DROP TABLE #SmsLogStatDailyCheck
	CREATE TABLE #SmsLogStatDailyCheck (
		Id int IDENTITY (1,1) PRIMARY KEY,
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
		CostEUR decimal(18,6) NOT NULL,
		PriceEUR decimal(18,6) NOT NULL,
		CostContract decimal(18,6) NULL,
		PriceContract decimal(18,6) NULL,
		SmsCountTotal int NOT NULL,
		SmsCountDelivered int NOT NULL,
		SmsCountUndelivered int NOT NULL,
		SmsCountRejected int NOT NULL,
		SmsCountProcessingWavecell int NOT NULL,
		SmsCountProcessingSupplier int NOT NULL,
		MsgCountTotal int NOT NULL,
		MsgCountDelivered int NOT NULL,
		MsgCountUndelivered int NOT NULL,
		MsgCountRejected int NOT NULL,
		MsgCountProcessingWavecell int NOT NULL,
		MsgCountProcessingSupplier int NOT NULL
	)

	INSERT INTO #SmsLogStatDailyCheck ([Date], AccountUid, SubAccountUid, 
		Country, OperatorId, SmsTypeId, ConnUid, 
		CostContractCurrency, PriceContractCurrency,
		CostEUR, PriceEUR,
		CostContract, PriceContract,
		SmsCountTotal, 
		SmsCountDelivered, 
		SmsCountUndelivered, 
		SmsCountRejected, 
		SmsCountProcessingWavecell, 
		SmsCountProcessingSupplier,
		MsgCountTotal, 
		MsgCountDelivered, 
		MsgCountUndelivered, 
		MsgCountRejected, 
		MsgCountProcessingWavecell, 
		MsgCountProcessingSupplier)
	SELECT CAST(sl.TimeFrom AS Date) AS [Date], sl.AccountUid, sl.SubAccountUid, 
		sl.Country, sl.OperatorId, sl.SmsTypeId, sl.ConnUid, 
		sl.CostContractCurrency, sl.PriceContractCurrency,
		SUM(sl.CostEUR) AS CostEUR, 
		SUM(sl.PriceEUR) AS PriceEUR, 
		SUM(sl.CostContract) AS CostContract,
		SUM(sl.PriceContract) AS PriceContract,
		SUM(sl.SmsCountTotal) AS SmsCountTotal, 
		SUM(sl.SmsCountDelivered) AS SmsCountDelivered, 
		SUM(sl.SmsCountUndelivered) AS SmsCountUndelivered, 
		SUM(sl.SmsCountRejected) AS SmsCountRejected, 
		SUM(sl.SmsCountProcessingWavecell) AS SmsCountProcessingWavecell, 
		SUM(sl.SmsCountProcessingSupplier) AS SmsCountProcessingSupplier,
		SUM(sl.MsgCountTotal) AS MsgCountTotal, 
		SUM(sl.MsgCountDelivered) AS MsgCountDelivered, 
		SUM(sl.MsgCountUndelivered) AS MsgCountUndelivered, 
		SUM(sl.MsgCountRejected) AS MsgCountRejected, 
		SUM(sl.MsgCountProcessingWavecell) AS MsgCountProcessingWavecell, 
		SUM(sl.MsgCountProcessingSupplier) AS MsgCountProcessingSupplier
	FROM sms.StatSmsLog sl
	WHERE sl.TimeFrom >= @TimeframeStart AND sl.TimeFrom < @TimeframeEnd
	GROUP BY CAST(sl.TimeFrom AS Date), sl.AccountUid, sl.SubAccountUid, 
		sl.Country, sl.OperatorId, sl.SmsTypeId, sl.ConnUid, 
		sl.CostContractCurrency, sl.PriceContractCurrency

	--debug
	--SELECT * FROM #SmsLogStatDailyCheck WHERE SubAccountUid = 1707

	DECLARE @DiffCount int
	SELECT @DiffCount = COUNT(*)
	--SELECT *
	FROM sms.StatSmsLogDaily t1
		RIGHT JOIN #SmsLogStatDailyCheck t2
			ON t1.[Date] = t2.[Date] 
				AND t1.SubAccountUid = t2.SubAccountUid
				AND ISNULL(t1.Country, '') = ISNULL(t2.Country, '')
				AND ISNULL(t1.OperatorId, '') = ISNULL(t2.OperatorId, '')
				AND t1.SmsTypeId = t2.SmsTypeId
				AND ISNULL(t1.ConnUid, '') = ISNULL(t2.ConnUid, '')
				AND ISNULL(t1.CostContractCurrency, '') = ISNULL(t2.CostContractCurrency, '')
				AND ISNULL(t1.PriceContractCurrency, '') = ISNULL(t2.PriceContractCurrency, '')
				AND t1.Date >= @TimeframeStart AND t1.Date <= @TimeframeEnd
	WHERE (
			t1.StatEntryId IS NULL 
			OR t2.id IS NULL
			OR t1.SmsCountTotal <> t2.SmsCountTotal 
			OR t1.SmsCountDelivered <> t2.SmsCountDelivered
			OR t1.CostEUR <> t2.CostEUR
			OR t1.PriceEUR <> t2.PriceEUR
		)

	IF @DiffCount > 0
	BEGIN
		SET @msg = 'Sync errors between sms.StatSmsLogDaily AND sms.StatSmsLog: ' + CAST(@DiffCount as varchar(10));
		THROW 51001, @msg, 1;
	END


	/*********************/
	/*** Validation #3 ***/
	/*********************/

	-- Removed: cause it can't work correctly when 1 SMS contains 2+ urls with different UrlBaseId.
	-- [sms].[vwStatUrlShorten].SUM(MsgTotal) is multiplied in that case. Due to initial grouping of MsgTotal by UrlBaseId
	/*
	SELECT @DiffCount = COUNT(*)
	--SELECT cast(u.MsgTotal as real) / s.MsgTotal AS Ratio, *
	FROM (
		SELECT 
			SubAccountId, SubAccountUid, Date, 
			SUM(MsgTotal) AS MsgTotal, 
			SUM(UrlCreated) AS UrlCreated, 
			SUM(UrlClicked) AS UrlClicked
		FROM [sms].[vwStatUrlShorten] s
		WHERE Date >= CAST(GETUTCDATE()-2 AS date)
		GROUP BY SubAccountId, SubAccountUid, Date
	) u LEFT JOIN (
		SELECT SubAccountUid, Date, SUM(MsgCountTotal) AS MsgTotal
		FROM [sms].[vwStatSmsLogDaily] s
		WHERE Date >= CAST(GETUTCDATE()-2 AS date)
		GROUP BY SubAccountUid, Date
	) s ON u.Date = s.Date AND u.SubAccountUid = s.SubAccountUid
	WHERE cast(u.MsgTotal as real) / s.MsgTotal > 1.2 OR s.Date IS NULL
	--ORDER BY u.Date, u.SubAccountId

	IF @DiffCount > 0
	BEGIN
		--hot fix - new jobs to recalc
		INSERT INTO sms.JobCalculate (TimeframeStart, TimeframeEnd, SubAccountUid)
		SELECT DISTINCT u.TimeFrom, dateadd(hh,1,u.timefrom), u.SubAccountUid
		--SELECT cast(u.MsgTotal as real) / s.MsgTotal AS Ratio, *
		FROM (
			SELECT 
				SubAccountId, SubAccountUid, TimeFrom, 
				SUM(MsgTotal) AS MsgTotal, 
				SUM(UrlCreated) AS UrlCreated, 
				SUM(UrlClicked) AS UrlClicked
			FROM [sms].[vwStatUrlShorten] s
			WHERE Date >= CAST(GETUTCDATE()-4 AS date)
			GROUP BY SubAccountId, SubAccountUid, TimeFrom
		) u LEFT JOIN (
			SELECT 
				SubAccountUid, 
				dbo.fnTimeRountdown(TimeFrom, 60) AS TimeFrom, 
				SUM(MsgCountTotal) AS MsgTotal
			FROM [MessageSphere].[sms].[vwStatSmsLog] s
			WHERE Date >= CAST(GETUTCDATE()-4 AS date)
			GROUP BY SubAccountUid, dbo.fnTimeRountdown(TimeFrom, 60)
		) s ON u.TimeFrom = s.TimeFrom AND u.SubAccountUid = s.SubAccountUid
		WHERE cast(u.MsgTotal as real) / s.MsgTotal > 1.1 or s.SubAccountUid IS NULL

		SET @msg = 'Bug in sms.StatUrlShorten volumes';
		THROW 51002, @msg, 1;
	END
	*/
END
