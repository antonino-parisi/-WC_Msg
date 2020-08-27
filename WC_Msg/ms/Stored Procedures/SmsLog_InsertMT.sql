-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-11-23
-- Description:	Insert of SMS record !!!! critical part of platform !!!
-- =============================================
CREATE PROCEDURE [ms].[SmsLog_InsertMT]
	@UMID				uniqueidentifier,
	@SubAccountUid		int,
	@MSISDN				bigint,
	@SmsStatusId		tinyint,
	@Source_In			varchar(20) = NULL,
	@Source_Out			varchar(20),
	@Body_In			nvarchar(1600),
	@Body_Out			nvarchar(1600),
	--@SmsTypeId			tinyint, /* 0 = MO, 1 = MT, replaced @MessageType */ 
	@ClientDeliveryRequested bit,	-- replaced @RegisteredDelivery
	@ConnUid			int,	-- replaced @RouteIdUsed
	--@EncodingTypeId		tinyint,	/* 0 = GSM7, 10 = UCS2, replaced by @DCS */
	@Country			char(2),
	@OperatorId			int,
	@AdditionalInfo		varchar(100),
	-- Cost
	@Cost					decimal(12,6) = NULL,	--depricated
	@CostContractCurrency	char(3) = NULL,
	@CostContractPerSms		decimal(12,6) = NULL,
	@CostEURPerSms			decimal(12,6) = NULL,

	-- Price
	@Price					decimal(12,6) = NULL,	--depricated
	@PriceContractCurrency	char(3) = NULL,
	@PriceContractPerSms	decimal(12,6) = NULL,
	@PriceEURPerSms			decimal(12,6) = NULL,

	-- Other
	@ProtocolSource		varchar(4),
	@Expiry				datetime = NULL,
	@BatchId			uniqueidentifier = NULL,
	@ClientMessageId	varchar(350) = NULL,
	@ClientBatchId		varchar(50) = NULL,
	@DCS				tinyint,	-- replace @EncodingTypeId, but not sure if it's right decision
	@SegmentsReceived	tinyint,
	@SubmittedTime		datetime = NULL,
	@DlrCallbackUrl		varchar(2000) = NULL	--optional case
