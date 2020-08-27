
CREATE PROCEDURE [dbo].[sp_UpdateRecordStatusBySubAccountIdUmid]
	@UMID VARCHAR(50),
	@SubAccountId VARCHAR(50),
	@Attempt INT,
	@Status VARCHAR(50),
	@AdditionalInfo NVARCHAR(255)
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @Timestamp datetime = GETUTCDATE()
	--DECLARE @CurStatus NVARCHAR(50);

	--IF (@Status='TRASHED')
	--BEGIN
	--	UPDATE [dbo].[TrafficRecord] 
	--	SET Status = @Status, DateTimeUpdated = @Timestamp, Attempt = @Attempt 
	--	WHERE UMID = @UMID and SubAccountId = @SubAccountId --and MessageType = 'MT'
	--END
	--ELSE if (@Status = 'DELIVERED TO DEVICE' OR @Status='REJECTED BY CARRIER')
	--BEGIN
	--	UPDATE [dbo].[TrafficRecord] 
	--	SET Status = @Status, AdditionalInfo = @AdditionalInfo, DateTimeUpdated = @Timestamp, Attempt = @Attempt 
	--	WHERE UMID = @UMID and SubAccountId = @SubAccountId --and MessageType = 'MT'
	--END
	--ELSE
	--BEGIN

	--	SELECT @CurStatus = Status 
	--	FROM [dbo].[TrafficRecord] WITH(NOLOCK) 
	--	WHERE UMID = @UMID and SubAccountId = @SubAccountId --and MessageType = 'MT'

	--	IF NOT (@CurStatus = 'DELIVERED TO DEVICE' OR @CurStatus='REJECTED BY CARRIER' )
	--	BEGIN
	--		UPDATE [dbo].[TrafficRecord] 
	--		SET Status = @Status, AdditionalInfo = @AdditionalInfo, DateTimeUpdated = @Timestamp, Attempt = @Attempt
	--		WHERE UMID = @UMID and SubAccountId = @SubAccountId --and MessageType = 'MT'
	--	END
	--END

	-- DLR Storage v2
	DECLARE @uid uniqueidentifier
	SET @uid = TRY_CAST(@UMID as uniqueidentifier)
	IF (LEN(@UMID) = 36 AND @uid IS NOT NULL)
	BEGIN
		--BEGIN TRY
			DECLARE @SmsStatusId tinyint 
			DECLARE @Latency int
			DECLARE @OutT TABLE (CreatedTime datetime NOT NULL)
			
			SET @SmsStatusId= sms.fnGetStatusId(@Status)
			
			UPDATE sms.SmsLog
			SET 
				StatusId = @SmsStatusId, 
				UpdatedTime = @Timestamp, 
				AdditionalInfo = CAST(@AdditionalInfo as varchar(100))
			OUTPUT inserted.CreatedTime INTO @OutT 
			WHERE UMID = @uid
				/* 
					There is not optimized logic in MS now. 
					Event SENT (and sometimes TRASHED, DELIVERED TO DEVICE in MDMeida) saves to DB two times.
					Event DELIVERED TO DEVICE can arrive earlier than DELIVERED TO CARRIER sometimes.
					As a workaround we skip 2nd DB call if Status already the same.
				*/
				AND StatusId < @SmsStatusId

			--CALCULATE Event Latency
			IF @@ROWCOUNT > 0
				SELECT TOP 1 @Latency = DATEDIFF(MILLISECOND, CreatedTime, @Timestamp) FROM @OutT
			ELSE
				SET @Latency = -1

			--Insert to DlrLog
			IF EXISTS (SELECT 1 FROM @OutT)
			BEGIN
				INSERT INTO sms.DlrLog (UMID, StatusId, EventTime, Latency, Hostname)
				VALUES (@uid, @SmsStatusId, @Timestamp, @Latency, HOST_NAME())

				IF @Latency > 18000000 /* 5 HOURS */
					INSERT INTO sms.StatRecalcRequestSms (UMID) VALUES (@uid)
			END
		--END TRY 
		--BEGIN CATCH
		--	PRINT ERROR_MESSAGE()
		--END CATCH
	END
END

