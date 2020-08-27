

-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-08-13
-- =============================================
-- EXEC cp.[SmsLog_CampaignDownload_v2] @AccountUid = 'DCB63E13-4FDE-E711-8147-02D85F55FCE7', @CampaignId = 33466, @UserId = 'EFA95606-53E7-473E-BD72-FEBA6F5AE27B', @PageSize = 10000
CREATE PROCEDURE [cp].[SmsLog_CampaignDownload_v2]
	@AccountUid uniqueidentifier,
    @UserId uniqueidentifier,
	@CampaignId int,
	@PageOffset int = 0,
	@PageSize int = 10000
WITH EXECUTE AS OWNER
AS
BEGIN

	-- extract SubAccountId by CampaignId
	DECLARE @SubAccountId varchar(50)

	SELECT @SubAccountId = c.SubAccountId
	FROM cp.CmCampaign c
	WHERE c.AccountUid = @AccountUid AND c.CampaignId = @CampaignId

	-- access check
	EXEC cp.User_CheckPermissions @AccountUid = @AccountUid, @UserId = @UserId, @SubAccountId = @SubAccountId

	-- validate params
	IF @PageSize < 1		SET @PageSize = 1
	IF @PageSize > 10000	SET @PageSize = 10000

	-- main select
	SELECT 
		CAST(sl.UMID as varchar(50)) AS UMID,
		cb.SubAccountId,
		CAST(sl.CreatedTime as smalldatetime) AS [Date Sent],
		IIF(sl.SmsTypeId = 1, 'Outbound', 'Inbound') AS [Message Type],
		ISNULL(sl.Country, '') AS Country,
		--sl.OperatorId,
		ISNULL(o.OperatorName, '') AS Operator,
		ISNULL(o.MCC_Default, '') AS MCC,
		ISNULL(o.MNC_Default, '') AS MNC,
		sl.MSISDN AS [Mobile Number],
		ISNULL(sl.SourceOriginal, sl.Source) AS [Source Original],
		sl.Source AS [Source Replaced],
		sl.SegmentsReceived AS [SMS Parts],
		--sl.PriceCurrency AS Currency,
		sl.PriceContractCurrency AS Currency,
		--(sl.SegmentsReceived * sl.Price) AS Cost,
		sl.SegmentsReceived * sl.PriceContractPerSms AS Cost,
		--st.StatusId,
		--st.Final,
		st.ShortenStatusName AS [Delivery Status],
		sl.ClientMessageId,
		--IIF(sl.BatchId IS NULL, NULL, sl.ClientBatchId) AS ClientBatchId,
		--dct.ConnectionType,
		det.EncodingType AS Encoding,
		sl.Body AS [Message Body]
	FROM sms.SmsLog sl  WITH (INDEX (IX_SmsLog_SubAccount_CreatedTime), NOLOCK)
		LEFT JOIN mno.Operator o ON sl.OperatorId = o.OperatorId
		INNER JOIN (
			SELECT c.SubAccountUid, cb.BatchId, c.ScheduledAt, sa.SubAccountId
			FROM cp.CmCampaign c
				INNER JOIN cp.CmCampaignBatchIds cb ON  c.CampaignId = cb.CampaignId
				INNER JOIN ms.SubAccount sa ON c.SubAccountUid = sa.SubAccountUid
			WHERE --c.CampaignId = 33466
				c.AccountUid = @AccountUid 
				AND c.CampaignId = @CampaignId
				AND c.ScheduledAt < SYSUTCDATETIME()
			) cb ON sl.BatchId = cb.BatchId
		LEFT JOIN sms.DimSmsStatus st ON sl.StatusId = st.StatusId
		--LEFT JOIN sms.DimConnType dct ON sl.ConnTypeId = dct.ConnTypeId
		LEFT JOIN sms.DimEncodingType det ON sl.EncodingTypeId = det.EncodingTypeId
	WHERE 
		sl.CreatedTime BETWEEN DATEADD(MINUTE, -10, cb.ScheduledAt) AND DATEADD(MINUTE, 40, cb.ScheduledAt) 
		--AND sl.SubAccountUid = cb.SubAccountUid -- TODO: there is no index yet for this column
		AND sl.SubAccountId = cb.SubAccountId
		AND sl.SmsTypeId = 1
	ORDER BY sl.CreatedTime
	OFFSET (@PageOffset) ROWS FETCH NEXT (@PageSize) ROWS ONLY

END
