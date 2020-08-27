

-- =============================================
-- Author: Tony Ivanov
-- Create date: 2020-07-15
-- Description:	Get the list of messages to re-upload to S3
-- =============================================
CREATE PROCEDURE [sms].[ETL_Reprocess_GetListToReprocess]
    @BatchId UNIQUEIDENTIFIER
AS
BEGIN
    DECLARE @r BIGINT = 1;

    -- bulk update in smaller batches to prevent long table lock
	WHILE @r > 0
    BEGIN
        UPDATE TOP (4000) sms.ETL_Reprocess 
		SET BatchId = @BatchId
        WHERE Status = 0 AND BatchId <> @BatchId AND CreatedAt < GETUTCDATE();
        
		SET @r = @@ROWCOUNT;
    END;

    SELECT DISTINCT
        r.SubAccountUid,
        r.LogType,
        CONVERT(DATE, COALESCE(sms.CreatedTime, ipm.CreatedAt)) AS Date
    FROM sms.ETL_Reprocess r
		LEFT JOIN sms.SmsLog sms ON r.UMID = sms.UMID
		LEFT JOIN sms.IpmLog ipm ON r.UMID = ipm.UMID
    WHERE r.BatchId = @batchId
    GROUP BY r.LogType, r.SubAccountUid, CONVERT(DATE, COALESCE(sms.CreatedTime, ipm.CreatedAt))
END
