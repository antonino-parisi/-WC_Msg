
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-11-20
-- =============================================
-- EXEC sms.job_DlrLog_CalculateLatency
-- SELECT TOP 100 * FROM sms.StatLatencyMTWavecell ORDER BY TimeFrom DESC, Host
CREATE PROCEDURE [sms].[job_DlrLog_CalculateLatency]
AS
BEGIN
	DECLARE @TimeIntervalInMins smallint = 5
	DECLARE @TimeFrom smalldatetime
	DECLARE @CalcDurationInMins smallint = 120
	
	SELECT TOP 1 @TimeFrom = TimeFrom FROM sms.StatLatencyMTWavecell ORDER BY TimeFrom DESC
	SET @TimeFrom = DATEADD(MINUTE, @TimeIntervalInMins, @TimeFrom)

	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'PERIOD: ' + CONVERT(varchar(50), @TimeFrom, 20) --+ ' - ' + CONVERT(varchar(50), @TimeframeEnd, 20)
	
	INSERT INTO sms.StatLatencyMTWavecell (TimeFrom, Host, Qty, Avg, Median)
    --SELECT DISTINCT dbo.fnTimeRountdown(MIN(dl.EventTime), @TimeIntervalInMins) as TimeFrom,
		--AVG(CAST(dl.Latency as bigint))/1000 as LatencyAvgInSec, MAX(dl.Latency)/1000 as LatencyMaxInSec, 
		--SUM(1) as CntTotal, 
		--SUM(CASE WHEN dl.Latency BETWEEN 5000 AND 30000 THEN 1 ELSE 0 END) as [Cnt5-30sec],
		--SUM(CASE WHEN dl.Latency > 30000 THEN 1 ELSE 0 END) as CntMore30sec,
	SELECT DISTINCT
		dbo.fnTimeRountdown(dl.EventTime, @TimeIntervalInMins) AS TimeFrom,
		dl.Hostname,
		COUNT(dl.StatusId)  OVER (PARTITION BY dbo.fnTimeRountdown(dl.EventTime, @TimeIntervalInMins), Hostname) AS Qty,
		AVG(cast(dl.Latency as bigint)) OVER (PARTITION BY dbo.fnTimeRountdown(dl.EventTime, @TimeIntervalInMins), Hostname) AS LatencyAvg,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cast(dl.Latency as bigint)) OVER (PARTITION BY dbo.fnTimeRountdown(dl.EventTime, @TimeIntervalInMins), Hostname) AS LatencyMedian
	FROM [sms].[DlrLog] dl WITH (NOLOCK, INDEX(IX_DlrLog_EventTime_Status))
	WHERE 
		--AND dl.EventTime > DATEADD(MINUTE, -240, GETUTCDATE())
		dl.EventTime >= @TimeFrom AND dl.EventTime < DATEADD(MINUTE, @CalcDurationInMins, @TimeFrom)
		AND dl.StatusId = 20
		AND dl.Latency < 60000
		--AND dl.SubAccountId ='tyntec_sim'
		--AND Hostname IN ('PRO-SMS1', 'PRO-SMS3')
	
	--GROUP BY Hostname
	--dbo.fnTimeRountdown(MIN(dl.EventTime), @TimeIntervalInMins)
	--HAVING COUNT(CASE WHEN dl.Latency >= 30000 THEN 1 ELSE NULL END) > 10
	ORDER BY 1, 2-- DESC, 3 DESC

	RETURN 0
END
