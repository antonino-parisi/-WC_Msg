-- =============================================
-- Author:		Rebecca
-- Create date: 2019-04-11
-- =============================================
-- SELECT * FROM rpt.fnWavecellLatencyLiveData (30, 'tix_otp', 'ID', DEFAULT, 80)
-- SELECT * FROM rpt.fnWavecellLatencyLiveData (30, 'tix_otp', 'ID', 'Indosat_Local', 80)

CREATE FUNCTION [rpt].[fnWavecellLatencyLiveData] (
	@Interval_Min tinyint = 30,
	@SubAccountId varchar(50) = NULL,
	@Country char(2) = NULL,
	@ConnId varchar(50) = NULL,
	@Percentile tinyint = 80 -- 80th percentile is the default
)
RETURNS @retLatency TABLE   
(
	TimeInterval varchar(20),
	SubAccountId varchar(50),
	ConnId varchar(50),
	Country char(2),
	OperatorName varchar(50),
	OperatorId int,
	--Avg_Wavecell_latency decimal(16,2),
	--Med_Wavecell_latency decimal(16,2),
	Avg_latency decimal(16,2),
	Latency decimal(16,2)
) 
AS  
BEGIN 
	DECLARE @start_time datetime = GETUTCDATE() ;
	DECLARE @from_time datetime, @to_time datetime ;
	DECLARE @tmp TABLE (
		TimeFrom varchar(5),
		UMID uniqueidentifier,
		CreatedTime datetime,
		SubAccountId varchar(50),
		ConnId varchar(50),
		Country char(2),
		Operatorid int,
		StatusId tinyint
	) ;

	-- Cannot both be null
	IF @SubAccountId IS NULL AND @ConnId IS NULL
		RETURN ;

	IF @interval_min > 120 -- limit query to 2 hrs
		SET @interval_min = 120 ;

	SET @interval_min = @Interval_Min/5*5 ;

	SET @to_time = CAST(FORMAT(MessageSphere.dbo.fnTimeRoundDown(GETUTCDATE(), 5), 'yyyy-MM-dd HH:mm') AS datetime) ;
	--SET @from_time = DATEADD(minute, -@Interval_Min, GETUTCDATE()) ;
	SET @from_time = DATEADD(minute, -@Interval_Min, @to_time) ;
	SET @start_time = @from_time ;

	WHILE @start_time <= @to_time
	BEGIN
		--PRINT CAST(DATEADD(minute, -15, @start_time) as varchar(20)) + ' to ' + CAST(@start_time as varchar(20)) ;
		IF @ConnId IS NULL
			INSERT INTO @tmp
			SELECT FORMAT(dbo.fnTimeRoundDown(CreatedTime, 5), 'HH:mm') TimeFrom, UMID,
					CreatedTime, SubAccountId, ConnId, Country, OperatorId, StatusId
					FROM sms.SmsLog l WITH (NOLOCK)
					WHERE
						l.CreatedTime >= @start_time
						AND l.CreatedTime < DATEADD(minute, 5, @start_time)
						AND l.SubAccountId = @SubAccountId
						--AND l.Country = @Country
						AND (@Country IS NULL OR l.Country = @Country)
						AND l.StatusId >= 30 ;
		ELSE IF @SubAccountId IS NULL
			INSERT INTO @tmp
			SELECT FORMAT(dbo.fnTimeRoundDown(CreatedTime, 5), 'HH:mm') TimeFrom, UMID,
					CreatedTime, SubAccountId, ConnId, Country, OperatorId, StatusId
					FROM sms.SmsLog l WITH (NOLOCK, FORCESEEK)
					WHERE
						l.CreatedTime >= @start_time
						AND l.CreatedTime < DATEADD(minute, 5, @start_time)
						AND l.ConnId = @ConnId
						--AND l.Country = @Country
						AND (@Country IS NULL OR l.Country = @Country)
						AND l.StatusId >= 30 ;
		ELSE -- Both not null
			INSERT INTO @tmp
			SELECT FORMAT(dbo.fnTimeRoundDown(CreatedTime, 5), 'HH:mm') TimeFrom, UMID,
					CreatedTime, SubAccountId, ConnId, Country, OperatorId, StatusId
					FROM sms.SmsLog l WITH (NOLOCK, FORCESEEK)
					WHERE
						l.CreatedTime >= @start_time
						AND l.CreatedTime < DATEADD(minute, 5, @start_time)
						AND l.SubAccountId = @SubAccountId
						AND l.ConnId = @ConnId
						--AND l.Country = @Country
						AND (@Country IS NULL OR l.Country = @Country)
						AND l.StatusId >= 30 ;

		INSERT INTO @retLatency
		SELECT n.TimeFrom [Time],
				n.SubAccountId, n.ConnId, n.Country, o.OperatorName, n.OperatorId,
				--CAST(Average_Wavecell_Latency AS DECIMAL(10,2)) [Average Wavecell Latency (s)],
				--CAST(Median_Wavecell_Latency AS DECIMAL(10,2)) [Median Wavecell Latency (s)],
				CAST(Average_Latency AS DECIMAL(10,2)) [Average Latency (s)],
				CAST(Latency AS DECIMAL(10,2)) [Latency (s)]
		FROM
			(SELECT DISTINCT TimeFrom, SubAccountId, ConnId, Country, OperatorId,
					--AVG(WaveCell_Latency_sec) OVER (PARTITION BY TimeFrom, SubAccountId, ConnId, Country, OperatorId) AS Average_Wavecell_Latency,
					--PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY WaveCell_Latency_sec)
					--		OVER (PARTITION BY TimeFrom, SubAccountId, ConnId, Country, OperatorId) AS Median_Wavecell_Latency,
					AVG(Latency_sec) OVER (PARTITION BY TimeFrom, SubAccountId, ConnId, Country, OperatorId) Average_Latency,
					PERCENTILE_CONT(CAST(@Percentile/CAST(100 AS decimal(5,2)) AS decimal(2,1))) WITHIN GROUP (ORDER BY Latency_sec)
							OVER (PARTITION BY TimeFrom, SubAccountId, ConnId, Country, OperatorId) Latency
			FROM
				(SELECT TimeFrom, SubAccountId, ConnId, Country, OperatorId,
						--WaveCell_Latency_sec = IIF(WaveCell_Latency_sec < 0, 0, WaveCell_Latency_sec),
						Latency_sec = IIF(Latency_sec < 0, 0, Latency_sec)
				FROM
					(SELECT s.TimeFrom, s.SubAccountId, s.ConnId, s.Country, s.OperatorId,
							--WaveCell_Latency_sec=ROUND(DATEDIFF(ms, s.CreatedTime, ISNULL(dl3.EventTime, GETUTCDATE()))/CAST(1000 AS DECIMAL(6,1)),3),
							Latency_sec=ROUND(DATEDIFF(ms, s.CreatedTime, ISNULL(dl3.EventTime, GETUTCDATE()))/CAST(1000 AS DECIMAL(10,2)), 3)
							--Supplier_Latency_sec=ROUND(DATEDIFF(ms, ISNULL(dl3.EventTime, GETUTCDATE()), ISNULL(dl4.EventTime, GETUTCDATE()))/CAST(1000 AS DECIMAL(6,1)),3)
					FROM @tmp s
						--LEFT JOIN sms.DlrLog dl3 WITH (NOLOCK, INDEX(IX_DlrLog_UMID_StatusId), FORCESEEK) ON s.UMID = dl3.UMID AND (dl3.StatusId = 30 OR dl3.StatusId = 31)
						LEFT JOIN sms.DlrLog dl3 WITH (NOLOCK, INDEX(IX_DlrLog_UMID_StatusId), FORCESEEK)
							ON s.UMID = dl3.UMID
								AND (dl3.StatusId = 30 OR dl3.StatusId = 31)
					) m
				) w
			) n
			LEFT JOIN mno.Operator o ON n.OperatorId = o.OperatorId ;

		DELETE @tmp ;
		SELECT @start_time = DATEADD(minute, 5, @start_time) ;

	END ;

	RETURN ;

END ;
