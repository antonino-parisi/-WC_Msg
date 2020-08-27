

CREATE PROCEDURE [dbo].[sp_UpdateRecordStatusCIdBySubAccountIdUmid]
	@UMID VARCHAR(50),
	@SubAccountId VARCHAR(50),
	@CorrelationId VARCHAR(50),
	@Status VARCHAR(50),
	@AdditionalInfo NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Timestamp datetime = GETUTCDATE()

	--UPDATE [dbo].[TrafficRecord] 
	--SET Status = @Status, AdditionalInfo = @AdditionalInfo,
	--	CorrelationId = @CorrelationId, DateTimeUpdated = @Timestamp
	--WHERE UMID = @UMID and SubAccountId = @SubAccountId and MessageType = 'MT'

	-- DLR Storage v2
	DECLARE @uid uniqueidentifier
	SET @uid = TRY_CAST(@UMID as uniqueidentifier)
	IF (LEN(@UMID) = 36 AND @uid IS NOT NULL)
	BEGIN
		--BEGIN TRY
			DECLARE @SmsStatusId tinyint 
			SET @SmsStatusId = sms.fnGetStatusId(@Status)
			
			DECLARE @Latency int
			DECLARE @OutT TABLE (CreatedTime datetime NOT NULL, ConnUid int)
			
			UPDATE sms.SmsLog
			SET 
				StatusId = @SmsStatusId, 
				UpdatedTime = @Timestamp, 
				AdditionalInfo = CAST(@AdditionalInfo as varchar(100)),
				ConnMessageId = @CorrelationId
			OUTPUT inserted.CreatedTime, inserted.ConnUid INTO @OutT 
			WHERE UMID = @uid
				/* 
					There is not optimized logic in MS now. 
					Event SENT (and sometimes TRASHED, DELIVERED TO DEVICE in MDMeida) saves to DB two times.
					Event DELIVERED TO DEVICE can arrive earlier than DELIVERED TO CARRIER sometimes.
					As a workaround we skip 2nd DB call if Status already the same.
				*/
				AND StatusId < @SmsStatusId

			-- populate of phisically managed index (due to limitation on ONLINE index in MSSQL Standard Edition)
			IF LEN(@CorrelationId) > 0 AND @UMID <> @CorrelationId /* ignore internal IDs */
				INSERT INTO sms.SmsLogConnMessageId (ConnUid, ConnMessageId, UMID)
				SELECT ConnUid, @CorrelationId, @uid
				FROM @OutT

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
