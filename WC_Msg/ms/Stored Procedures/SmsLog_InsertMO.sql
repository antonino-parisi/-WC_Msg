-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-11-23
-- Description:	Insert of SMS record !!!! critical part of platform !!!
-- =============================================
CREATE PROCEDURE [ms].[SmsLog_InsertMO]
	@UMID				uniqueidentifier,
	@SubAccountUid		int,
	@MSISDN				bigint,
	@SmsStatusId		tinyint,
	@Source_Out			varchar(20),
	@Body_Out			nvarchar(1600),
	@ClientDeliveryRequested bit,	-- replaced @RegisteredDelivery	
	@ConnUid			int,
	@ConnMessageId		VARCHAR(50) = NULL,
	@Country			char(2),
	@OperatorId			int,
	@ProtocolSource		varchar(4),	
	@DCS				tinyint,	-- replace @EncodingTypeId, but not sure if it's right decision	
	@SegmentsReceived	tinyint,
	@SubmittedTime		datetime = NULL,
	@CostContractCurrency char(3) = 'EUR',
	@CostContractPerSms decimal(12,6) = 0,
	@PriceContractCurrency char(3) = 'EUR',
	@PriceContractPerSms decimal(12,6) = 0
AS
BEGIN
	SET NOCOUNT ON;

	--IF @SubAccountId = 'wavecell_dev_1' RETURN

	DECLARE @NowUtc datetime = GETUTCDATE()
	IF (@SubmittedTime IS NULL) SET @SubmittedTime = @NowUtc
	
	-- adjust Country and OperatorId values
	IF @OperatorId = 0 SET @OperatorId = NULL
	IF @Country IS NULL AND @OperatorId IS NOT NULL
		SELECT @Country = CountryISO2alpha FROM mno.Operator WHERE OperatorId = @OperatorId

	-- read backward compatibility columns
	DECLARE @ConnId varchar(50)
	SELECT @ConnId = ConnId FROM rt.SupplierConn WHERE ConnUid = @ConnUid
	
	DECLARE @SubAccountId varchar(50)
	IF @SubAccountUid IS NOT NULL AND @SubAccountUid > 0
		SELECT @SubAccountId = SubAccountId FROM ms.SubAccount WHERE SubAccountUid = @SubAccountUid
	ELSE
	BEGIN
		SET @SubAccountUid = ISNULL(@SubAccountUid, 0);
		SET @SubAccountId = 'NOT_DEFINED';
	END

	-- main operation
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
			0, -- SmsTypeId = 0 - MO
			@Country,
			@OperatorId,
			@SmsStatusId, -- sms.fnGetStatusId(@Status),
			@MSISDN,
			NULL, /*SourceOriginal,*/
			@Source_Out,
			NULL, /*BodyOriginal,*/
			@Body_Out,
			sms.fnGetEncodingTypeIdByDCS(@DCS),
			@DCS, --sms.fnGetDCS(@DCS, @Encoding) /*DCS*/,
			@SubmittedTime,
			@NowUtc,
			NULL, /*@AdditionalInfo,*/
			sms.fnGetConnTypeId(@ProtocolSource),
			@ConnMessageId, /*ConnMessageId,*/
			NULL, /*ConnErrorCode*/
			mno.CurrencyConverter(@CostContractPerSms, @CostContractCurrency, 'EUR', DEFAULT), /*Cost - backward compatibility */
			'EUR' /*CostCurrency*/,
			@CostContractPerSms, /*CostContractPerSms*/
			@CostContractCurrency /*CostContractCurrency*/,
			mno.CurrencyConverter(@CostContractPerSms, @CostContractCurrency, 'EUR', DEFAULT), /*CostEURPerSms - backward compatibility */
			mno.CurrencyConverter(@PriceContractPerSms, @PriceContractCurrency, 'EUR', DEFAULT), /*Price - backward compatibility */
			'EUR' /*PriceCurrency*/,
			@PriceContractPerSms, /*PriceContractPerSms*/
			@PriceContractCurrency /*PriceContractCurrency*/,
			mno.CurrencyConverter(@PriceContractPerSms, @PriceContractCurrency, 'EUR', DEFAULT), /*PriceEURPerSms - backward compatibility */
			@SegmentsReceived,	/*SegmentsReceived*/
			NULL, /* ClientMessageId */
			NULL, /* ClientBatchId */
			NULL, /* BatchId */
			@ClientDeliveryRequested, /* ClientDeliveryRequested */
			NULL /* Expiry */)
END
