-- =============================================
-- Author:		Anton Shchekalov
-- Last update date: 2016-11-01
-- Description:	Used in DRInListener
-- =============================================
-- EXEC [ms].[TrafficRecord_GetForDR] @CorrelationId = 'ka63605292103842055537', @Destination = '66826269423'
-- EXEC [ms].[TrafficRecord_GetForDR] @SubAccountId = 'lazada_id_ops1', @UMID = '1B2118EE-E5E7-E811-8144-02D9BAAA9E6F'
-- EXEC [ms].[TrafficRecord_GetForDR] @CorrelationId = '1B2118EE-E5E7-E811-8144-02D9BAAA9E6F', @UMID = '1B2118EE-E5E7-E811-8144-02D9BAAA9E6F', @RouteId = 'MDMedia_HQ_alpha'
CREATE PROCEDURE [ms].[TrafficRecord_GetForDR]
	@UMID VARCHAR(50) = NULL,
	@SubAccountId VARCHAR(50) = NULL,
	@CorrelationId VARCHAR(50) = NULL,
	@Destination VARCHAR(50)= NULL,
	@RouteId VARCHAR(50) = NULL
AS
BEGIN
	
	-- 3x times copy-paste to  optimize query execution time :(((
	--IF (@UMID IS NOT NULL AND @UMID <> '')
	--BEGIN
	--	SELECT 
	--		sl.SubAccountId, 
	--		CAST(sl.UMID AS VARCHAR(50)) AS UMID, 
	--		sl.Source, CAST(sl.MSISDN AS VARCHAR(50)) AS Destination, 
	--		0 AS Attempt, 
	--		sl.ConnId AS RouteIdUsed, 
	--		sl.ClientDeliveryRequested AS RegisteredDelivery,
	--		sl.OperatorId,
	--		sl.CreatedTime AS DateTimeStamp,
	--		CAST(sl.Price AS DECIMAL(18,5)) AS Price, 
	--		sl.PriceCurrency AS Currency, 
	--		CASE sl.ConnTypeId
	--			WHEN 1 THEN 'HTTP'
	--			WHEN 2 THEN 'SMPP'
	--			WHEN 3 THEN 'WSMX'
	--		END AS ProtocolSource, 
	--		NULL AS WavecellErrorCode,
	--		sl.ConnMessageId AS CorrelationId,
	--		sl.ClientMessageId,
	--		sl.BatchId, 
	--		sl.ClientBatchId, 
	--		cb.CallbackUrl
	--	FROM sms.SmsLog sl WITH (NOLOCK)
	--		LEFT JOIN sms.SmsCallbackCache cb  WITH (NOLOCK) ON sl.UMID = cb.UMID
	--	WHERE
	--		(sl.UMID = TRY_CAST(@UMID as uniqueidentifier))
	--END
	--ELSE 
	IF (@SubAccountId IS NOT NULL AND @SubAccountId <> '')
	BEGIN
		--THROW 51000, 'Lookup by SubAccountId without UMID is depricated. Say Hi to Anton.', 1;

		SELECT 
			sl.SubAccountId, 
			CAST(sl.UMID AS VARCHAR(50)) AS UMID, 
			sl.Source, CAST(sl.MSISDN AS VARCHAR(50)) AS Destination, 
			0 AS Attempt,
			sl.ConnId AS RouteIdUsed, 
			sl.ClientDeliveryRequested AS RegisteredDelivery,
			sl.OperatorId,
			sl.CreatedTime AS DateTimeStamp,
			CAST(sl.Price AS DECIMAL(18,5)) AS Price, 
			sl.PriceCurrency AS Currency, 
			CASE sl.ConnTypeId
				WHEN 1 THEN 'HTTP'
				WHEN 2 THEN 'SMPP'
				WHEN 3 THEN 'WSMX'
			END AS ProtocolSource, 
			NULL AS WavecellErrorCode,
			sl.ConnMessageId AS CorrelationId,
			sl.ClientMessageId,
			sl.BatchId, 
			sl.ClientBatchId, 
			cb.CallbackUrl
		FROM sms.SmsLog sl WITH (NOLOCK)
			LEFT JOIN sms.SmsCallbackCache cb  WITH (NOLOCK) ON sl.UMID = cb.UMID
		WHERE
			(sl.UMID = TRY_CAST(@UMID as uniqueidentifier))

		--SELECT 
		--	tr.SubAccountId, tr.UMID, 
		--	tr.Source, tr.Destination, tr.Attempt, 
		--	tr.RouteIdUsed, 
		--	RegisteredDelivery AS RegisteredDelivery,
		--	TRY_CAST(tr.OperatorId as int) AS OperatorId, 
		--	tr.DateTimeStamp,
		--	tr.Price, 'EUR' As Currency, 
		--	tr.ProtocolSource, NULL AS WavecellErrorCode, 
		--	tr.CorrelationId,
		--	sl.ClientMessageId, sl.BatchId, 
		--	sl.ClientBatchId, cb.CallbackUrl
		--FROM dbo.TrafficRecord tr WITH (NOLOCK)
		--	--LEFT JOIN TrafficErrorCode TE  WITH (NOLOCK) ON tr.RouteIdUsed = te.RouteID AND tr.ErrorCode = te.SupplierErrorCode
		--	LEFT JOIN sms.SmsLog sl WITH (NOLOCK) ON TRY_CAST(tr.UMID as uniqueidentifier) = sl.UMID
		--	LEFT JOIN sms.SmsCallbackCache cb  WITH (NOLOCK) ON tr.UMID = cb.UMID
		--WHERE 
		--	-- Usually First level DLRs (SENT, RECEIVED FOR PROCESSING)
		--	(tr.UMID = @UMID AND tr.SubAccountId = @SubAccountId)
	END
	ELSE IF (@CorrelationId IS NOT NULL AND @RouteId IS NOT NULL AND @RouteId <> '')
	BEGIN

		-- lookup UMID by external ConnUid + CorrelationId
		IF @CorrelationId <> @UMID 
			OR NOT EXISTS (SELECT TOP (1) 1 FROM sms.SmsLog WITH (NOLOCK) WHERE UMID = TRY_CAST(@UMID as uniqueidentifier))
		BEGIN
			DECLARE @ConnUid int
			SELECT TOP(1) @ConnUid = ConnUid
			FROM rt.SupplierConn (NOLOCK)
			WHERE ConnId = @RouteId

			SELECT TOP (1) @UMID = UMID
			FROM sms.SmsLogConnMessageId
			WHERE ConnUid = @ConnUid AND ConnMessageId = @CorrelationId
		END

		SELECT 
			sl.SubAccountId, 
			CAST(sl.UMID AS VARCHAR(50)) AS UMID, 
			sl.Source, CAST(sl.MSISDN AS VARCHAR(50)) AS Destination, 
			0 AS Attempt,
			sl.ConnId AS RouteIdUsed, 
			sl.ClientDeliveryRequested AS RegisteredDelivery,
			sl.OperatorId,
			sl.CreatedTime AS DateTimeStamp,
			CAST(sl.Price AS DECIMAL(18,5)) AS Price, 
			sl.PriceCurrency AS Currency, 
			CASE sl.ConnTypeId
				WHEN 1 THEN 'HTTP'
				WHEN 2 THEN 'SMPP'
				WHEN 3 THEN 'WSMX'
			END AS ProtocolSource, 
			NULL AS WavecellErrorCode,
			sl.ConnMessageId AS CorrelationId,
			sl.ClientMessageId,
			sl.BatchId, 
			sl.ClientBatchId, 
			cb.CallbackUrl
		FROM sms.SmsLog sl WITH (NOLOCK)
			LEFT JOIN sms.SmsCallbackCache cb  WITH (NOLOCK) ON sl.UMID = cb.UMID
		WHERE
			(sl.UMID = TRY_CAST(@UMID as uniqueidentifier))

	END
	ELSE IF (@CorrelationId IS NOT NULL AND @Destination IS NOT NULL)
	BEGIN
		THROW 51001, 'Lookup by CorrelationId+Destination should be depricated. Catching events. Say Hi to Anton.', 1;

		--SELECT 
		--	tr.SubAccountId, tr.UMID, 
		--	tr.Source, tr.Destination, 
		--	tr.Attempt, tr.RouteIdUsed, 
		--	RegisteredDelivery AS RegisteredDelivery,
		--	TRY_CAST(tr.OperatorId as int) AS OperatorId, 
		--	tr.DateTimeStamp,
		--	tr.Price, 'EUR' As Currency, 
		--	tr.ProtocolSource, te.WavecellErrorCode, 
		--	tr.CorrelationId,
		--	sl.ClientMessageId, sl.BatchId, 
		--	sl.ClientBatchId, cb.CallbackUrl
		--FROM dbo.TrafficRecord tr WITH (NOLOCK)
		--	LEFT JOIN TrafficErrorCode TE  WITH (NOLOCK) ON tr.RouteIdUsed = te.RouteID AND tr.ErrorCode = te.SupplierErrorCode
		--	LEFT JOIN sms.SmsLog sl WITH (NOLOCK) ON TRY_CAST(tr.UMID as uniqueidentifier) = sl.UMID
		--	LEFT JOIN sms.SmsCallbackCache cb  WITH (NOLOCK) ON tr.UMID = cb.UMID
		--WHERE 
		--	-- By CorrelationId AND MSISDN - Usully for SMPP (Kannel)
		--	(tr.CorrelationId = @CorrelationId and tr.Destination = @Destination)
	END
	
	-- Debug for unexpected cases
	--IF (@@ROWCOUNT <> 1)
	--	INSERT INTO ext.tmp_DLRLog (UMID, SubAccountId, CorrelationId, Destination, RouteId, OUT_Count)
	--	VALUES (@UMID, @SubAccountId, @CorrelationId, @Destination, @RouteId, @@ROWCOUNT)
END
