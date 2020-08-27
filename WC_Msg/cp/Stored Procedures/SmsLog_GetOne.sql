-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-05-19
-- =============================================
-- EXEC cp.[SmsLog_GetOne] @TimeframeStart = '2017-08-02 00:00', @TimeframeEnd = '2017-08-04 00:00', @SubAccountId = 'wavecell_test2', @UMID = 'ABCDC24C-CD77-E711-8146-020897DF5459', @OutputDLRLog = 1
CREATE PROCEDURE [cp].[SmsLog_GetOne]
	@TimeframeStart datetime,
	@TimeframeEnd datetime,
	@SubAccountId varchar(50),
	@UMID uniqueidentifier,
	@OutputDLRLog bit = 0
WITH EXECUTE AS 'ref_smslog_read'
AS
BEGIN

	SELECT TOP (1) sl.UMID, CAST(sl.CreatedTime as smalldatetime) as CreatedTime, 
		sl.SubAccountId, sl.SmsTypeId, dst.SmsType,
		sl.Country, sl.OperatorId, o.OperatorName, sl.MSISDN, sl.SourceOriginal, sl.Source, sl.SegmentsReceived,
		(sl.SegmentsReceived * sl.Price) AS Price, sl.PriceCurrency,	sl.StatusId, dss.Final, dss.Status,
		sl.BatchId, 
		IIF(sl.BatchId IS NULL, NULL, sl.ClientMessageId) AS ClientMessageId, 
		IIF(sl.BatchId IS NULL, NULL, sl.ClientBatchId) AS ClientBatchId, 
		dct.ConnectionType, det.EncodingType
	
	FROM [sms].[SmsLog] sl (NOLOCK)
		LEFT JOIN mno.Operator o ON sl.OperatorId = o.OperatorId
		LEFT JOIN sms.DimSmsStatus dss ON sl.StatusId = dss.StatusId
		LEFT JOIN sms.DimSmsType dst ON sl.SmsTypeId = dst.SmsTypeId
		LEFT JOIN sms.DimConnType dct ON sl.ConnTypeId = dct.ConnTypeId
		LEFT JOIN sms.DimEncodingType det ON sl.EncodingTypeId = det.EncodingTypeId
	
	WHERE sl.UMID = @UMID
		AND sl.CreatedTime BETWEEN @TimeframeStart AND @TimeframeEnd -- for security check
		AND sl.SubAccountId = @SubAccountId	-- for security check

	-- DLR logs
	IF @OutputDLRLog = 1 AND @@ROWCOUNT > 0
	BEGIN
		SELECT [DlrLogId]
		  ,dl.[StatusId], dss.Status, dss.Level as Status_Level, dss.Final as Status_Final
		  ,[EventTime]
		  ,[Latency]
		FROM [sms].[DlrLog] dl
			LEFT JOIN sms.DimSmsStatus dss ON dl.StatusId = dss.StatusId
		WHERE dl.UMID = @UMID AND Latency >= 0
		ORDER BY dl.DlrLogId
	END
END
