-- =============================================
-- Author:		Anton Shchekalov
-- Last update date: 2016-11-01
-- Description:	Used in DRInListener
-- =============================================
-- EXEC [ms].[SmsLog_GetForDR] @CorrelationId = 'ka63605292103842055537', @Destination = '66826269423'
-- EXEC [ms].[SmsLog_GetForDR] @SubAccountId = 'wavecell_mon_1', @UMID = '02148207-b41f-4fcb-a9f6-f74b3bce9e63'
-- EXEC [ms].[SmsLog_GetForDR] @CorrelationId = 'ka63605292103842055537', @RouteId = 'Mailbit'
CREATE PROCEDURE [ms].[SmsLog_GetForDR]
	@UMID uniqueidentifier = NULL,
	@CorrelationId VARCHAR(50) = NULL,
	@ConnUid int
AS
BEGIN
	
	-- lookup by UMID
	IF (@UMID IS NOT NULL)
	BEGIN
		SELECT 
			sl.UMID,
			sl.SubAccountId,
			sl.Source, --varchar(32)
			sl.MSISDN, --bigint
			sl.ConnId AS RouteIdUsed,
			sl.ClientDeliveryRequested AS RegisteredDelivery,
			sl.Country,
			sl.OperatorId, 
			sl.CreatedTime AS DateTimeStamp,
			sl.Price, 
			sl.PriceCurrency AS Currency, 
			CASE sl.ConnTypeId
				WHEN 1 THEN 'HTTP'
				WHEN 2 THEN 'SMPP'
				WHEN 3 THEN 'WSMX'
			END AS ProtocolSource,
			sl.BatchId, 
			sl.ClientMessageId, 
			sl.ClientBatchId, 
			cb.CallbackUrl,
			sl.SegmentsReceived AS Segments,
			sl.PriceContractPerSms AS ContractPrice,
			sl.PriceContractCurrency AS ContractCurrency
		FROM sms.SmsLog sl WITH (NOLOCK)
			LEFT JOIN sms.SmsCallbackCache cb  WITH (NOLOCK) ON sl.UMID = cb.UMID
		WHERE
			-- This lookup by UMID is used in following cases:
			--    - first level DLRs (SENT, RECEIVED FOR PROCESSING)
			--	  - new Kannel integration which supports passing UMID
			--	  - HTTP suppliers, who support keeping client message id
			(sl.UMID = @UMID)
	END
	-- lookup by external ConnUid + CorrelationId
	ELSE IF (@CorrelationId IS NOT NULL AND @ConnUid IS NOT NULL)
	BEGIN

		-- lookup UMID by external ConnUid + CorrelationId
		IF @CorrelationId <> CAST(@UMID as VARCHAR(40))
			OR NOT EXISTS (SELECT TOP (1) 1 FROM sms.SmsLog WITH (NOLOCK) WHERE UMID = @UMID)
		BEGIN
			SELECT TOP (1) @UMID = UMID
			FROM sms.SmsLogConnMessageId
			WHERE ConnUid = @ConnUid AND ConnMessageId = @CorrelationId
		END

		SELECT 
			sl.UMID,
			sl.SubAccountId,
			sl.Source, --varchar(32)
			sl.MSISDN, --bigint
			sl.ConnId AS RouteIdUsed,
			sl.ClientDeliveryRequested AS RegisteredDelivery,
			sl.Country,
			sl.OperatorId, 
			sl.CreatedTime AS DateTimeStamp,
			sl.Price, 
			sl.PriceCurrency AS Currency, 
			CASE sl.ConnTypeId
				WHEN 1 THEN 'HTTP'
				WHEN 2 THEN 'SMPP'
				WHEN 3 THEN 'WSMX'
			END AS ProtocolSource,
			sl.BatchId, 
			sl.ClientMessageId, 
			sl.ClientBatchId, 
			cb.CallbackUrl,
			sl.SegmentsReceived AS Segments,
			sl.PriceContractPerSms AS ContractPrice,
			sl.PriceContractCurrency AS ContractCurrency
		FROM sms.SmsLog sl WITH (NOLOCK)
			LEFT JOIN sms.SmsCallbackCache cb  WITH (NOLOCK) ON sl.UMID = cb.UMID
		WHERE 
			(sl.UMID = @UMID)

	END
	ELSE
		THROW 51001, 'Wrong case for Lookup. Not supported', 1
END
