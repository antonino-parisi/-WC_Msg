-- =============================================
-- Author:		Team work
-- Create date: 2018-09-11
-- =============================================

-- Flow: 
--		MT-IN  ->	ms.SmsLog_InsertMT
--		MT-OUT ->	ms.SmsLog_UpdateCorrelationId
--		DR-IN  ->	ms.SmsLog_UpdateMTStatus

-- SAMPLE:
-- EXEC ms.SmsLog_UpdateMTStatus ...
CREATE PROCEDURE [ms].[SmsLog_UpdateMTStatus]
	@UMID			uniqueidentifier,
	@SmsStatusId	tinyint,
	@AdditionalInfo varchar(100),
	@ErrorCode		varchar(20),
	@DateTimeStamp	datetime,
	--@CorrelationId	varchar(50) = NULL,
	@ResetCost bit,	-- case: if config "OnDelivery" and Status = Undelivered
	@ResetPrice bit
AS
BEGIN

	SET NOCOUNT ON;
	
	IF @DateTimeStamp IS NULL SET @DateTimeStamp = GETUTCDATE()
	
	DECLARE @CntModified int = 0;
	DECLARE @ResetPriceSuccess bit = 0;
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
		--ConnMessageId = ISNULL(@CorrelationId, ConnMessageId), 
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
	
	-- Feature: Cost on delivery.
	-- Logic: set cost to zero if "Rejected" DR received from supplier who has "ChargeOnDelivery" flag
	-- It was decided for 1st phase to make feature PriceOnDelivery dependent on feature CostOnDelivery
	-- ---
	-- Igor's change: MessageSphere performs checks of statuses and rt.SupplierOperatorConfig,
	-- and sends @ResetCost flag, if required to reset cost
	IF @ResetCost = 1 AND @SmsStatusId IN (31, 41) /* REJECTED BY CARRIER, REJECTED BY DEVICE */		
	BEGIN
			
		-- cost on delivery
		UPDATE sms.SmsLog
		SET CostContractPerSms = 0, 
			Cost = 0, 
			CostEURPerSms = 0
		WHERE UMID = @UMID

	END

	-- Feature: Price on delivery.
	-- Logic: set Price to zero if "Trashed" DR received and requested @ResetPrice
	-- @ResetPrice is resolved from ms.FeatureFilter_BillingOnDelivery
	IF @ResetPrice = 1 AND @SmsStatusId IN (21, 31, 41) /* REJECTED BY WAVECELL, REJECTED BY CARRIER, REJECTED BY DEVICE */		
	BEGIN
		DECLARE @PriceChange TABLE (
			PriceOld decimal(12,6),
			PriceNew decimal(12,6)
		)
		
		-- price on delivery
		UPDATE sms.SmsLog
		SET PriceEURPerSms = 0,
			Price = 0,
			PriceContractPerSms = 0
		OUTPUT deleted.PriceEURPerSms, inserted.PriceEURPerSms INTO @PriceChange (PriceOld, PriceNew)
		WHERE UMID = @UMID

		-- we set flag @ResetPriceSuccess if price of msg was really changed
		IF EXISTS (SELECT 1 FROM @PriceChange WHERE PriceOld > 0 AND PriceOld <> PriceNew)
			SET @ResetPriceSuccess = 1
	END

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
		INSERT INTO sms.DlrLog (UMID, StatusId, EventTime, Latency)
		VALUES (@UMID, @SmsStatusId, @DateTimeStamp, @Latency)

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

	SELECT @CntModified AS ModifyStatus, @ResetPriceSuccess AS ResetPriceSuccess
END