AS
BEGIN
	SET NOCOUNT ON;

	--IF @SubAccountId = 'wavecell_dev_1' RETURN

	DECLARE @NowUtc datetime = GETUTCDATE()
	IF (@SubmittedTime IS NULL) SET @SubmittedTime = @NowUtc

	-- INSERT INTO Sms Storage v2
	--DECLARE @uid uniqueidentifier
	--SET @uid = TRY_CAST(@UMID as uniqueidentifier)
	--IF (LEN(@UMID) = 36 AND @uid IS NOT NULL)
	--BEGIN
	BEGIN TRY

		--DECLARE @OperId int
		--DECLARE @ConnUid smallint
		--DECLARE @SubAccountUid int
		DECLARE @ConnId varchar(50)
		DECLARE @SubAccountId varchar(50)

		--SET @OperId = TRY_CAST(@OperatorId as int)
		IF @OperatorId = 0 SET @OperatorId = NULL
		--IF @RouteIdUsed = '' SET @RouteIdUsed = NULL

		IF @Country IS NULL AND @OperatorId IS NOT NULL
			SELECT @Country = CountryISO2alpha FROM mno.Operator WHERE OperatorId = @OperatorId
			
		--SELECT @SubAccountUid = SubAccountUid FROM dbo.Account WHERE SubAccountId = @SubAccountId
		--SELECT @ConnUid = RouteUid FROM dbo.CarrierConnections WHERE RouteId = @RouteIdUsed
		SELECT @SubAccountId = SubAccountId FROM dbo.Account WHERE SubAccountUid = @SubAccountUid
		SELECT @ConnId = RouteId FROM dbo.CarrierConnections WHERE RouteUid = @ConnUid

		INSERT INTO sms.SmsLog
				(UMID,
				SubAccountId,
				SubAccountUid,
				ConnId,
				ConnUid,
				SmsTypeId,
				Country,
				OperatorId,
				StatusId,
				MSISDN,
				SourceOriginal,
				[Source],
				BodyOriginal,
				Body,
				EncodingTypeId,
				DCS,
				CreatedTime,
				UpdatedTime,
				AdditionalInfo,
				ConnTypeId,
				ConnMessageId,
				ConnErrorCode,
				Cost,
				CostCurrency,
				CostContractPerSms,
				CostContractCurrency,
				CostEURPerSms,
				Price,
				PriceCurrency,
				PriceContractPerSms,
				PriceContractCurrency,
				PriceEURPerSms,
				SegmentsReceived,
				ClientMessageId,
				ClientBatchId,
				BatchId,
				ClientDeliveryRequested,
				ExpiryTime)
			VALUES
				(@UMID,
				@SubAccountId,
				@SubAccountUid,
				@ConnId,
				@ConnUid,
				1,--@SmsTypeId, --sms.fnGetSmsTypeId(@MessageType),
				@Country,
				@OperatorId,
				@SmsStatusId, -- sms.fnGetStatusId(@Status),
				@MSISDN,
				@Source_In,
				@Source_Out,
				@Body_In,
				@Body_Out,
				sms.fnGetEncodingTypeIdByDCS(@DCS),
				@DCS, --sms.fnGetDCS(@DCS, @Encoding) /*DCS*/,
				@SubmittedTime,
				@NowUtc,
				@AdditionalInfo,
				sms.fnGetConnTypeId(@ProtocolSource),
				NULL, /*CorrelationId,*/
				NULL /*ConnErrorCode*/,
				ISNULL(@CostEURPerSms, @Cost),
				'EUR' /*CostCurrency*/,
				IIF(@CostContractCurrency = '', NULL, @CostContractPerSms),
				IIF(@CostContractCurrency = '', NULL, @CostContractCurrency),
				@CostEURPerSms,
				ISNULL(@PriceEURPerSms, @Price),
				'EUR' /*PriceCurrency*/,
				IIF(@PriceContractCurrency = '', NULL, @PriceContractPerSms),
				IIF(@PriceContractCurrency = '', NULL, @PriceContractCurrency),
				@PriceEURPerSms,
				@SegmentsReceived	/*SegmentsReceived*/,
				LEFT(@ClientMessageId,50),
				@ClientBatchId,
				@BatchId,
				@ClientDeliveryRequested, /* ClientDeliveryRequested */
				@Expiry)

		-- INSERT smscallback, but not override existing one
		IF  (@DlrCallbackUrl IS NOT NULL)
		BEGIN
			INSERT INTO sms.SmsCallbackCache (UMID, CallbackUrl)
			VALUES (@UMID, @DlrCallbackUrl)
		END

		-- Oracle responsys case - when @ClientMessageId is long
		IF LEN(@ClientMessageId) > 50
		BEGIN
			INSERT INTO sms.SmsLogClientMessageId (UMID, ClientMessageId)
			VALUES (@UMID, @ClientMessageId)
		END

		---- temporary hack for competition with Plivo for Garena + Telkomsel @ 2017
		--IF @SubAccountUid = 7153 /* plivo_india_hq */ AND @OperId = 510010
		--	WAITFOR DELAY '00:00:25'
		
		END TRY 
		BEGIN CATCH
			
			DECLARE @ErrorNum int = ERROR_NUMBER()
			
			-- log error
			INSERT INTO sms.Error (dt, [Source], UMID, [Message], Host)
			VALUES (GETUTCDATE(), 'SmsLog_InsertMT', @UMID, ERROR_MESSAGE() + ' Num:' + CAST(@ErrorNum AS varchar(50)), HOST_NAME())

			-- rethrow all except duplicated insert
			IF @ErrorNum <> 2627 -- Violation of PRIMARY KEY constraint
				THROW
		--	-- select top 1000 * from sms.Error order by id desc
		END CATCH
END
