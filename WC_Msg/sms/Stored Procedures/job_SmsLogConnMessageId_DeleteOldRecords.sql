
-- =============================================
-- Author:		Rebecca
-- Create date: 2018-11-14
-- Description:	Delete records older than 3 days
-- =============================================
-- EXEC sms.job_SmsLogConnMessageId_DeleteOldRecords

CREATE PROCEDURE [sms].[job_SmsLogConnMessageId_DeleteOldRecords]
AS
BEGIN
	DECLARE @DaysToKeep TINYINT = 3 ;
	DECLARE @Batch INT = 10000 ;
	DECLARE @MinID BIGINT, @MaxID BIGINT ;
	DECLARE @CreatedTime DATETIME ;
	DECLARE @Loop BIT = 1 ;

	WHILE @Loop = 1
		BEGIN
			SELECT @MinID = ISNULL(MIN(ID),0)
			FROM sms.SmsLogConnMessageId WITH (NOLOCK, INDEX(PK_SmsLogConnMessageId)) ;

			PRINT dbo.CURRENT_TIMESTAMP_STR() + 'MinID = ' + CAST(@MinID AS VARCHAR(20)) ;

			IF @MinID = 0 --No record in sms.SmsLogConnMessageId
				BREAK ;

			SELECT @CreatedTime = CreatedTime
			FROM sms.SmsLog WITH (NOLOCK)
			WHERE UMID = (SELECT UMID
							FROM sms.SmsLogConnMessageId WITH (NOLOCK)
							WHERE ID = @MinID) ;

			IF @CreatedTime IS NULL OR @CreatedTime < DATEADD(dd, -(@DaysToKeep), CAST(GETDATE() AS DATE))
				BEGIN
					-- Delete records by batch
					SET @MaxID = @MinID + @Batch -1 ;

					DELETE FROM sms.SmsLogConnMessageId
						WHERE ID BETWEEN @MinID AND @MaxID ;

					EXEC dbo.Print_RowCount @msg = 'Delete from sms.SmsLogConnMessageId ', @procid=@@PROCID ;
				END ;
			ELSE
				SET @Loop = 0 ;
		END ;
END