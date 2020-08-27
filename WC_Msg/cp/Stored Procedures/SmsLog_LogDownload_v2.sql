
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-08-14
-- =============================================
-- EXEC cp.[SmsLog_LogDownload_v2] @AccountUid = 'DCB63E13-4FDE-E711-8147-02D85F55FCE7', @UserId = 'EFA95606-53E7-473E-BD72-FEBA6F5AE27B', @SubAccountUid = 33466, @PageSize = 10000
CREATE PROCEDURE [cp].[SmsLog_LogDownload_v2]
	@AccountUid uniqueidentifier,
    @UserId uniqueidentifier,
	@SubAccountId varchar(50),
	@TimeFrom smalldatetime,
	@TimeTill smalldatetime,
	@PageOffset int = 0,
	@PageSize int = 10000
WITH EXECUTE AS OWNER
AS
BEGIN

	-- access check
	EXEC cp.User_CheckPermissions @AccountUid = @AccountUid, @UserId = @UserId, @SubAccountId = @SubAccountId

	-- validate params
	IF @PageSize < 1		SET @PageSize = 1
	IF @PageSize > 10000	SET @PageSize = 10000

	-- temporary, while INDEX is on SubAccountId column
	--DECLARE @SubAccountId varchar(50)
	--SELECT @SubAccountId =  SubAccountId FROM dbo.Account WHERE SubAccountUid = @SubAccountUid

	-- main select
	SELECT 
		CAST(sl.UMID AS VARCHAR(50)) AS UMID,
		sl.SubAccountId,
		CAST(FORMAT(sl.CreatedTime, 'yyyy-MM-dd HH:mm:ss') AS datetime) AS [Date Sent],
		--CAST(sl.CreatedTime AS SMALLDATETIME) AS [Date Sent],
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
		(sl.SegmentsReceived * sl.PriceContractPerSms) AS Cost,
		--st.StatusId,
		--st.Final,
		st.ShortenStatusName AS [Delivery Status],
		sl.ClientMessageId,
		IIF(sl.BatchId IS NULL, NULL, sl.ClientBatchId) AS ClientBatchId,
		det.EncodingType AS Encoding,
		sl.Body AS [Message Body]
	FROM sms.SmsLog sl  WITH (INDEX (IX_SmsLog_SubAccount_CreatedTime), NOLOCK)
		LEFT JOIN mno.Operator o ON sl.OperatorId = o.OperatorId
		LEFT JOIN sms.DimSmsStatus st ON sl.StatusId = st.StatusId
		--LEFT JOIN sms.DimConnType dct ON sl.ConnTypeId = dct.ConnTypeId
		LEFT JOIN sms.DimEncodingType det ON sl.EncodingTypeId = det.EncodingTypeId
	WHERE 
		sl.CreatedTime >= @TimeFrom AND sl.CreatedTime < @TimeTill
		--AND sl.SubAccountUid = @SubAccountUid -- TODO: there is no index yet for this column
		AND sl.SubAccountId = @SubAccountId
		--AND sl.SmsTypeId = 1
	ORDER BY sl.CreatedTime
	OFFSET (@PageOffset) ROWS FETCH NEXT (@PageSize) ROWS ONLY

END
