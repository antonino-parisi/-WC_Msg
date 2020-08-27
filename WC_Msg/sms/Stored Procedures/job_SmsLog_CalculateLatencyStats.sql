-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2019-01-16
-- Description: Calculate the latency of sms delivery grouped by
--              15-min interval, country, operator, route, priority
--              If no start_date is given, it will default to the max date in database + 15 min
--              If no end_date is given, it will default to 24 hrs ago round to nearest 15-min interval
-- =============================================
-- EXEC sms.job_SmsLog_CalculateLatencyStats
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 02/04/2019  Rebecca  Added latency bands
-- 02/08/2019  Rebecca  Added ISNULL to ConnUid & OperatorId

CREATE PROCEDURE [sms].[job_SmsLog_CalculateLatencyStats]
	@start_date DATETIME = NULL,
	@end_date DATETIME = NULL
AS
BEGIN
	DECLARE @dt DATETIME ;
	DECLARE @MinBatchSize INT = 100 ;

	CREATE TABLE #qc
		(SubAccountUid INT,
		[Priority] TINYINT) ;

	INSERT INTO #qc
	SELECT SubAccountUid, [Priority]
	FROM ms.QueueConfig B WITH (NOLOCK)
		WHERE QueueRole = 'MT'
		AND (SubAccountUid IS NOT NULL
			OR (SubAccountUid IS NULL
				AND ClusterGroupId_Consumer = 'ANY'
				AND ClusterGroupId_Publish = 'ANY')
			) ;

	CREATE TABLE #tmpLatency
		(Country CHAR(2),
		OperatorId INT,
		ConnUid SMALLINT,
		[Priority] TINYINT,
		SubAccountUid INT,
		SegmentsReceived TINYINT,
		SegmentsDelivered TINYINT,
		L3_Latency_ms BIGINT,
		L4_Latency_ms BIGINT) ;

	--Create a temp table with exact structure as final table
	SELECT * INTO #StatSmsLatency FROM sms.StatSmsLatency WHERE 1 = 2;
	ALTER TABLE #StatSmsLatency DROP COLUMN StatEntryId ;

	-- If start_date is null, get the 15 min based on nearest 0, 15, 30, 45 min of the clock
	--SELECT @dt = ISNULL(@start_date, dbo.fnTimeRoundDown(DATEADD(minute, -5, dbo.fnTimeRoundDown(GETUTCDATE(), 15)), 15)) ;
	--SELECT @end_date = ISNULL(@end_date, DATEADD(minute, 15, @dt)) ;
	SELECT @dt = ISNULL(@start_date, DATEADD(mi, 15, MAX(TimeFrom))) FROM sms.StatSmsLatency WITH (NOLOCK) ;
	SELECT @end_date = ISNULL(@end_date, dbo.fnTimeRoundDown(DATEADD(minute, -15, GETUTCDATE()), 15)) ;

	WHILE @dt < @end_date
	BEGIN
		PRINT @dt ;

		--Get raw data into temp table
		INSERT INTO #tmpLatency
		SELECT A.Country, A.OperatorId, A.ConnUid,
				ISNULL(B.Priority, C.Priority) [Priority], A.SubAccountUid,
				A.SegmentsReceived, A.SegmentsDelivered,
				L3_Latency_ms=CASE WHEN A.L3_Latency_ms>=0 THEN A.L3_Latency_ms ELSE 0 END,
				L4_Latency_ms=CASE WHEN A.L4_Latency_ms>=0 THEN A.L4_Latency_ms ELSE 0 END
		FROM
			(SELECT sl.SubAccountUid, sl.ConnUid, sl.Country,
				sl.OperatorId, sl.SegmentsReceived,	sl.SegmentsDelivered, 
				L3_Latency_ms=DATEDIFF(ms, sl.CreatedTime, ISNULL(dl3.EventTime, GETUTCDATE())),
				L4_Latency_ms=DATEDIFF(ms, sl.CreatedTime, ISNULL(dl4.EventTime, GETUTCDATE()))
			FROM
				(SELECT UMID, SubAccountUid, ConnUid, Country, OperatorId, SegmentsReceived, CreatedTime,
						SegmentsDelivered=CASE WHEN StatusId = 40 THEN SegmentsReceived ELSE 0 END
				FROM sms.SmsLog sl  WITH (NOLOCK, INDEX(IX_SmsLog_CreatedTime))
				WHERE CreatedTime >= @dt
					AND CreatedTime < DATEADD(minute, 15, @dt)
					AND StatusId >= 40
					AND SmsTypeId <> 0
				) sl
				LEFT JOIN sms.DlrLog dl3 WITH (NOLOCK, INDEX(IX_DlrLog_UMID_StatusId), FORCESEEK)
					ON sl.UMID = dl3.UMID AND (dl3.StatusId = 30 OR dl3.StatusId = 31)
				LEFT JOIN sms.DlrLog dl4 WITH (NOLOCK, INDEX(IX_DlrLog_UMID_StatusId), FORCESEEK)
					ON sl.UMID = dl4.UMID AND (dl4.StatusId = 40 OR dl4.StatusId = 41)
			) A
			LEFT JOIN #qc B
				ON A.SubAccountUid = B.SubAccountUid
			LEFT JOIN #qc C
				ON B.SubAccountUid IS NULL AND C.SubAccountUid IS NULL ;

		--insert all the columns which do not need grouping or can use grouping
		--insert data grouped with SubAccountUid first
		INSERT INTO #StatSmsLatency
			(TimeFrom, Country,	OperatorId,	ConnUid, [Priority], SubAccountUid,
			MsgCountTotal, MsgCountDelivered, SmsCountTotal, SmsCountDelivered,
			L3_Min_Latency_sec,	L3_Max_Latency_sec,	L3_Avg_Latency_sec,
			L4_Min_Latency_sec,	L4_Max_Latency_sec,	L4_Avg_Latency_sec,
			LE2, GT2LE5, GT5LE10, GT10LE20, GT20LE30, GT30,
			LastUpdatedAt)
		SELECT @dt, Country, OperatorId, ConnUid, [Priority], SubAccountUid,
			COUNT(1), SUM(CASE WHEN SegmentsDelivered > 0 THEN 1 ELSE 0 END),
			SUM(SegmentsReceived), SUM(SegmentsDelivered),
			MIN(L3_Latency_ms)/1000, MAX(L3_Latency_ms)/1000, AVG(CAST(L3_Latency_ms AS BIGINT))/1000,
			MIN(L4_Latency_ms)/1000, MAX(L4_Latency_ms)/1000, AVG(CAST(L4_Latency_ms AS BIGINT))/1000,
			SUM(CASE WHEN L4_Latency_ms <= 2000 THEN 1 ELSE 0 END),
			SUM(CASE WHEN L4_Latency_ms > 2000 AND L4_Latency_ms <= 5000 THEN 1 ELSE 0 END),
			SUM(CASE WHEN L4_Latency_ms > 5000 AND L4_Latency_ms <= 10000 THEN 1 ELSE 0 END),
			SUM(CASE WHEN L4_Latency_ms > 10000 AND L4_Latency_ms <= 20000 THEN 1 ELSE 0 END),
			SUM(CASE WHEN L4_Latency_ms > 20000 AND L4_Latency_ms <= 30000 THEN 1 ELSE 0 END),
			SUM(CASE WHEN L4_Latency_ms > 30000 THEN 1 ELSE 0 END),
			GETUTCDATE()
		FROM #tmpLatency
		GROUP BY Country, OperatorId, ConnUid, [Priority], SubAccountUid
		HAVING COUNT(1) >= @MinBatchSize ;

		EXEC dbo.Print_RowCount @msg='Insert #StatSmsLatency grouped by SubAccountUid', @procid=@@PROCID ;

		--insert data without grouped by SubAccountUid
		INSERT INTO #StatSmsLatency
			(TimeFrom, Country,	OperatorId,	ConnUid, [Priority], SubAccountUid,
			MsgCountTotal, MsgCountDelivered, SmsCountTotal, SmsCountDelivered,
			L3_Min_Latency_sec,	L3_Max_Latency_sec,	L3_Avg_Latency_sec,
			L4_Min_Latency_sec,	L4_Max_Latency_sec,	L4_Avg_Latency_sec,
			LE2, GT2LE5, GT5LE10, GT10LE20, GT20LE30, GT30,
			LastUpdatedAt)
		SELECT @dt, Country, OperatorId, ConnUid, [Priority], NULL,
			COUNT(1), SUM(CASE WHEN SegmentsDelivered > 0 THEN 1 ELSE 0 END),
			SUM(SegmentsReceived), SUM(SegmentsDelivered),
			MIN(L3_Latency_ms)/1000, MAX(L3_Latency_ms)/1000, AVG(CAST(L3_Latency_ms AS BIGINT))/1000,
			MIN(L4_Latency_ms)/1000, MAX(L4_Latency_ms)/1000, AVG(CAST(L4_Latency_ms AS BIGINT))/1000,
			SUM(CASE WHEN L4_Latency_ms <= 2000 THEN 1 ELSE 0 END),
			SUM(CASE WHEN L4_Latency_ms > 2000 AND L4_Latency_ms <= 5000 THEN 1 ELSE 0 END),
			SUM(CASE WHEN L4_Latency_ms > 5000 AND L4_Latency_ms <= 10000 THEN 1 ELSE 0 END),
			SUM(CASE WHEN L4_Latency_ms > 10000 AND L4_Latency_ms <= 20000 THEN 1 ELSE 0 END),
			SUM(CASE WHEN L4_Latency_ms > 20000 AND L4_Latency_ms <= 30000 THEN 1 ELSE 0 END),
			SUM(CASE WHEN L4_Latency_ms > 30000 THEN 1 ELSE 0 END),			
			GETUTCDATE()
		FROM #tmpLatency
		GROUP BY Country, OperatorId, ConnUid, [Priority]
		HAVING COUNT(1) >= @MinBatchSize ;

		EXEC dbo.Print_RowCount @msg='Insert #StatSmsLatency without grouped by SubAcountUid', @procid=@@PROCID ;

		--update rows inserted above (grouped with SubAccountUid) with percentiles
		UPDATE A
			SET L3_Q10_Latency_sec = B.L3_Q10_Latency_sec/1000,
				L3_Q20_Latency_sec = B.L3_Q20_Latency_sec/1000,
				L3_Q30_Latency_sec = B.L3_Q30_Latency_sec/1000,
				L3_Q40_Latency_sec = B.L3_Q40_Latency_sec/1000,
				L3_Q50_Latency_sec = B.L3_Q50_Latency_sec/1000,
				L3_Q60_Latency_sec = B.L3_Q60_Latency_sec/1000,
				L3_Q70_Latency_sec = B.L3_Q70_Latency_sec/1000,
				L3_Q80_Latency_sec = B.L3_Q80_Latency_sec/1000,
				L3_Q90_Latency_sec = B.L3_Q90_Latency_sec/1000,
				L4_Q10_Latency_sec = B.L4_Q10_Latency_sec/1000,
				L4_Q20_Latency_sec = B.L4_Q20_Latency_sec/1000,
				L4_Q30_Latency_sec = B.L4_Q30_Latency_sec/1000,
				L4_Q40_Latency_sec = B.L4_Q40_Latency_sec/1000,
				L4_Q50_Latency_sec = B.L4_Q50_Latency_sec/1000,
				L4_Q60_Latency_sec = B.L4_Q60_Latency_sec/1000,
				L4_Q70_Latency_sec = B.L4_Q70_Latency_sec/1000,
				L4_Q80_Latency_sec = B.L4_Q80_Latency_sec/1000,
				L4_Q90_Latency_sec = B.L4_Q90_Latency_sec/1000
		FROM #StatSmsLatency A JOIN
			(SELECT DISTINCT Country, OperatorId, ConnUid, [Priority], SubAccountUid,
				L3_Q10_Latency_sec=PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L3_Q20_Latency_sec=PERCENTILE_CONT(0.2) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L3_Q30_Latency_sec=PERCENTILE_CONT(0.3) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L3_Q40_Latency_sec=PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L3_Q50_Latency_sec=PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L3_Q60_Latency_sec=PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L3_Q70_Latency_sec=PERCENTILE_CONT(0.7) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L3_Q80_Latency_sec=PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L3_Q90_Latency_sec=PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L4_Q10_Latency_sec=PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L4_Q20_Latency_sec=PERCENTILE_CONT(0.2) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L4_Q30_Latency_sec=PERCENTILE_CONT(0.3) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L4_Q40_Latency_sec=PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L4_Q50_Latency_sec=PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L4_Q60_Latency_sec=PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L4_Q70_Latency_sec=PERCENTILE_CONT(0.7) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L4_Q80_Latency_sec=PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid),
				L4_Q90_Latency_sec=PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority], SubAccountUid)
			FROM #tmpLatency
			) B
			ON A.SubAccountUid IS NOT NULL
				AND A.Country = B.Country
				AND ISNULL(A.OperatorId, 0) = ISNULL(B.OperatorId, 0)
				AND ISNULL(A.ConnUid, 0) = ISNULL(B.ConnUid, 0)
				AND A.[Priority] = B.[Priority]
				AND A.SubAccountUid=B.SubAccountUid ;

		EXEC dbo.Print_RowCount @msg='Update #StatSmsLatency (group by SubAccountUid)', @procid=@@PROCID ;

		--update rows inserted above (without group by SubAccountUid) with percentiles
		UPDATE A
			SET L3_Q10_Latency_sec = B.L3_Q10_Latency_sec/1000,
				L3_Q20_Latency_sec = B.L3_Q20_Latency_sec/1000,
				L3_Q30_Latency_sec = B.L3_Q30_Latency_sec/1000,
				L3_Q40_Latency_sec = B.L3_Q40_Latency_sec/1000,
				L3_Q50_Latency_sec = B.L3_Q50_Latency_sec/1000,
				L3_Q60_Latency_sec = B.L3_Q60_Latency_sec/1000,
				L3_Q70_Latency_sec = B.L3_Q70_Latency_sec/1000,
				L3_Q80_Latency_sec = B.L3_Q80_Latency_sec/1000,
				L3_Q90_Latency_sec = B.L3_Q90_Latency_sec/1000,
				L4_Q10_Latency_sec = B.L4_Q10_Latency_sec/1000,
				L4_Q20_Latency_sec = B.L4_Q20_Latency_sec/1000,
				L4_Q30_Latency_sec = B.L4_Q30_Latency_sec/1000,
				L4_Q40_Latency_sec = B.L4_Q40_Latency_sec/1000,
				L4_Q50_Latency_sec = B.L4_Q50_Latency_sec/1000,
				L4_Q60_Latency_sec = B.L4_Q60_Latency_sec/1000,
				L4_Q70_Latency_sec = B.L4_Q70_Latency_sec/1000,
				L4_Q80_Latency_sec = B.L4_Q80_Latency_sec/1000,
				L4_Q90_Latency_sec = B.L4_Q90_Latency_sec/1000
		FROM #StatSmsLatency A JOIN
			(SELECT DISTINCT Country, OperatorId, ConnUid, [Priority],
				L3_Q10_Latency_sec=PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L3_Q20_Latency_sec=PERCENTILE_CONT(0.2) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L3_Q30_Latency_sec=PERCENTILE_CONT(0.3) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L3_Q40_Latency_sec=PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L3_Q50_Latency_sec=PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L3_Q60_Latency_sec=PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L3_Q70_Latency_sec=PERCENTILE_CONT(0.7) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L3_Q80_Latency_sec=PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L3_Q90_Latency_sec=PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY L3_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L4_Q10_Latency_sec=PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L4_Q20_Latency_sec=PERCENTILE_CONT(0.2) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L4_Q30_Latency_sec=PERCENTILE_CONT(0.3) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L4_Q40_Latency_sec=PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L4_Q50_Latency_sec=PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L4_Q60_Latency_sec=PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L4_Q70_Latency_sec=PERCENTILE_CONT(0.7) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L4_Q80_Latency_sec=PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority]),
				L4_Q90_Latency_sec=PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY L4_Latency_ms) OVER (PARTITION BY Country, OperatorId, ConnUid, [Priority])
			FROM #tmpLatency
			) B
			ON A.SubAccountUid IS NULL
				AND A.Country = B.Country
				AND ISNULL(A.OperatorId, 0) = ISNULL(B.OperatorId, 0)
				AND ISNULL(A.ConnUid, 0) = ISNULL(B.ConnUid, 0)
				AND A.[Priority] = B.[Priority] ;

		EXEC dbo.Print_RowCount @msg='Update #StatSmsLatency (without group by SubAccountUid)', @procid=@@PROCID ;

		UPDATE A
		SET MsgCountTotal = B.MsgCountTotal,
			MsgCountDelivered = B.MsgcountDelivered,
			SmsCountTotal = B.SmsCountTotal,
			SmsCountDelivered = B.SmsCountDelivered,
			L3_Min_Latency_sec = B.L3_Min_Latency_sec,
			L3_Max_Latency_sec = B.L3_Max_Latency_sec,
			L3_Avg_Latency_sec = B.L3_Avg_Latency_sec,
			L3_Q10_Latency_sec = B.L3_Q10_Latency_sec,
			L3_Q20_Latency_sec = B.L3_Q20_Latency_sec,
			L3_Q30_Latency_sec = B.L3_Q30_Latency_sec,
			L3_Q40_Latency_sec = B.L3_Q40_Latency_sec,
			L3_Q50_Latency_sec = B.L3_Q50_Latency_sec,
			L3_Q60_Latency_sec = B.L3_Q60_Latency_sec,
			L3_Q70_Latency_sec = B.L3_Q70_Latency_sec,
			L3_Q80_Latency_sec = B.L3_Q80_Latency_sec,
			L3_Q90_Latency_sec = B.L3_Q90_Latency_sec,
			L4_Min_Latency_sec = B.L4_Min_Latency_sec,
			L4_Max_Latency_sec = B.L4_Max_Latency_sec,
			L4_Avg_Latency_sec = B.L4_Avg_Latency_sec,
			L4_Q10_Latency_sec = B.L4_Q10_Latency_sec,
			L4_Q20_Latency_sec = B.L4_Q20_Latency_sec,
			L4_Q30_Latency_sec = B.L4_Q30_Latency_sec,
			L4_Q40_Latency_sec = B.L4_Q40_Latency_sec,
			L4_Q50_Latency_sec = B.L4_Q50_Latency_sec,
			L4_Q60_Latency_sec = B.L4_Q60_Latency_sec,
			L4_Q70_Latency_sec = B.L4_Q70_Latency_sec,
			L4_Q80_Latency_sec = B.L4_Q80_Latency_sec,
			L4_Q90_Latency_sec = B.L4_Q90_Latency_sec,
			LE2 = B.LE2,
			GT2LE5 = B.GT2LE5,
			GT5LE10 = B.GT5LE10,
			GT10LE20 = B.GT10LE20,
			GT20LE30 = B.GT20LE30,
			GT30 = B.GT30,
			LastUpdatedAt = GETUTCDATE()
		FROM sms.StatSmsLatency A JOIN #StatSmsLatency B
			ON A.TimeFrom = B.TimeFrom
			AND ISNULL(A.Country, '') = ISNULL(B.Country, '')
			AND ISNULL(A.OperatorId, 0) = ISNULL(B.OperatorId, 0)
			AND ISNULL(A.ConnUid, 0) = ISNULL(B.ConnUid, 0)
			AND ISNULL(A.[Priority], 0) = ISNULL(B.[Priority], 0)
			AND ISNULL(A.SubAccountUid, 0) = ISNULL(B.SubAccountUid, 0);

		EXEC dbo.Print_RowCount @msg='Update sms.StatSmsLatency ', @procid=@@PROCID ;

		INSERT INTO sms.StatSmsLatency
		SELECT * FROM #StatSmsLatency A
		WHERE NOT EXISTS (SELECT 1 FROM sms.StatSmsLatency
							WHERE TimeFrom = A.TimeFrom
								AND ISNULL(Country, '') = ISNULL(A.Country, '')
								AND ISNULL(OperatorId, 0) = ISNULL(A.OperatorId, 0)
								AND ISNULL(ConnUid, 0) = ISNULL(A.ConnUid, 0)
								AND ISNULL([Priority], 0) = ISNULL(A.[Priority], 0)
								AND ISNULL(SubAccountUid, 0) = ISNULL(A.SubAccountUid, 0)) ;

		EXEC dbo.Print_RowCount @msg='Insert sms.StatSmsLatency', @procid=@@PROCID ;

		SET @dt = DATEADD(minute, 15, @dt) ;
		TRUNCATE TABLE #tmpLatency ;
		TRUNCATE TABLE #StatSmsLatency ;
		--BREAK ;
	END ; -- while loop

END ;