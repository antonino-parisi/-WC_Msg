-- =============================================
-- Author:		Team work
-- Create date: 2020-03-19
-- =============================================
-- SAMPLE:
-- EXEC ms.SmsLog_UpdateCorrelationId ...
CREATE PROCEDURE [ms].[SmsLog_UpdateCorrelationId]
	@UMID			uniqueidentifier,
	@CorrelationId	varchar(50)
AS
BEGIN

	IF @CorrelationId IS NULL 
		OR LEN(@CorrelationId) = 0
		OR CAST(@UMID as varchar(40)) = @CorrelationId /* ignore internal IDs */
		THROW 51000, 'Not acceptablable input params', 1;

	-- DLR Storage v2	
	DECLARE @OutT TABLE (ConnUid smallint NULL)
			
	UPDATE sms.SmsLog
	SET ConnMessageId = @CorrelationId
	OUTPUT inserted.ConnUid INTO @OutT 
	WHERE UMID = @UMID
	
	DECLARE @CntModified int = @@ROWCOUNT;
	
	-- populate of phisically managed index (due to limitation on ONLINE index in MSSQL Standard Edition)
	INSERT INTO sms.SmsLogConnMessageId (ConnUid, ConnMessageId, UMID)
	SELECT ConnUid, @CorrelationId, @UMID
	FROM @OutT
			
	/*
		@CntModified = 0 - No record in db
		@CntModified > 0 - Record updated
	*/
	SELECT @CntModified
END
