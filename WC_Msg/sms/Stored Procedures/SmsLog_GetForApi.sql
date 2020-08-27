
-- =============================================
-- Author:		Sadeep Madurange
-- Create date: 2020-06-11
-- Description:	Procedure for querying message details for SMS.
-- =============================================
-- select top 10 * from sms.SmsLog
-- EXEC sms.SmsLog_GetForApi @UMID = '1BDB7812-C27F-EA11-AFA2-00155D0B6997', @SubAccountUid = 4216
CREATE PROCEDURE sms.SmsLog_GetForApi
	@Umid UNIQUEIDENTIFIER,
	@SubAccountUid INT
--WITH EXECUTE AS OWNER
AS
BEGIN
	SELECT
		sl.UMID As Umid,
		sa.SubAccountId,
		IIF(sl.SmsTypeId = 0, 'Inbound', 'Outbound') As Direction,
		sl.Country,
		sl.StatusId,
		dl.EventTime,
		IIF(err.WavecellErrorCode = 0, NULL, err.WavecellErrorCode) AS ErrorCode,
		IIF(err.WavecellErrorCode = 0, NULL, err.WavecellReasonCode) AS ErrorMessage,
		sl.MSISDN AS Msisdn,
		sl.Source,
		sl.Body,
		det.EncodingType AS Encoding,
		sl.CreatedTime AS CreatedAt,
		sl.SegmentsReceived AS SmsCount,
		sl.PriceContractPerSms,
		sl.PriceContractCurrency,
		sl.ClientMessageId,
		sl.ClientBatchId,
		sl.BatchId
	FROM sms.SmsLog sl (NOLOCK)
		INNER JOIN ms.SubAccount AS sa (NOLOCK) ON sa.SubAccountUid = sl.SubAccountUid
		-- workaround, as it might be few rows with same StatusId sometimes
		OUTER APPLY (SELECT TOP 1 EventTime FROM sms.DlrLog WITH (NOLOCK, FORCESEEK) WHERE UMID = sl.UMID AND StatusId = sl.StatusId ORDER BY DlrLogId) dl
		--LEFT JOIN sms.DlrLog dl ON dl.UMID = sl.UMID AND dl.StatusId = sl.StatusId -- (SELECT MAX(StatusId) FROM sms.DlrLog WHERE UMID = @Umid)
		--INNER JOIN sms.DimSmsStatus dss ON dss.StatusId = dl.StatusId
		-- TODO: to refactor legacy table dbo.TrafficErrorCode
		LEFT JOIN dbo.TrafficErrorCode err (NOLOCK) ON err.SupplierErrorCode = sl.ConnErrorCode AND err.RouteID = sl.ConnId
		INNER JOIN sms.DimEncodingType det (NOLOCK) ON det.EncodingTypeId = sl.EncodingTypeId
	WHERE sl.UMID = @Umid AND sl.SubAccountUid = @SubAccountUid
END
