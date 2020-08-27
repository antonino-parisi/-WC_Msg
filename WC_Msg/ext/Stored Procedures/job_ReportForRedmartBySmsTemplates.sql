
CREATE PROCEDURE [ext].[job_ReportForRedmartBySmsTemplates]
AS
BEGIN
	-- Fill data
	DECLARE @StartDate date = DATEADD(DAY, 1, EOMONTH(GETUTCDATE(),-5))
	DECLARE @EndDate date = DATEADD(month, 1, @StartDate)
	
	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'PERIOD: ' + CAST(@StartDate as varchar(20)) + ' - ' + CAST(@EndDate as varchar(20))

	/*
	USE tempdb
	--DROP TABLE tempdb.dbo.SmsLogRedmart
	CREATE TABLE tempdb.dbo.SmsLogRedmart (
		id int NOT NULL IDENTITY (1,1) PRIMARY KEY, 
		UMID uniqueidentifier NOT NULL,
		SubAccountUid int NOT NULL,
		Body nvarchar(750) NULL,
		StatusId smallint NOT NULL,
		Segments tinyint NOT NULL,
		TemplateId smallint NULL
	)  ON [PRIMARY]
	GO
	*/

	-- prepare empty temp table for log
	IF OBJECT_ID ('tempdb.dbo.SmsLogRedmart', 'U') IS NOT NULL
		TRUNCATE TABLE tempdb.dbo.SmsLogRedmart
	ELSE
		CREATE TABLE tempdb.dbo.SmsLogRedmart (
			id int NOT NULL IDENTITY (1,1) PRIMARY KEY, 
			Date date NOT NULL,
			UMID uniqueidentifier NOT NULL,
			SubAccountUid int NOT NULL,
			Body nvarchar(750) NULL,
			StatusId smallint NOT NULL,
			Segments tinyint NOT NULL,
			TemplateId smallint NULL
		)

	-- copy Redmart messages for SmsLog
	INSERT INTO tempdb.dbo.SmsLogRedmart (
		Date, UMID, SubAccountUid, Body, StatusId, Segments)
	SELECT
		DATEADD(DAY, 1, EOMONTH(t.CreatedTime,-1)), 
		UMID, 
		SubAccountUid, 
		LEFT(Body, 750) AS Body, 
		StatusId, 
		SegmentsReceived
	FROM sms.SmsLog t (NOLOCK)
	WHERE t.CreatedTime >= @StartDate and t.CreatedTime < @EndDate
		AND SubAccountId IN (
			SELECT SubAccountId FROM dbo.Account WHERE AccountId IN ('redmart')
		)
	
	PRINT dbo.Log_ROWCOUNT('From SmsLog')

	-- Match with templates dictionary
	------------------------
	DECLARE @n INT = 0;
	DECLARE @step INT = 50000;
	DECLARE @max INT;

	SELECT @max = MAX(id) FROM tempdb.dbo.SmsLogRedmart

	WHILE @n <= @max
	BEGIN
		update l set TemplateId = t.TemplateId
		from tempdb.dbo.SmsLogRedmart l
			inner join ext.SmsTemplateRedmart t on RTRIM(l.Body) like RTRIM(t.Template)
		where 
			l.id between @n and @n + @step - 1
			and l.TemplateId is null 
	
		IF @@ROWCOUNT > @step / 2
			WAITFOR DELAY '00:00:02';
	
		SET @n = @n + @step;
	END;
	-------

END
