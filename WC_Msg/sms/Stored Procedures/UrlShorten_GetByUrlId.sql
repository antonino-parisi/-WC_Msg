-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-04-20
-- Description:	UrlShorten - get by url
-- =============================================
CREATE PROCEDURE [sms].[UrlShorten_GetByUrlId]
	@UrlId int
AS
BEGIN
	
	DECLARE @Output TABLE (
		OriginalUrl nvarchar(450),
		Pin smallint,
		UMID uniqueidentifier,
		Hits smallint,
		-- for analytics update
		SubAccountUid int,
		BaseUrlId int,
		CreatedAt datetime2(2)
	)
	DECLARE @UMID uniqueidentifier
	
	UPDATE sms.UrlShorten
	SET Hits += IIF (Hits < 32766, 1, 0),	-- sometimes Hits reachs max value of smallint
		FirstAccessedAt = IIF(FirstAccessedAt IS NULL, SYSUTCDATETIME(), FirstAccessedAt),
		LastAccessedAt = SYSUTCDATETIME()
    OUTPUT inserted.OriginalUrl, 
		inserted.Pin, 
		inserted.UMID, 
		inserted.Hits,
		inserted.SubAccountUid,
		inserted.BaseUrlId,
		inserted.CreatedAt
	INTO @Output (OriginalUrl, Pin, UMID, Hits, SubAccountUid, BaseUrlId, CreatedAt)
	WHERE UrlId = @UrlId

	-- TODO: Logic of Pin validation or Stat update must be changed. 
	-- Currently, if Pin is incorrect, Hit will be counted in any case. :(
	--   Option 1: to validate Pin inside this SP, Pin should be added as input param to this SP
	--   Option 2: Hits update should be moved to separate SP
	DECLARE @Latency int
	DECLARE @DateTimeStamp datetime = GETUTCDATE()

	SELECT 
		@UMID = UMID, 
		@Latency = DATEDIFF(MILLISECOND, CreatedAt, @DateTimeStamp) 
	FROM @Output 
	WHERE UMID IS NOT NULL 
		-- only 1st hit is counted
		AND Hits = 1 
		-- I decided to limit click increment by 15 days window only (Anton). Otherwise it will b overflow for @Latency int & DATEDIFF
		AND CreatedAt > DATEADD(DAY, -15, @DateTimeStamp) 
	
	IF @UMID IS NOT NULL
	BEGIN
		--INSERT INTO sms.DlrLog (UMID, StatusId, EventTime, Latency, Hostname)
		--VALUES (@UMID, 50 /* READ */, @DateTimeStamp, @Latency, NULL)

		EXEC [sms].UrlShorten_UpdateSurveyStats @UMID = @UMID

		---- update of Stat Analytics - must do for all messages
		INSERT INTO sms.StatRecalcRequestSms (UMID) VALUES (@UMID)

	END

	SELECT OriginalUrl, Pin
	FROM @Output
END
