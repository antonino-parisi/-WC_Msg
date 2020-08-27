
-- =============================================
-- Author:		Tony Ivanov
-- Create date: 2020-05-29
-- Description:	Export DlrLogs to external DWH storage
-- =============================================
-- EXEC sms.DlrLog_DWHExport @From = '2020-02-07 10:00', @To = '2020-02-07 10:30'
CREATE PROCEDURE [sms].[DlrLog_DWHExport]
	@From datetime,
	@To datetime
AS
BEGIN

	-- validation
	IF @To <= @From OR DATEDIFF(MINUTE, @From, @To) > 30
		THROW 51000, 'Negative or too large time range', 1;

	-- main query
	SELECT 
		lg.DlrLogId,
		CAST(lg.Umid as varchar(36)) AS Umid,
		slg.SubAccountId,
		lg.StatusId,
		lg.EventTime,
		lg.Latency,
		lg.Hostname
	FROM sms.DlrLog AS lg (NOLOCK)
	INNER JOIN sms.SmsLog AS slg ON slg.UMID = lg.UMID
	WHERE lg.EventTime >= @From AND lg.EventTime < @To
	ORDER BY lg.EventTime
END
