
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2020-04-02
-- Description:	Export SMS Logs to external DWH storage
-- =============================================
-- EXEC sms.SmsLog_DWHExport @From = '2020-02-07 10:00', @To = '2020-02-07 10:30'
CREATE PROCEDURE [sms].[SmsLog_DWHExport]
    @From datetime,
    @To datetime,
    @SubAccountUid int = NULL
--WITH EXECUTE AS 'dbo'
AS
BEGIN

    -- validation
    IF @To <= @From OR DATEDIFF(MINUTE, @From, @To) > 30
        THROW 51000, 'Negative or too large time range', 1;

    -- main query
    SELECT
        CAST(lg.Umid as varchar(36)) AS Umid,
        lg.SubAccountId,
        lg.SubAccountUid,
        lg.ConnId,
        lg.ConnUid,
        lg.SmsTypeId,
        dst.SmsType,
        lg.Country,
        lg.OperatorId,
        o.OperatorName,
        o.MCC_Default AS MCC,
        o.MNC_Default AS MNC,
        lg.MSISDN,
        lg.Source,
        lg.SourceOriginal,
        lg.SegmentsReceived AS SmsCount,
        lg.DCS,
        det.EncodingType AS Encoding,
        lg.CreatedTime AS CreatedAt,
        lg.ConnMessageId,
        lg.ConnErrorCode,
        CAST(lg.BatchId AS varchar(36)) AS BatchId,
        lg.ClientBatchId,
        lg.ClientMessageId,
        lg.PriceContractCurrency AS PriceCurrency,
        lg.PriceContractPerSms AS PricePerSms,
        lg.CostContractCurrency as CostCurrency,
        lg.CostContractPerSms as CostPerSms,
        lg.StatusId AS StatusValue,
        IIF(err.WavecellErrorCode = 0, NULL, err.WavecellErrorCode) AS StatusErrorCode,
        IIF(err.WavecellErrorCode = 0, NULL, err.WavecellReasonCode) AS StatusErrorMessage,
        lg.Body
    FROM sms.SmsLog AS lg (NOLOCK)
        LEFT JOIN sms.DimEncodingType det ON lg.EncodingTypeId = det.EncodingTypeId
        LEFT JOIN sms.DimSmsType dst ON lg.SmsTypeId = dst.SmsTypeId
        LEFT JOIN mno.Operator o ON lg.OperatorId = o.OperatorId
        LEFT JOIN dbo.TrafficErrorCode err (NOLOCK) ON err.SupplierErrorCode = lg.ConnErrorCode AND err.RouteID = lg.ConnId
    WHERE lg.CreatedTime >= @From
      AND lg.CreatedTime < @To
      AND (@SubAccountUid IS NULL OR lg.SubAccountUid = @SubAccountUid)
    ORDER BY lg.CreatedTime
END
