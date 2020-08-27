-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-01-03
-- Description:	Delete records older that 6 months
-- =============================================
-- EXEC sms.job_SmsLog_DeleteOldRecords
-- SELECT MIN(CreatedTime) FROM sms.SmsLog
-- SELECT MIN(EventTime) FROM sms.DlrLog
CREATE PROCEDURE [sms].[job_SmsLog_DeleteOldRecords]
AS
BEGIN

	-- Define delete date
	--DECLARE @DeleteUntil date = DATEADD(MONTH, -6, DATEFROMPARTS(YEAR(GETUTCDATE()), MONTH(GETUTCDATE()), 1))
	DECLARE @DeleteUntil date = DATEADD(MONTH, -6, GETUTCDATE())
	
	DECLARE @LastDumpUntil date 
	SELECT @LastDumpUntil = DATEADD(MONTH, 1, CAST(ParameterValue + '01' as date)) FROM ms.ApplicationSettings2 WHERE ParameterName = 'Backup.SmsLog.LastDump'

	-- ro
	IF (@DeleteUntil > @LastDumpUntil)
		SET @DeleteUntil = @LastDumpUntil

	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Goal: Delete until ' + CAST(@DeleteUntil as varchar(40))
	
	-------------
	--- DlrLog --
	-------------
	SET NOCOUNT ON;
	DECLARE @JobLimitDurationInMins int = 60 * 4
	--DECLARE @LimitDeletePerCall int = 20000000
	DECLARE @TotalCounter INT = 0
	DECLARE @JobStartTimeUtc datetime2 = SYSUTCDATETIME()
	DECLARE @DlrLogIdUntil bigint
	DECLARE @BatchSize_DlrLog int = 10000
	DECLARE @LastBatchCount int = @BatchSize_DlrLog

	SELECT TOP (1) @DlrLogIdUntil = DlrLogId FROM sms.DlrLog (NOLOCK) WHERE EventTime BETWEEN @DeleteUntil AND DATEADD(MINUTE, 10, CAST(@DeleteUntil as datetime2)) 
	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'DlrLog: Starting delete until ' + CAST(@DeleteUntil as varchar(40)) + ' | WHERE DlrLogId < ' + CAST(@DlrLogIdUntil as varchar(20))
	
	-- just in case if DlrLogId wasn't definied
	IF @DlrLogIdUntil IS NULL
	BEGIN
		DECLARE @msg NVARCHAR(2048)
		SET @msg = 'Incorrect input @DlrLogIdUntil to start deletion';
		THROW 51000, @msg, 1;
	END

	--WHILE EXISTS (SELECT TOP (1) 1 FROM sms.DlrLog dl (NOLOCK) WHERE EventTime < @DeleteUntil)
	WHILE @BatchSize_DlrLog = @LastBatchCount 	
		AND DATEDIFF(MINUTE, @JobStartTimeUtc, SYSUTCDATETIME()) < @JobLimitDurationInMins -- limit SP duration by time
	BEGIN
		DELETE TOP(@BatchSize_DlrLog) 
		FROM sms.DlrLog 
		WHERE DlrLogId < @DlrLogIdUntil

		SET @LastBatchCount = @@ROWCOUNT
		SET @TotalCounter += @LastBatchCount

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'DlrLog: Total deleted = ' + CAST(@TotalCounter AS VARCHAR(15)) + ' | Last deleted = ' + CAST(@LastBatchCount AS VARCHAR(15))

		WAITFOR DELAY '00:00:01'
	END

	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'DlrLog: cleanup completed. Deleted records = ' + CAST(@TotalCounter AS VARCHAR(15))

	---- exit if daily limit reached
	--IF (@TotalCounter >= @LimitDeletePerCall)
	--BEGIN
	--	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'DlrLog: !!! WARNING !!! Exit from Job. Delete was completed only partly. Programmatic threshold is reached of deletions per one job session.'
	--	RETURN 
	--END

	-------------
	--- SmsLog --
	-------------
	--DECLARE @TotalCounter INT = 0
	--DECLARE @DeleteUntil date = '20170901'
	--DECLARE @LimitDeletePerCall int

	--SET @LimitDeletePerCall = 10000000
	SET @TotalCounter = 0
	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'SmsLog: Starting delete until ' + CAST(@DeleteUntil as varchar(40))
	DECLARE @UMIDs TABLE (UMID uniqueidentifier PRIMARY KEY)
	DECLARE @TimeCounter datetime
	DECLARE @BatchSize_SmsLog int = 5000
	SET @LastBatchCount = @BatchSize_SmsLog
	
	-- partial delete for 
	--WHILE EXISTS (SELECT TOP (1) 1 FROM sms.SmsLog sl (NOLOCK) WHERE CreatedTime < @DeleteUntil)
	WHILE @LastBatchCount = @BatchSize_SmsLog
		AND DATEDIFF(MINUTE, @JobStartTimeUtc, SYSUTCDATETIME()) < @JobLimitDurationInMins -- limit SP duration by time
	BEGIN
		SET @TimeCounter = CURRENT_TIMESTAMP

		--SELECT TOP (100) * FROM sms.SmsLog (NOLOCK) WHERE CreatedTime < '20171201'
		INSERT INTO @UMIDs (UMID)
		SELECT TOP(@BatchSize_SmsLog) UMID 
		FROM sms.SmsLog (NOLOCK) 
		WHERE CreatedTime < @DeleteUntil
		--PRINT dbo.CURRENT_TIMESTAMP_STR() + 'SmsLog: Candidates selected from sms.SmsLog'
		EXEC Print_RowCount @msg = 'SmsLog: Candidates selected from sms.SmsLog'

		DELETE FROM sl FROM sms.SmsLog sl JOIN @UMIDs u ON sl.UMID = u.UMID
		EXEC @LastBatchCount = Print_RowCount @msg = 'SmsLog: Deleted from sms.SmsLog'

		--SET @LastBatchCount = @rows
		SET @TotalCounter += @LastBatchCount

		DELETE FROM s FROM sms.SmsCallbackCache s	JOIN @UMIDs u ON s.UMID = u.UMID
		EXEC Print_RowCount @msg = 'SmsLog: Deleted from sms.SmsCallbackCache'

		DELETE FROM s FROM sms.SurveyResponse s		JOIN @UMIDs u ON s.UMID = u.UMID
		EXEC Print_RowCount @msg = 'SmsLog: Deleted from sms.SurveyResponse'

		DELETE FROM s FROM sms.UrlShorten s			JOIN @UMIDs u ON s.UMID = u.UMID
		EXEC Print_RowCount @msg = 'SmsLog: Deleted from sms.UrlShorten'
		
		DELETE FROM s FROM sms.SmsLogClientMessageId s	JOIN @UMIDs u ON s.UMID = u.UMID
		EXEC Print_RowCount @msg = 'SmsLog: Deleted from sms.SmsLogClientMessageId'
		
		DELETE FROM @UMIDs
		
		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'SmsLog: Total deleted = ' + CAST(@TotalCounter AS VARCHAR(15))
			+ ' Speed: ' + CAST(DATEDIFF(MILLISECOND, @TimeCounter, CURRENT_TIMESTAMP) / (@BatchSize_SmsLog /1000) AS varchar(20)) + 'ms/1000rows'
		
		WAITFOR DELAY '00:00:01'
	END

	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'SmsLog: cleanup completed. Deleted records = ' + CAST(@TotalCounter AS VARCHAR(15))
	
	IF DATEDIFF(MINUTE, @JobStartTimeUtc, SYSUTCDATETIME()) >= @JobLimitDurationInMins
		PRINT dbo.CURRENT_TIMESTAMP_STR() + '!!! WARNING !!! Delete was completed only partly. Programmatic threshold is reached of deletions per one job session.'

END