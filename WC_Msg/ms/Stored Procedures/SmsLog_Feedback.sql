
-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2019-02-27
-- =============================================
-- SAMPLE:
-- EXEC ms.SmsLog_Feedback @UMID, 
CREATE PROCEDURE [ms].[SmsLog_Feedback] 
	@UMID uniqueidentifier,
	@SubAccountUid int,
	@Outcome bit,
	@Timestamp datetime2(2)
AS
BEGIN

	-- only successful outcome saved
	IF @Outcome <> 1 RETURN

	-- calc Latency from timestamp of receiving sms
	DECLARE @Latency int
	DECLARE @CreatedTime datetime2(2)

	SELECT TOP 1 @CreatedTime = CreatedTime
	FROM sms.SmsLog (NOLOCK)
	WHERE UMID = @UMID AND SubAccountUid = @SubAccountUid

	-- calc latency avoiding edge case overflow
	IF DATEDIFF(DAY, @CreatedTime, @Timestamp) <= 24 -- to avoid overflow for ms
		SET @Latency = DATEDIFF(MILLISECOND, @CreatedTime, @Timestamp) 
	ELSE
		SET @Latency = 2073600000 -- 24 days in ms

	-- Save as READ event for UMID
	IF @Latency IS NOT NULL
		INSERT INTO sms.DlrLog (UMID, StatusId, EventTime, Latency, Hostname)
		VALUES (@UMID, 50 /* READ */, @Timestamp, @Latency, HOST_NAME())

END