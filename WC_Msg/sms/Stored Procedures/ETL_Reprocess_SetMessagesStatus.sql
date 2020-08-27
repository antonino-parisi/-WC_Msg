
-- =============================================
-- Author: Tony Ivanov
-- Create date: 2020-08-12
-- Description:	Update processing status of batch
-- =============================================
CREATE PROCEDURE [sms].[ETL_Reprocess_SetMessagesStatus]
    @BatchId UNIQUEIDENTIFIER,
    @Status TINYINT,
    @LogType VARCHAR(10)
AS
BEGIN
    DECLARE @r BIGINT = 1;
    DECLARE @currentTime DATETIME2 = SYSUTCDATETIME();
    
	-- bulk update in smaller batches to prevent long table lock
	WHILE @r > 0
    BEGIN
        UPDATE TOP (4000) sms.ETL_Reprocess 
		SET Status = @Status, UpdatedAt = @CurrentTime
        WHERE BatchId = @BatchId AND LogType = @LogType AND Status <> @Status;
        
		SET @r = @@ROWCOUNT;
    END;
END
