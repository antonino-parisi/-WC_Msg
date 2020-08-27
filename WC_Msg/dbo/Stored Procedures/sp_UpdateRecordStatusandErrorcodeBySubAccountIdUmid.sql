--EXEC [dbo].[sp_UpdateRecordStatusandErrorcodeBySubAccountIdUmid] 
CREATE PROCEDURE [dbo].[sp_UpdateRecordStatusandErrorcodeBySubAccountIdUmid]
	@UMID VARCHAR(50),
	@SubAccountId VARCHAR(50),
	@Attempt INT,
	@Status VARCHAR(50),
	@AdditionalInfo NVARCHAR(255),
	@ErrorCode NVARCHAR(255),
	@DateTimeStamp datetime = NULL
AS
BEGIN
	SET NOCOUNT ON;
	--SET NOCOUNT OFF;

	IF @DateTimeStamp IS NULL SET @DateTimeStamp = GETUTCDATE()
	
	----------DECLARE @newLevel int;
	----------DECLARE @oldLevel int;
	----------DECLARE @oldStatus varchar(50);

	----------SET @newLevel = ms.GetDRLevel(@Status)
	----------SELECT @oldLevel = ms.GetDRLevel([Status]), @oldStatus = [Status] FROM [dbo].[TrafficRecord] WHERE UMID = @UMID and SubAccountId = @SubAccountId and MessageType = 'MT'
	----------IF (@oldLevel > @newLevel)
	----------BEGIN
	----------	INSERT INTO dbo.tmp_DLR1124 (UMID, NewStatus, OldStatus) VALUES (@UMID, @Status, @oldStatus)
	----------	RETURN
	----------	--THROW 51000, 'DR level in DB is higher than requested', 1;
	----------END

	--DECLARE @CurStatus NVARCHAR(50);
	--IF (@Status='TRASHED')
	--BEGIN
	--	UPDATE [dbo].[TrafficRecord] 
	--	SET Status = @Status, ErrorCode=@ErrorCode, DateTimeUpdated = @DateTimeStamp, Attempt = @Attempt
	--	WHERE UMID = @UMID and SubAccountId = @SubAccountId and MessageType = 'MT'
	--END
	--ELSE IF (@Status = 'DELIVERED TO DEVICE' OR @Status='REJECTED BY CARRIER')
	--BEGIN
	--	UPDATE [dbo].[TrafficRecord] 
	--	SET Status = @Status, ErrorCode=@ErrorCode, DateTimeUpdated = @DateTimeStamp, Attempt = @Attempt, AdditionalInfo = @AdditionalInfo
	--	WHERE UMID = @UMID and SubAccountId = @SubAccountId and MessageType = 'MT'
	--END
	--ELSE
	--BEGIN

	--	SET @CurStatus = (Select TOP(1) Status from [dbo].[TrafficRecord] WITH(NOLOCK) WHERE UMID = @UMID and SubAccountId = @SubAccountId and MessageType = 'MT')

	--	IF NOT (@CurStatus = 'DELIVERED TO DEVICE' OR @CurStatus='REJECTED BY CARRIER')
	--	BEGIN
	--		UPDATE [dbo].[TrafficRecord] 
	--		SET Status = @Status, ErrorCode=@ErrorCode, DateTimeUpdated = @DateTimeStamp, Attempt = @Attempt, AdditionalInfo = @AdditionalInfo
	--		WHERE UMID = @UMID and SubAccountId = @SubAccountId and MessageType = 'MT'
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
			
			SET @SmsStatusId = sms.fnGetStatusId(@Status)
			
			UPDATE sms.SmsLog
			SET 
				StatusId = @SmsStatusId, 
				UpdatedTime = @DateTimeStamp, 
				AdditionalInfo = CAST(@AdditionalInfo as varchar(100)), 
				ConnErrorCode = CAST(@ErrorCode as varchar(20))
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
				SELECT TOP 1 @Latency = DATEDIFF(MILLISECOND, CreatedTime, @DateTimeStamp) FROM @OutT
			ELSE
				SET @Latency = -1

			--Insert to DlrLog
			IF EXISTS (SELECT 1 FROM @OutT)
			BEGIN
				INSERT INTO sms.DlrLog (UMID, StatusId, EventTime, Latency, Hostname)
				VALUES (@uid, @SmsStatusId, @DateTimeStamp, @Latency, HOST_NAME())

				IF @Latency > 18000000 /* 5 HOURS */ 
					INSERT INTO sms.StatRecalcRequestSms (UMID) VALUES (@uid)
			END
		--END TRY 
		--BEGIN CATCH
		--	PRINT ERROR_MESSAGE()
		--END CATCH
	END
END
