-- =============================================
-- Author:		Rebecca
-- Create date: 2019-09-11
-- Usage : 
--	EXEC cp.ChatApps_ReportStatistics @SubAccountUid = 6716, @FromDate='2019-10-01', @ToDate='2019-10-22'
--	EXEC cp.ChatApps_ReportStatistics @SubAccountUid = 6716, @FromDate='2019-10-01', @ToDate='2019-10-22', @ChannelId='SM'
-- ============================================
CREATE PROCEDURE [cp].[ChatApps_ReportStatistics]
	@SubAccountUid int,
	@ChannelId VARCHAR(50) = NULL,
	@FromDate smalldatetime,
	@ToDate smalldatetime
AS
BEGIN
	--DECLARE @Date_Tab TABLE (DT smalldatetime) ;
	DECLARE @Dt smalldatetime, @GroupByDay bit = 1 ;
	--DECLARE @HoursInterval smallint = 0 ;
	DECLARE @ChannelTypeId tinyint ;
	DECLARE @Tab1 TABLE (DT smalldatetime, ChannelTypeId tinyint, Outgoing int, Incoming int) ;
	DECLARE @Tab2 TABLE (DT smalldatetime, Delivered int, Undelivered int, [Read] int, Outgoing int,
						  Incoming int, [Free] int, Chargeable int, Currency char(3), Fee decimal(18,2)) ;

	IF @ChannelId IS NOT NULL
		BEGIN
			SELECT @ChannelTypeId = ChannelTypeId FROM ipm.ChannelType WITH (NOLOCK)
			WHERE ChannelType = @ChannelId ;

			IF @ChannelTypeId IS NULL -- ChannelId not found
				RETURN ;
		END ;

	--IF @PrevDays IS NOT NULL
	--	BEGIN
	--		SET @FromDate = DATEADD(hour, -@UTCOffSet, CAST(DATEADD(dd, -@PrevDays+1, CAST(DATEADD(hour, @UTCOffSet, GETUTCDATE()) AS date)) AS datetime)) ;
	--		SET @ToDate = DATEADD(hour, -@UTCOffSet, CAST(DATEADD(dd, 1, CAST(DATEADD(hour, @UTCOffSet, GETUTCDATE()) AS date)) AS datetime)) ;
	--	END
	--ELSE -- assume @FromDate & @ToDate given
	--	BEGIN --if no date given, assume today in local time
	--		SET @FromDate = DATEADD(hour, -@UTCOffSet, CAST(ISNULL(@FromDate, CAST(DATEADD(hour, @UTCOffSet, GETUTCDATE()) AS date)) AS datetime)) ;
	--		SET @ToDate = DATEADD(hour, -@UTCOffSet, ISNULL(DATEADD(dd, 1, @ToDate), DATEADD(hour, 24, @FromDate))) ;
	--		SET @HoursInterval = DATEDIFF(hour, @FromDate, @ToDate) ;
	--	END ;


	---- Generate time series with 1d or 1h increment, fill into @Date_Tab
	SET @GroupByDay = IIF(DATEDIFF(hour, @FromDate, @ToDate) > 24, 1, 0) ; --to give by day or hour
	--IF @GroupByDay = 0
	--	BEGIN
	--		SET @Dt = @FromDate;
	--		WHILE @Dt < @ToDate
	--			BEGIN
	--				INSERT INTO @Date_Tab VALUES (@Dt) ;
	--				SET @Dt = DATEADD(HOUR, 1, @Dt) ;
	--			END ;
	--	END ;
	--ELSE -- group by day
	--	BEGIN
	--		SET @Dt = CAST(@FromDate AS date) ;
	--		WHILE @Dt <= CAST(@ToDate AS date)
	--			BEGIN
	--				INSERT INTO @Date_Tab VALUES (@Dt) ;
	--				SET @Dt = DATEADD(DAY, 1, @Dt) ;
	--			END ;
	--	END ;

	INSERT INTO @Tab1
	SELECT 
		[Date], 
		ChannelTypeId, 
		SUM(IIF(Direction=1, 1, 0)) AS Outgoing,
		SUM(IIF(Direction=0, 1, 0)) AS Incoming
	FROM
		(SELECT 
			IIF(@GroupByDay = 1, CAST(CreatedAt AS DATE), dbo.fnTimeRoundDown(CreatedAt, 60)) AS [Date],
			ChannelUid AS ChannelTypeId, 
			Direction
		FROM sms.IpmLog WITH (NOLOCK, FORCESEEK)
		WHERE 
			CreatedAt >= @FromDate
			AND CreatedAt < @ToDate
			AND SubAccountUid = @SubAccountUid
			AND (@ChannelId IS NULL OR ChannelUid = @ChannelTypeId)
		) ipm
	GROUP BY [Date], ChannelTypeId ;

	SELECT t.DT [Date], Ch.ChannelType AS ChannelId, t.Outgoing, t.Incoming
	FROM @Tab1 t
		LEFT JOIN ipm.ChannelType Ch WITH (NOLOCK) ON t.ChannelTypeId = Ch.ChannelTypeId
	ORDER BY T.DT DESC;

	INSERT INTO @Tab2
	SELECT 
		[Date],
		SUM(Delivered) AS Delivered, 
		SUM(Outgoing-Delivered-[Read]) AS Undelivered,
		SUM([Read]) AS[Read], 
		SUM(Outgoing) AS Outgoing,
		SUM(Incoming) AS Incoming, 
		SUM(Outgoing-Chargeable) AS [Free], 
		SUM(Chargeable) AS Chargeable,
		Currency,
		SUM(Fee) AS Fee
	FROM
		(SELECT 
			[Date],
			Delivered = CASE WHEN Direction = 1 AND [StatusId] = 40 THEN 1 ELSE 0 END,
			[Read] = CASE WHEN Direction = 1 AND [StatusId] = 50 THEN 1 ELSE 0 END,
			Incoming = CASE Direction WHEN 0 THEN 1 ELSE 0 END,
			Outgoing = CASE Direction WHEN 1 THEN 1 ELSE 0 END,
			Chargeable = CASE WHEN Direction = 1 AND StatusId >= 40
							AND ((Ch.ChannelType = 'WA' AND InitSession = 1)
							OR Ch.ChannelType = 'VB' OR Ch.ChannelType = 'LN') THEN 1 ELSE 0 END,
			Currency,
			Fee = CASE WHEN Direction = 1 AND StatusId >= 40
							AND ((Ch.ChannelType = 'WA' AND InitSession = 1)
							OR Ch.ChannelType = 'VB' OR Ch.ChannelType = 'LN') THEN Fee ELSE 0 END
		FROM
			(SELECT 
				IIF(@GroupByDay = 1, CAST(CreatedAt AS DATE), dbo.fnTimeRoundDown(CreatedAt, 60)) AS [Date], 
				--CAST(CreatedAt AS DATE) [Date],
				ChannelUid as ChannelTypeId,
				Direction, 
				StatusId, 
				InitSession, 
				ContractCurrency AS Currency, 
				MessageFeeContract AS Fee
			FROM sms.IpmLog WITH (NOLOCK, FORCESEEK)
			WHERE CreatedAt >= @FromDate
				AND CreatedAt < @ToDate
				AND SubAccountUid = @SubAccountUid
				AND (@ChannelId IS NULL OR ChannelUid = @ChannelTypeId)
			) L
			LEFT JOIN ipm.ChannelType Ch WITH (NOLOCK) ON L.ChannelTypeId = Ch.ChannelTypeId
		) s
	GROUP BY [Date], Currency;

	SELECT 
		t.DT [Date], 
		Delivered, 
		Undelivered, 
		Outgoing, 
		Incoming, 
		[Read], 
		[Free], 
		Chargeable,
		CAST(IIF(Outgoing IS NULL OR Outgoing = 0, 0, (Delivered+[Read])*100/CAST(Outgoing AS DECIMAL(10,2))) AS DECIMAL(10,2)) DeliveryRate,
		CAST(IIF(Outgoing IS NULL OR Outgoing = 0, 0, ([Read])*100/CAST(Outgoing AS DECIMAL(10,2))) AS DECIMAL(10,2)) ReadRate,
		Currency, 
		Fee
	FROM @Tab2 t
	ORDER BY T.DT DESC;

END
