-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-25
-- =============================================
-- EXEC sms.job_SmsLog_AddJob @PastMinutes = 360
-- EXEC sms.job_SmsLog_AddJob @PastMinutes = 35760
-- SELECT TOP 20 * FROM sms.JobCalculate /*WHERE StartedAt IS NULL*/ ORDER BY CreatedAt DESC
CREATE PROCEDURE [sms].[job_SmsLog_AddJob]
	@PastMinutes int
AS
BEGIN
	
	IF @PastMinutes IS NULL RETURN

	/* Step 1: PLAN jobs */
	DECLARE @TimeframeStart smalldatetime, @TimeframeEnd smalldatetime

	/* KEY CONST */	
	DECLARE @TimeIntervalInMins smallint = 15

	IF @PastMinutes <= 360
	BEGIN
		SET @TimeframeStart = dbo.fnTimeRountdown(DATEADD(MINUTE, -@PastMinutes, GETUTCDATE()), @TimeIntervalInMins)
		SET @TimeframeEnd = GETUTCDATE()
		
		-- add generic task
		INSERT INTO sms.JobCalculate (TimeframeStart, TimeframeEnd, SubAccountUid, Country, OperatorId) 
		VALUES (@TimeframeStart, @TimeframeEnd, NULL, NULL, NULL)
	END
	ELSE
	BEGIN

		DECLARE @umids TABLE (id int, UMID uniqueidentifier)
		INSERT INTO @umids (id, UMID) SELECT id, UMID FROM sms.StatRecalcRequestSms

		INSERT INTO sms.JobCalculate (TimeframeStart, TimeframeEnd, SubAccountUid, Country, OperatorId) 
		SELECT DISTINCT dbo.fnTimeRountdown(sl.CreatedTime, @TimeIntervalInMins) AS MinCreatedTime, DATEADD(MINUTE, @TimeIntervalInMins, dbo.fnTimeRountdown(sl.CreatedTime, @TimeIntervalInMins)) AS MaxCreatedTime, 
			sl.SubAccountUid, NULL, NULL
			--sl.SubAccountUid, sl.Country, sl.OperatorId
		FROM sms.SmsLog sl (NOLOCK)
			INNER JOIN @umids u ON sl.UMID = u.UMID
		
		DELETE r FROM sms.StatRecalcRequestSms r INNER JOIN @umids u ON r.id = u.id

	END
END
