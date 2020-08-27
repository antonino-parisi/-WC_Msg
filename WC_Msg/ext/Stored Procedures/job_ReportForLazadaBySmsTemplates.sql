
CREATE PROCEDURE [ext].[job_ReportForLazadaBySmsTemplates]
AS
BEGIN
	-- Fill data
	DECLARE @StartDate date = DATEADD(month, DATEDIFF(month, 0, dateadd(month,-1,GETUTCDATE())), 0)
	DECLARE @EndDate date = DATEADD(month, 1, @StartDate)
	
	PRINT dbo.CURRENT_TIMESTAMP_STR() + 'PERIOD: ' + CAST(@StartDate as varchar(20)) + ' - ' + CAST(@EndDate as varchar(20))

	-- prepare empty temp table for log
	IF OBJECT_ID ('tempdb.dbo.SmsLogLazada', 'U') IS NOT NULL
		TRUNCATE TABLE tempdb.dbo.SmsLogLazada
	ELSE
		CREATE TABLE tempdb.dbo.SmsLogLazada (
			id int NOT NULL IDENTITY (1,1) PRIMARY KEY, 
			UMID uniqueidentifier NOT NULL,
			SubAccountUid int NOT NULL,
			MSISDN bigint NOT NULL,
			Body nvarchar(750) NULL,
			StatusId smallint NOT NULL,
			SmsCount tinyint NOT NULL,
			TemplateId smallint NULL,
			CreatedTime datetime2(2) not null,
			Country char(2) null,
			OperatorId int null,
			PricePerSms decimal(12,6) not null
		)

	-- copy lazada messages for SmsLog
	INSERT INTO tempdb.dbo.SmsLogLazada (UMID, SubAccountUid, MSISDN, Body, StatusId, SmsCount, CreatedTime, Country, OperatorId, PricePerSms)
	SELECT UMID, SubAccountUid, MSISDN, LEFT(Body, 750) AS Body, StatusId, SegmentsReceived, CreatedTime, Country, OperatorId, Price
	FROM sms.SmsLog t (NOLOCK)
	WHERE t.CreatedTime >= @StartDate and t.CreatedTime < @EndDate
		AND SubAccountId IN (
			SELECT SubAccountId FROM dbo.Account 
			WHERE AccountId IN (
				'lazada_id','lazada_my','lazada_ph','lazada_sg','lazada_th','lazada_vn','lazada_crossborder', 'lazada_sea', 'lazada_id_dg', 'lazada_ph_dg', 'lazada_vn_dg', 'lazadamal')
		)
	
	PRINT dbo.Log_ROWCOUNT('From SmsLog')

	-- Match with templates dictionary
	------------------------
	DECLARE @n INT = 0;
	DECLARE @step INT = 50000;
	DECLARE @max INT;

	SELECT @max = MAX(id) FROM tempdb.dbo.SmsLogLazada

	WHILE @n <= @max
	BEGIN
		update l set TemplateId = t.TemplateId
		from tempdb.dbo.SmsLogLazada l
			inner join ext.SmsTemplateLazada t on RTRIM(l.Body) like RTRIM(t.Template)
		where 
			l.id between @n and @n + @step - 1
			and l.TemplateId is null 
	
		--IF @@ROWCOUNT > @step / 2
		--	WAITFOR DELAY '00:00:02';
	
		SET @n = @n + @step;
	END;

END
