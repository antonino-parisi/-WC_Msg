
-- =============================================
-- Author:		Anton Ivanov
-- Create date: 2020-07-02
-- Description:	Export Ipm Logs to external DWH storage
-- =============================================
-- EXEC sms.IpmLog_DWHExport @From = '2020-02-07 10:00', @To = '2020-02-07 10:30'
CREATE PROCEDURE [sms].[IpmLog_DWHExport]
    @From datetime,
    @To datetime,
    @SubAccountUid int = NULL
AS
BEGIN
    -- validation
    IF @To <= @From OR DATEDIFF(MINUTE, @From, @To) > 30
        THROW 51000, 'Negative or too large time range', 1;

    -- main query
    SELECT
        CAST(il.Umid as varchar(36)) AS Umid,
        sa.SubAccountId,
        il.SubAccountUid,
        il.ChannelUid AS ChannelTypeId,
        CAST(il.ChannelId AS varchar(36)) AS ChannelId,
        il.Direction,
        il.Country,
        il.StatusId,
        il.MSISDN,
        il.ChannelUserId,
        dct.ContentType,
        il.CreatedAt,
        il.DeliveredAt,
        il.ReadAt,
        il.UpdatedAt,
        il.ClientMessageId,
        il.ClientBatchId,
        CAST(il.BatchId AS varchar(36)) AS BatchId,
        il.Step,
        il.ConnMessageId,
        il.ConnErrorCode,
        il.InitSession,
        il.Content
    FROM sms.IpmLog AS il (NOLOCK)
        LEFT JOIN ms.SubAccount sa ON sa.SubAccountUid = il.SubAccountUid
        LEFT JOIN sms.DimContentType dct ON dct.ContentTypeId = il.ContentTypeId
    WHERE il.CreatedAt >= @From
      AND il.CreatedAt < @To
      AND (@SubAccountUid IS NULL OR il.SubAccountUid = @SubAccountUid)
    ORDER BY il.CreatedAt
END
