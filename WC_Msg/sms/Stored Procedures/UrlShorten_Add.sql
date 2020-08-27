-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-04-20
-- Description:	UrlShorten - add new url
-- =============================================
-- EXEC [sms].[UrlShorten_Add] @SubAccountUid=6716, @DomainId=1, @OriginalUrl='http://example.com/test', @UMID='28717995-8973-E811-814C-020897DF5459', @Pin=777
CREATE PROCEDURE [sms].[UrlShorten_Add]
	@SubAccountUid int,
	@DomainId smallint,
	@OriginalUrl nvarchar(450),
	@UMID uniqueidentifier,
	@Pin smallint = NULL,
	@BaseUrl nvarchar(450) = NULL
AS
BEGIN
	
	--DECLARE @baseUrl nvarchar(450) 
	
	-- backup plan, if app hasn't provided this value
	IF @BaseUrl IS NULL
		SET @BaseUrl = dbo.GetBasePathFromUrl(@OriginalUrl);	
	
	-- insert of new 'BaseUrl' to 'sms.UrlShortenBaseUrls'
	DECLARE @BaseUrlId int = NULL;	
	SELECT TOP (1) @BaseUrlId = BaseUrlId 
	FROM sms.UrlShortenBaseUrl 
	WHERE BaseUrl = @BaseUrl
	
	IF @BaseUrlId IS NULL
	BEGIN
		-- Race conditions scenario might happen. We do positive insert and ready to fail
		BEGIN TRY
			INSERT sms.UrlShortenBaseUrl VALUES (@BaseUrl);
			SET @BaseUrlId = @@IDENTITY;
		END TRY
		BEGIN CATCH
			SELECT TOP (1) @BaseUrlId = BaseUrlId 
			FROM sms.UrlShortenBaseUrl 
			WHERE BaseUrl = @BaseUrl
		END CATCH
	END
		
	-- insert to sms.UrlShorten
	DECLARE @CreatedAt datetime2(2) = SYSUTCDATETIME()

    INSERT INTO sms.UrlShorten (DomainId, OriginalUrl, BaseUrlId, SubAccountUid, UMID, Pin, CreatedAt)
	OUTPUT INSERTED.UrlId
	VALUES (@DomainId, @OriginalUrl, @BaseUrlId, @SubAccountUid, @UMID, @Pin, @CreatedAt)

	-- ** LOGIC is changed to Background Agregation SQL job **
	-- increment to Stats
	--DECLARE @StatEntryId int;
	--DECLARE @TimeIntervalInMins int = 15 --CONST

	--DECLARE @TimeFrom smalldatetime = dbo.fnTimeRountdown(@CreatedAt, @TimeIntervalInMins)
	
	--SELECT TOP (1) @StatEntryId = StatEntryId 
	--FROM sms.StatUrlShorten 
	--WHERE BaseUrlId = @BaseUrlId AND TimeFrom = @TimeFrom AND SubAccountUid = @SubAccountUid
	
	--IF @StatEntryId IS NOT NULL
	--	UPDATE sms.StatUrlShorten SET UrlCreated += 1 WHERE StatEntryId = @StatEntryId
	--ELSE
	--BEGIN
	--	-- Race conditions scenario might happen. We do positive insert and ready to fail
	--	BEGIN TRY
	--		INSERT sms.StatUrlShorten (TimeFrom, SubAccountUid, BaseUrlId, UrlCreated, UrlClicked)
	--		VALUES (@TimeFrom, @SubAccountUid, @BaseUrlId, 1, 0);
	--	END TRY
	--	BEGIN CATCH
	--		UPDATE sms.StatUrlShorten 
	--		SET UrlCreated += 1 
	--		WHERE TimeFrom = @TimeFrom 
	--			AND BaseUrlId = @BaseUrlId
	--			AND SubAccountUid = @SubAccountUid
	--	END CATCH
	--END
	
END
