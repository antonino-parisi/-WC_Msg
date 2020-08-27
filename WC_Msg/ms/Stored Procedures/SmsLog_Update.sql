-- =============================================
-- Author:		Team work
-- Create date: 2018-09-11
-- =============================================
-- SAMPLE:
-- EXEC ms.SmsLog_Update ...
CREATE PROCEDURE [ms].[SmsLog_Update]
	@UMID			uniqueidentifier,
	--@SubAccountId VARCHAR(50),
	--@Status VARCHAR(50),
	@SmsStatusId	tinyint,	-- newer numeric version of @Status
	@AdditionalInfo varchar(100),
	--@Attempt INT,	-- just for V1
	--@MessageType CHAR(2),	-- just for V1
	@ErrorCode		varchar(20) = NULL,
	@DateTimeStamp	datetime = NULL,
	@CorrelationId	varchar(50) = NULL
AS
BEGIN

	SET NOCOUNT ON;
	
	IF @DateTimeStamp IS NULL SET @DateTimeStamp = GETUTCDATE()
	
	--------------------------------------------------
	---- V2 logic: sms.SmsLog                   ------
	--------------------------------------------------

	DECLARE @CntModified int = 0;
	--SET @CntModified = 0;

	-- DLR Storage v2
	--DECLARE @SmsStatusId tinyint
	DECLARE @Latency int
	DECLARE @OutT TABLE (
		CreatedTime datetime NOT NULL, 
		ConnUid smallint NULL, 
		OperatorId int NULL)
			
	--IF @SmsStatusId IS NULL SET @SmsStatusId= sms.fnGetStatusId(@Status)
			
	UPDATE sms.SmsLog
	SET 
		StatusId = @SmsStatusId, 
		UpdatedTime = @DateTimeStamp, 
		AdditionalInfo = ISNULL(@AdditionalInfo, AdditionalInfo),
		ConnMessageId = ISNULL(@CorrelationId, ConnMessageId), 
		ConnErrorCode = ISNULL(@ErrorCode, ConnErrorCode)
	OUTPUT inserted.CreatedTime, inserted.ConnUid, inserted.OperatorId INTO @OutT 
	WHERE UMID = @UMID
		/* 
			There is not optimized logic in MS now. 
			Event SENT (and sometimes TRASHED, DELIVERED TO DEVICE in MDMeida) saves to DB two times.
			Event DELIVERED TO DEVICE can arrive earlier than DELIVERED TO CARRIER sometimes.
			As a workaround we skip 2nd DB call if Status already the same.
		*/
		AND StatusId < @SmsStatusId

	SET @CntModified = @@ROWCOUNT;

	/* Retry to set correlationid if SENT status is lower than existing one */
	IF @CntModified = 0 AND @CorrelationId IS NOT NULL AND @CorrelationId <> ''
	BEGIN
		UPDATE sms.SmsLog
		SET ConnMessageId = @CorrelationId
		OUTPUT inserted.CreatedTime, inserted.ConnUid, inserted.OperatorId INTO @OutT
		WHERE UMID = @UMID
	END
	
	-- Feature: Cost on delivery.
	-- Logic: set cost to zero if "Rejected" DR received from supplier who has "ChargeOnDelivery" flag
	IF @SmsStatusId IN (31, 41) /* REJECTED BY CARRIER, REJECTED BY DEVICE */
		AND EXISTS (
			SELECT 1 FROM rt.SupplierOperatorConfig soc (NOLOCK) 
				INNER JOIN @OutT ot ON ot.ConnUid = soc.ConnUid AND ot.OperatorId = soc.OperatorId
			WHERE soc.ChargeOnDelivery = 1
		)
	BEGIN
		UPDATE sms.SmsLog
		SET CostContractPerSms = 0, Cost = 0, CostEURPerSms = 0
		WHERE UMID = @UMID
	END

	-- populate of phisically managed index (due to limitation on ONLINE index in MSSQL Standard Edition)
	IF LEN(@CorrelationId) > 0 AND CAST(@UMID as varchar(40)) <> @CorrelationId /* ignore internal IDs */
		INSERT INTO sms.SmsLogConnMessageId (ConnUid, ConnMessageId, UMID)
		SELECT ConnUid, @CorrelationId, @UMID
		FROM @OutT

	--CALCULATE Event Latency
	IF @CntModified > 0
		SELECT TOP 1 @Latency = DATEDIFF(MILLISECOND, CreatedTime, @DateTimeStamp) 
		FROM @OutT
	ELSE
		SET @Latency = -1

	--Insert into sms.DlrLog
	IF EXISTS (SELECT 1 FROM @OutT)
	BEGIN
		-- Note: condition above limits cases. 
		-- If initial condition "StatusId < @SmsStatusId" failed, sms.DlrLog will be not populated
		INSERT INTO sms.DlrLog (UMID, StatusId, EventTime, Latency, Hostname)
		VALUES (@UMID, @SmsStatusId, @DateTimeStamp, @Latency, HOST_NAME())

		IF @Latency BETWEEN 18000000 /* 5 HOURS */ AND 432000000 /* 5 DAYS */
			INSERT INTO sms.StatRecalcRequestSms (UMID) VALUES (@UMID)
			-- note: this record is used to initiate recalc of stats later for this timeframe
	END
	--END

	-- check if record exists
	IF @CntModified = 0
		IF EXISTS (SELECT 1 FROM sms.SmsLog WHERE UMID = @UMID AND StatusId >= @SmsStatusId)
			SET @CntModified = -1
	
	/*
		@CntModified < 0 - Record in db, status in db is greater or equal than current
		@CntModified = 0  - No record in db
		@CntModified > 0 - Status updated
	*/
	SELECT @CntModified
END
